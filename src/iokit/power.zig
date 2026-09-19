//! Power sources: battery charge, whether the machine is on mains, and how
//! long it has left.
//!
//! In C this is `IOPSCopyPowerSourcesInfo` returning an opaque blob, then
//! `IOPSCopyPowerSourcesList` turning it into a `CFArray` of opaque
//! handles, then `IOPSGetPowerSourceDescription` turning each of those back
//! into a `CFDictionary` — whose keys are plain C strings that have to be
//! wrapped in `CFString`s before they can be looked up, and whose values
//! are `CFNumber`s and `CFBoolean`s that have to be unboxed one at a time.
//!
//! Here it is one call returning plain structs:
//!
//! ```zig
//! const state = try mac.iokit.power.snapshot(allocator);
//! defer state.deinit(allocator);
//!
//! if (state.battery()) |b| std.debug.print("{d}%\n", .{b.percent});
//! ```
//!
//! Nothing here needs a permission, and nothing here fails on a desktop
//! with no battery -- the source list is simply empty.

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const cf = @import("../cf.zig");

const Error = errors.Error;

/// What is powering the machine.
pub const State = enum {
    /// Running on mains.
    ac,
    /// Running on battery.
    battery,
    /// A source that is present but not supplying anything.
    off_line,
    /// A value IOKit reported that this binding does not name.
    unknown,
};

/// What kind of power source it is.
pub const Kind = enum {
    internal_battery,
    ups,
    unknown,
};

/// How close to empty the system thinks it is.
pub const WarningLevel = enum(i32) {
    none = 1,
    early = 2,
    final = 3,
    _,
};

/// One power source -- normally the internal battery, and on a desktop
/// normally none at all.
pub const Source = struct {
    /// The source's name, such as `"InternalBattery-0"`. Owned by the
    /// `Snapshot` it came from.
    name: []const u8,
    kind: Kind,
    state: State,
    is_present: bool,
    is_charging: bool,

    /// Charge as a percentage, 0 to 100.
    percent: u8,
    /// The raw capacity numbers the percentage is derived from. Their unit
    /// is whatever the source reports -- usually percent, so
    /// `max_capacity` is usually 100 rather than a milliamp-hour figure.
    current_capacity: i64,
    max_capacity: i64,

    /// Minutes until empty, or null while the system is still estimating
    /// or the source is charging.
    time_to_empty: ?u32,
    /// Minutes until full, or null while estimating or discharging.
    time_to_full: ?u32,

    /// The source's own assessment: `"Good"`, `"Fair"`, `"Poor"`. Null
    /// when it does not report one. Owned by the `Snapshot`.
    health: ?[]const u8,
};

/// Everything the system knows about power right now.
pub const Snapshot = struct {
    sources: []const Source,
    /// What is currently powering the machine, which is reported
    /// separately from any individual source.
    providing: State,

    pub fn deinit(self: Snapshot, allocator: std.mem.Allocator) void {
        for (self.sources) |source| {
            allocator.free(source.name);
            if (source.health) |h| allocator.free(h);
        }
        allocator.free(self.sources);
    }

    /// The internal battery, if this machine has one.
    pub fn battery(self: Snapshot) ?Source {
        for (self.sources) |source| {
            if (source.kind == .internal_battery) return source;
        }
        return null;
    }

    /// True when the machine is running off its own battery.
    pub fn onBattery(self: Snapshot) bool {
        return self.providing == .battery;
    }
};

/// Reads the current power state.
///
/// On a machine with no battery this returns a snapshot with no sources and
/// `providing` of `.ac`, rather than failing.
pub fn snapshot(allocator: std.mem.Allocator) !Snapshot {
    const blob = raw.IOPSCopyPowerSourcesInfo();
    const checked_blob = try errors.checkPtr(blob);
    defer raw.CFRelease(checked_blob);

    const providing = providingState(checked_blob);

    const list_ref = raw.IOPSCopyPowerSourcesList(checked_blob);
    const list = cf.Array.fromRaw(try errors.checkPtr(list_ref)) orelse
        return .{ .sources = &.{}, .providing = providing };
    defer list.deinit();

    var sources: std.ArrayList(Source) = .empty;
    errdefer {
        for (sources.items) |source| {
            allocator.free(source.name);
            if (source.health) |h| allocator.free(h);
        }
        sources.deinit(allocator);
    }

    var it = list.iterator();
    while (it.next()) |entry| {
        // The description is borrowed from the blob, not copied, so there
        // is nothing to release here.
        const description = cf.Dictionary.fromRaw(
            raw.IOPSGetPowerSourceDescription(checked_blob, entry.toRaw()),
        ) orelse continue;

        try sources.append(allocator, try parse(allocator, description));
    }

    return .{
        .sources = try sources.toOwnedSlice(allocator),
        .providing = providing,
    };
}

fn parse(allocator: std.mem.Allocator, description: cf.Dictionary) !Source {
    const name = try description.lookupString(allocator, raw.kIOPSNameKey);
    errdefer allocator.free(name);

    const health: ?[]const u8 =
        description.lookupString(allocator, raw.kIOPSBatteryHealthKey) catch null;
    errdefer if (health) |h| allocator.free(h);

    const current = try description.lookupInt(raw.kIOPSCurrentCapacityKey) orelse 0;
    const max = try description.lookupInt(raw.kIOPSMaxCapacityKey) orelse 0;

    const is_charging = try description.lookupBool(raw.kIOPSIsChargingKey) orelse false;
    const state = try sourceState(description);

    return .{
        .name = name,
        .kind = if (try description.lookupStringEquals(raw.kIOPSTypeKey, raw.kIOPSInternalBatteryType))
            .internal_battery
        else if (try description.lookupStringEquals(raw.kIOPSTypeKey, raw.kIOPSUPSType))
            .ups
        else
            .unknown,
        .state = state,
        .is_present = try description.lookupBool(raw.kIOPSIsPresentKey) orelse false,
        .is_charging = is_charging,
        .percent = percentOf(current, max),
        .current_capacity = current,
        .max_capacity = max,
        // IOKit reports -1 for "still working it out", and reports the
        // irrelevant half of the pair as 0 rather than omitting it -- a
        // machine on mains reports a time-to-empty of 0, which is not an
        // estimate that it is about to die. So each one is only taken when
        // the source is actually doing the thing it measures.
        .time_to_empty = positiveMinutes(
            try description.lookupInt(raw.kIOPSTimeToEmptyKey),
            state == .battery,
        ),
        .time_to_full = positiveMinutes(
            try description.lookupInt(raw.kIOPSTimeToFullChargeKey),
            is_charging,
        ),
        .health = health,
    };
}

fn percentOf(current: i64, max: i64) u8 {
    if (max <= 0) return 0;
    const ratio = @divTrunc(current * 100, max);
    return @intCast(std.math.clamp(ratio, 0, 100));
}

fn positiveMinutes(value: ?i64, relevant: bool) ?u32 {
    if (!relevant) return null;
    const minutes = value orelse return null;
    // -1 is IOKit's "still estimating"; 0 is what it reports for the half
    // of the pair that does not apply.
    if (minutes <= 0) return null;
    return @intCast(minutes);
}

fn sourceState(description: cf.Dictionary) Error!State {
    if (try description.lookupStringEquals(raw.kIOPSPowerSourceStateKey, raw.kIOPSACPowerValue)) {
        return .ac;
    }
    if (try description.lookupStringEquals(raw.kIOPSPowerSourceStateKey, raw.kIOPSBatteryPowerValue)) {
        return .battery;
    }
    if (try description.lookupStringEquals(raw.kIOPSPowerSourceStateKey, raw.kIOPSOffLineValue)) {
        return .off_line;
    }
    return .unknown;
}

fn providingState(blob: *const anyopaque) State {
    const reported = cf.String.fromRaw(raw.IOPSGetProvidingPowerSourceType(blob)) orelse
        return .unknown;

    inline for (.{
        .{ raw.kIOPSACPowerValue, State.ac },
        .{ raw.kIOPSBatteryPowerValue, State.battery },
        .{ raw.kIOPSOffLineValue, State.off_line },
    }) |pair| {
        const candidate = cf.String.init(pair[0]) catch return .unknown;
        defer candidate.deinit();
        if (raw.CFEqual(reported.handle, candidate.handle) != 0) return pair[1];
    }
    return .unknown;
}

/// Minutes of battery left, or null when the system is still estimating or
/// the machine is on mains.
///
/// Cheaper than a full `snapshot` -- no allocation, one call -- and this is
/// the number a status bar wants.
pub fn timeRemaining() ?u32 {
    const seconds = raw.IOPSGetTimeRemainingEstimate();
    // -1 is "still estimating", -2 is "unlimited", meaning on mains.
    if (seconds < 0) return null;
    return @intFromFloat(seconds / 60);
}

/// How close to empty the system thinks it is. This is what drives the
/// low-battery notifications, so it is the right thing to react to rather
/// than a percentage threshold of your own.
pub fn warningLevel() WarningLevel {
    return @fromBackingInt(@intCast(raw.IOPSGetBatteryWarningLevel()));
}

test "a snapshot reads without a permission and without a battery" {
    const state = try snapshot(std.testing.allocator);
    defer state.deinit(std.testing.allocator);

    // A desktop legitimately has no sources at all.
    try std.testing.expect(state.providing != .unknown);

    for (state.sources) |source| {
        try std.testing.expect(source.name.len > 0);
        try std.testing.expect(source.percent <= 100);
        // A source cannot be counting down to both empty and full.
        try std.testing.expect(source.time_to_empty == null or source.time_to_full == null);
    }
}

test "the internal battery, when there is one, is consistent with the whole" {
    const state = try snapshot(std.testing.allocator);
    defer state.deinit(std.testing.allocator);

    const b = state.battery() orelse return;

    try std.testing.expectEqual(Kind.internal_battery, b.kind);
    try std.testing.expect(b.max_capacity > 0);
    try std.testing.expectEqual(percentOf(b.current_capacity, b.max_capacity), b.percent);

    // Charging and running on battery are mutually exclusive.
    if (b.is_charging) try std.testing.expect(state.providing != .battery);
}

test "the cheap reads agree with the snapshot" {
    const state = try snapshot(std.testing.allocator);
    defer state.deinit(std.testing.allocator);

    // On mains the estimate is "unlimited", which is null here.
    if (state.providing == .ac) try std.testing.expect(timeRemaining() == null);

    // The warning level is only meaningful with a battery present.
    const level = warningLevel();
    if (state.battery() == null) try std.testing.expectEqual(WarningLevel.none, level);
}

test "percent is clamped and safe at zero capacity" {
    try std.testing.expectEqual(@as(u8, 0), percentOf(50, 0));
    try std.testing.expectEqual(@as(u8, 50), percentOf(50, 100));
    try std.testing.expectEqual(@as(u8, 100), percentOf(200, 100));
}

test "an irrelevant, unknown or zero time estimate becomes null" {
    // -1 is "still estimating".
    try std.testing.expect(positiveMinutes(-1, true) == null);
    // 0 is what IOKit reports for the half of the pair that does not
    // apply -- a machine on mains is not zero minutes from empty.
    try std.testing.expect(positiveMinutes(0, true) == null);
    try std.testing.expect(positiveMinutes(90, false) == null);
    try std.testing.expectEqual(@as(u32, 90), positiveMinutes(90, true).?);
}
