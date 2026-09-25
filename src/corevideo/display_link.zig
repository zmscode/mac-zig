//! `CVDisplayLink`: a callback once per refresh of a display, on a
//! high-priority thread of CoreVideo's own, with the time the frame being
//! prepared will reach the glass.
//!
//! Apple deprecated it in macOS 15 in favour of the display links AppKit
//! hands out for a view, window or screen (`appkit.View.displayLinkWithTargetSelector`,
//! which `appkit.MetalView` uses). It still works, and it is the one that
//! needs no view -- a headless renderer, an encoder pacing itself to a
//! display, or macOS 13, where AppKit has none.

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const cg = @import("../cg/cg.zig");
const corevideo = @import("corevideo.zig");

const Error = errors.Error;

/// A moment on a display's timeline. `CVTimeStamp`.
pub const TimeStamp = struct {
    raw: raw.CVTimeStamp,

    /// In the host clock's ticks, as `mach_absolute_time` counts.
    pub fn hostTime(self: TimeStamp) u64 {
        return self.raw.hostTime;
    }

    /// `hostTime` in seconds, on the same clock as
    /// `metal.all.currentMediaTime()`.
    pub fn seconds(self: TimeStamp) f64 {
        return @as(f64, @floatFromInt(self.raw.hostTime)) / raw.CVGetHostClockFrequency();
    }

    /// Seconds from one refresh to the next, or null when the display does
    /// not say.
    pub fn refreshPeriod(self: TimeStamp) ?f64 {
        if (self.raw.videoTimeScale == 0) return null;
        return @as(f64, @floatFromInt(self.raw.videoRefreshPeriod)) / @as(f64, @floatFromInt(self.raw.videoTimeScale));
    }
};

/// What a display link's callback is told.
pub const Tick = struct {
    /// When the callback was called.
    now: TimeStamp,
    /// When the frame being prepared will be shown. Animate to this.
    output: TimeStamp,
};

/// A display link. Yours to `deinit`, which stops it first.
pub const DisplayLink = struct {
    handle: *raw.struct___CVDisplayLink,

    /// A link that follows whichever active display it is set to; the main
    /// display to begin with.
    pub fn init() Error!DisplayLink {
        var out: raw.CVDisplayLinkRef = null;
        try corevideo.check(raw.CVDisplayLinkCreateWithActiveCGDisplays(&out));
        return .{ .handle = out orelse return Error.Failed };
    }

    /// A link for one display.
    pub fn initForDisplay(target: cg.Display) Error!DisplayLink {
        var out: raw.CVDisplayLinkRef = null;
        try corevideo.check(raw.CVDisplayLinkCreateWithCGDisplay(target.id, &out));
        return .{ .handle = out orelse return Error.Failed };
    }

    pub fn deinit(self: DisplayLink) void {
        _ = raw.CVDisplayLinkStop(self.handle);
        raw.CVDisplayLinkRelease(self.handle);
    }

    /// Follows `target` from now on -- when a window moves to another
    /// screen, say.
    pub fn setDisplay(self: DisplayLink, target: cg.Display) Error!void {
        try corevideo.check(raw.CVDisplayLinkSetCurrentCGDisplay(self.handle, target.id));
    }

    pub fn display(self: DisplayLink) cg.Display {
        return .{ .id = raw.CVDisplayLinkGetCurrentCGDisplay(self.handle) };
    }

    /// Calls `callback(context, tick)` once per refresh, once started.
    ///
    /// It runs on CoreVideo's thread, not the main thread: hand anything
    /// for AppKit to `dispatch.Queue.main()`. `context` is a pointer that
    /// must stay valid until the link is stopped.
    pub fn setCallback(
        self: DisplayLink,
        context: anytype,
        comptime callback: fn (@TypeOf(context), Tick) void,
    ) Error!void {
        const Context = @TypeOf(context);
        if (@typeInfo(Context) != .pointer) @compileError("a display link's context is a pointer; found " ++ @typeName(Context));
        const Trampoline = struct {
            fn call(
                _: raw.CVDisplayLinkRef,
                now: [*c]const raw.CVTimeStamp,
                output: [*c]const raw.CVTimeStamp,
                _: raw.CVOptionFlags,
                _: [*c]raw.CVOptionFlags,
                pointer: ?*anyopaque,
            ) callconv(.c) raw.CVReturn {
                callback(@ptrCast(@alignCast(pointer)), .{
                    .now = .{ .raw = now.* },
                    .output = .{ .raw = output.* },
                });
                return raw.kCVReturnSuccess;
            }
        };
        const erased: ?*anyopaque = @ptrCast(@constCast(context));
        try corevideo.check(raw.CVDisplayLinkSetOutputCallback(self.handle, Trampoline.call, erased));
    }

    pub fn start(self: DisplayLink) Error!void {
        try corevideo.check(raw.CVDisplayLinkStart(self.handle));
    }

    pub fn stop(self: DisplayLink) void {
        _ = raw.CVDisplayLinkStop(self.handle);
    }

    pub fn isRunning(self: DisplayLink) bool {
        return raw.CVDisplayLinkIsRunning(self.handle) != 0;
    }

    /// Seconds per refresh, as the display advertises it, or null when it
    /// does not say.
    pub fn nominalRefreshPeriod(self: DisplayLink) ?f64 {
        const period = raw.CVDisplayLinkGetNominalOutputVideoRefreshPeriod(self.handle);
        if (period.flags & raw.kCVTimeIsIndefinite != 0 or period.timeScale == 0) return null;
        return @as(f64, @floatFromInt(period.timeValue)) / @as(f64, @floatFromInt(period.timeScale));
    }

    /// Seconds per refresh, as measured while running; 0 until then.
    pub fn actualRefreshPeriod(self: DisplayLink) f64 {
        return raw.CVDisplayLinkGetActualOutputVideoRefreshPeriod(self.handle);
    }
};

test "a display link ticks, with output times that move forward" {
    const link = DisplayLink.init() catch return error.SkipZigTest; // no display
    defer link.deinit();

    const Counter = struct {
        ticks: std.atomic.Value(u32) = .init(0),
        last_output: std.atomic.Value(u64) = .init(0),
        backwards: std.atomic.Value(bool) = .init(false),

        fn tick(self: *@This(), t: Tick) void {
            const previous = self.last_output.swap(t.output.hostTime(), .acq_rel);
            if (t.output.hostTime() < previous) self.backwards.store(true, .release);
            _ = self.ticks.fetchAdd(1, .acq_rel);
        }
    };
    var counter: Counter = .{};
    try link.setCallback(&counter, Counter.tick);
    try link.start();
    try std.testing.expect(link.isRunning());

    // A few refreshes, at up to a second's worth of patience.
    var waited: u32 = 0;
    while (counter.ticks.load(.acquire) < 3 and waited < 100) : (waited += 1) {
        std.Io.sleep(std.testing.io, .fromMilliseconds(10), .awake) catch {};
    }
    link.stop();
    try std.testing.expect(counter.ticks.load(.acquire) >= 3);
    try std.testing.expect(!counter.backwards.load(.acquire));
    if (link.nominalRefreshPeriod()) |period| try std.testing.expect(period > 0 and period < 1);
}
