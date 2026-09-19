//! Synthetic input and event taps -- the part of CoreGraphics that talks to
//! the window server rather than to a drawing surface.
//!
//! ## Permission
//!
//! Neither half of this works on a modern macOS without the user's consent,
//! and neither half says so clearly:
//!
//! - **Posting** events needs Accessibility permission (System Settings ->
//!   Privacy & Security -> Accessibility). Without it `Event.post` is a
//!   silent no-op: no error, no code, nothing happens.
//! - **Tapping** events needs Input Monitoring permission.
//!   `hasListenAccess` reports whether it has been granted and
//!   `requestListenAccess` prompts for it, which is the only part of this
//!   that is checkable up front.
//!
//! Building and inspecting events needs no permission at all, which is why
//! that is what this module's tests cover.
//!
//! ## Coordinates
//!
//! Event locations are in the global display space: origin at the main
//! display's top left, y **downwards**. This is the display coordinate
//! system from `cg.display`, not a context's.

const std = @import("std");
const raw = @import("cg_raw");
const errors = @import("errors.zig");
const geometry = @import("geometry.zig");

const Error = errors.Error;
const Point = geometry.Point;

/// What an event is. The two `tap_disabled` values are not input -- they
/// arrive at a tap's callback when the system has switched the tap off,
/// which it does when a callback takes too long.
pub const Type = enum(u32) {
    null = 0,
    left_mouse_down = 1,
    left_mouse_up = 2,
    right_mouse_down = 3,
    right_mouse_up = 4,
    mouse_moved = 5,
    left_mouse_dragged = 6,
    right_mouse_dragged = 7,
    key_down = 10,
    key_up = 11,
    flags_changed = 12,
    scroll_wheel = 22,
    tablet_pointer = 23,
    tablet_proximity = 24,
    other_mouse_down = 25,
    other_mouse_up = 26,
    other_mouse_dragged = 27,
    /// The tap was switched off because a callback took too long. Re-enable
    /// it with `Tap.enable`.
    tap_disabled_by_timeout = 0xFFFFFFFE,
    tap_disabled_by_user_input = 0xFFFFFFFF,
    _,
};

pub const MouseButton = enum(u32) {
    left = 0,
    right = 1,
    center = 2,
    _,
};

/// The modifier keys and state flags carried by every event.
pub const Flags = packed struct(u64) {
    _reserved0: u8 = 0,
    /// The event was not merged with others of its kind. Mouse-moved
    /// events are coalesced by default.
    non_coalesced: bool = false,
    _reserved1: u7 = 0,
    caps_lock: bool = false,
    shift: bool = false,
    control: bool = false,
    /// The alt key.
    option: bool = false,
    command: bool = false,
    numeric_pad: bool = false,
    help: bool = false,
    /// The fn key.
    secondary_fn: bool = false,
    _reserved2: u40 = 0,

    pub inline fn toRaw(self: Flags) raw.CGEventFlags {
        return @backingInt(self);
    }

    pub inline fn fromRaw(value: raw.CGEventFlags) Flags {
        return @fromBackingInt(value);
    }
};

/// Where an event is posted to, or tapped from.
pub const TapLocation = enum(u32) {
    /// The very bottom of the stack, as though the hardware produced it.
    /// This is the one to post to.
    hid = 0,
    /// The window server's session, above the HID layer.
    session = 1,
    annotated_session = 2,
    _,
};

/// Whether a tap sees events before or after the taps already installed.
pub const TapPlacement = enum(u32) {
    head_insert = 0,
    tail_append = 1,
    _,
};

/// Whether a tap may change events or only watch them. A listen-only tap
/// needs Input Monitoring; a modifying one needs Accessibility as well.
pub const TapOptions = enum(u32) {
    default = 0,
    listen_only = 1,
    _,
};

pub const ScrollUnit = enum(u32) {
    /// Pixels, for smooth trackpad-style scrolling.
    pixel = 0,
    /// Lines, for a notched wheel.
    line = 1,
    _,
};

/// Which stream of state an event's unspecified fields are filled in from.
pub const SourceState = enum(i32) {
    /// A private state that this process's events do not share with
    /// anything else -- the right choice for automation that should not
    /// disturb the user's own modifier state.
    private = -1,
    combined_session = 0,
    hid_system = 1,
    _,
};

/// ANSI virtual key codes, which are positions on the keyboard rather than
/// the characters they produce -- `.a` is the key where A is on a US
/// layout, whatever the current layout types there.
///
/// These are Carbon's `kVK_*` constants. CoreGraphics takes them but does
/// not define them, so the common ones are named here; any other value goes
/// through as an integer.
pub const KeyCode = enum(u16) {
    a = 0,
    s = 1,
    d = 2,
    f = 3,
    h = 4,
    g = 5,
    z = 6,
    x = 7,
    c = 8,
    v = 9,
    b = 11,
    q = 12,
    w = 13,
    e = 14,
    r = 15,
    y = 16,
    t = 17,
    one = 18,
    two = 19,
    three = 20,
    four = 21,
    six = 22,
    five = 23,
    equal = 24,
    nine = 25,
    seven = 26,
    minus = 27,
    eight = 28,
    zero = 29,
    right_bracket = 30,
    o = 31,
    u = 32,
    left_bracket = 33,
    i = 34,
    p = 35,
    @"return" = 36,
    l = 37,
    j = 38,
    quote = 39,
    k = 40,
    semicolon = 41,
    backslash = 42,
    comma = 43,
    slash = 44,
    n = 45,
    m = 46,
    period = 47,
    tab = 48,
    space = 49,
    grave = 50,
    /// Backspace.
    delete = 51,
    escape = 53,
    command = 55,
    shift = 56,
    caps_lock = 57,
    option = 58,
    control = 59,
    right_shift = 60,
    right_option = 61,
    right_control = 62,
    function = 63,
    f5 = 96,
    f6 = 97,
    f7 = 98,
    f3 = 99,
    f8 = 100,
    f9 = 101,
    f11 = 103,
    f10 = 109,
    f12 = 111,
    home = 115,
    page_up = 116,
    forward_delete = 117,
    f4 = 118,
    end = 119,
    f2 = 120,
    page_down = 121,
    f1 = 122,
    left = 123,
    right = 124,
    down = 125,
    up = 126,
    _,
};

/// A field of an event's payload. `Event.integerField` reads one.
pub const Field = enum(u32) {
    mouse_event_number = 0,
    /// 1 for a single click, 2 for a double, and so on. Set this to
    /// synthesize a double click.
    mouse_click_state = 1,
    mouse_pressure = 2,
    mouse_button_number = 3,
    mouse_delta_x = 4,
    mouse_delta_y = 5,
    keyboard_autorepeat = 8,
    keyboard_keycode = 9,
    keyboard_type = 10,
    /// The scroll amount in **lines**, whatever unit the event was made
    /// with. A pixel-unit event reports the rounded line equivalent here,
    /// so a 5-pixel scroll reads back as 1 -- the pixel amount is in
    /// `scroll_point_delta_axis_1`.
    scroll_delta_axis_1 = 11,
    scroll_delta_axis_2 = 12,
    scroll_delta_axis_3 = 13,
    /// The scroll amount in pixels, for an event made with `.pixel` units.
    scroll_point_delta_axis_1 = 96,
    scroll_point_delta_axis_2 = 97,
    /// Non-zero for a trackpad-style continuous scroll.
    scroll_is_continuous = 88,
    event_target_pid = 39,
    event_source_pid = 41,
    _,
};

/// The state an event's unfilled fields are taken from. Events can be made
/// without one -- pass null -- in which case the system picks.
pub const Source = struct {
    handle: *raw.struct___CGEventSource,

    pub fn init(state: SourceState) Error!Source {
        const created = raw.CGEventSourceCreate(@backingInt(state));
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Source) void {
        raw.CFRelease(self.handle);
    }

    pub inline fn toRaw(self: Source) raw.CGEventSourceRef {
        return self.handle;
    }
};

pub const Event = struct {
    handle: *raw.struct___CGEvent,

    /// A mouse event of `of_type` at `position`. `button` is ignored for
    /// `.mouse_moved`, and for the left and right variants it must agree
    /// with `of_type` or the window server ignores the event.
    pub fn initMouse(
        source: ?Source,
        of_type: Type,
        position: Point,
        button: MouseButton,
    ) Error!Event {
        const created = raw.CGEventCreateMouseEvent(
            if (source) |s| s.toRaw() else null,
            @backingInt(of_type),
            position.toRaw(),
            @backingInt(button),
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// A key press or release. To type a character regardless of the
    /// current layout, make a key event and then call `setUnicodeString`.
    pub fn initKeyboard(source: ?Source, key: KeyCode, down: bool) Error!Event {
        const created = raw.CGEventCreateKeyboardEvent(
            if (source) |s| s.toRaw() else null,
            @backingInt(key),
            down,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// A scroll. `vertical` is positive upwards. `horizontal` null makes a
    /// one-axis event, which is what a plain wheel produces.
    ///
    /// The amounts are in `unit`. Reading them back is not symmetric:
    /// `scroll_delta_axis_1` is always in lines, so a `.pixel` event's
    /// amounts come back from `scroll_point_delta_axis_1` instead.
    pub fn initScroll(
        source: ?Source,
        unit: ScrollUnit,
        vertical: i32,
        horizontal: ?i32,
    ) Error!Event {
        const source_ref = if (source) |s| s.toRaw() else null;
        const created = if (horizontal) |h|
            raw.CGEventCreateScrollWheelEvent(source_ref, @backingInt(unit), 2, vertical, h)
        else
            raw.CGEventCreateScrollWheelEvent(source_ref, @backingInt(unit), 1, vertical);
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// An event carrying only the current state -- where the pointer is and
    /// which modifiers are held. Useful for reading, not for posting.
    pub fn initCurrentState(source: ?Source) Error!Event {
        const created = raw.CGEventCreate(if (source) |s| s.toRaw() else null);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Event) void {
        raw.CFRelease(self.handle);
    }

    pub fn retain(self: Event) Event {
        return .{ .handle = @ptrCast(raw.CFRetain(self.handle).?) };
    }

    pub fn fromRaw(value: raw.CGEventRef) ?Event {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: Event) raw.CGEventRef {
        return self.handle;
    }

    pub fn kind(self: Event) Type {
        return @fromBackingInt(@intCast(raw.CGEventGetType(self.handle)));
    }

    pub fn location(self: Event) Point {
        return .fromRaw(raw.CGEventGetLocation(self.handle));
    }

    pub fn setLocation(self: Event, position: Point) void {
        raw.CGEventSetLocation(self.handle, position.toRaw());
    }

    pub fn flags(self: Event) Flags {
        return .fromRaw(raw.CGEventGetFlags(self.handle));
    }

    pub fn setFlags(self: Event, value: Flags) void {
        raw.CGEventSetFlags(self.handle, value.toRaw());
    }

    pub fn integerField(self: Event, field: Field) i64 {
        return raw.CGEventGetIntegerValueField(self.handle, @backingInt(field));
    }

    pub fn setIntegerField(self: Event, field: Field, value: i64) void {
        raw.CGEventSetIntegerValueField(self.handle, @backingInt(field), value);
    }

    /// Makes a key event produce `text` whatever the key code says and
    /// whatever layout is active. This is how to type a character reliably.
    ///
    /// `text` is converted to UTF-16, which is what the window server
    /// wants, into a fixed buffer -- more than 256 UTF-16 code units is
    /// `error.RangeCheck`.
    pub fn setUnicodeString(self: Event, text: []const u8) Error!void {
        var utf16: [256]u16 = undefined;
        const len = std.unicode.utf8ToUtf16Le(&utf16, text) catch return Error.IllegalArgument;
        if (len > utf16.len) return Error.RangeCheck;
        raw.CGEventKeyboardSetUnicodeString(self.handle, @intCast(len), &utf16);
    }

    /// Sends the event.
    ///
    /// **Silently does nothing without Accessibility permission.** There is
    /// no return value and no error: CoreGraphics drops the event and says
    /// nothing. If synthetic input appears to do nothing at all, this is
    /// almost always why.
    pub fn post(self: Event, to: TapLocation) void {
        raw.CGEventPost(@backingInt(to), self.handle);
    }

    /// Sends the event to one process only. Subject to the same permission.
    pub fn postToPid(self: Event, pid: i32) void {
        raw.CGEventPostToPid(pid, self.handle);
    }
};

/// A hook into the event stream.
///
/// A tap's callback runs on whatever run loop the tap was added to, and the
/// system switches the tap off if a callback takes too long -- watch for
/// `.tap_disabled_by_timeout` and call `enable` again.
pub const Tap = struct {
    handle: raw.CFMachPortRef,

    pub const Options = struct {
        location: TapLocation = .session,
        placement: TapPlacement = .head_insert,
        options: TapOptions = .listen_only,
        /// Which event types to receive. Build it with `maskOf`.
        mask: u64,
    };

    /// The event mask for a set of types, for `Options.mask`.
    pub fn maskOf(types: []const Type) u64 {
        var mask: u64 = 0;
        for (types) |kind| mask |= @as(u64, 1) << @intCast(@backingInt(kind));
        return mask;
    }

    /// Installs a tap.
    ///
    /// `context` must be a pointer; it is handed to `handler` unchanged.
    /// The handler returns the event to pass on -- return the one it was
    /// given to let it through, or null to swallow it. Swallowing requires
    /// a tap created with `.options = .default`.
    ///
    /// Returns `error.CgError` when the permission is missing, which is the
    /// one part of this module that does report a failure.
    pub fn init(
        options: Options,
        context: anytype,
        comptime handler: fn (@TypeOf(context), Type, Event) ?Event,
    ) Error!Tap {
        const Context = @TypeOf(context);
        comptime std.debug.assert(@typeInfo(Context) == .pointer);

        const trampoline = struct {
            fn call(
                proxy: raw.CGEventTapProxy,
                kind: raw.CGEventType,
                event: raw.CGEventRef,
                info: ?*anyopaque,
            ) callconv(.c) raw.CGEventRef {
                _ = proxy;
                const recovered: Context = @ptrCast(@alignCast(info.?));
                const wrapped = Event.fromRaw(event) orelse return event;
                const result = handler(recovered, @fromBackingInt(@intCast(kind)), wrapped);
                return if (result) |kept| kept.toRaw() else null;
            }
        };

        const created = raw.CGEventTapCreate(
            @backingInt(options.location),
            @backingInt(options.placement),
            @backingInt(options.options),
            options.mask,
            trampoline.call,
            @ptrCast(@constCast(context)),
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Tap) void {
        raw.CFRelease(self.handle);
    }

    pub fn enable(self: Tap, on: bool) void {
        raw.CGEventTapEnable(self.handle, on);
    }

    pub fn isEnabled(self: Tap) bool {
        return raw.CGEventTapIsEnabled(self.handle);
    }

    /// Adds the tap to this thread's run loop, so its callback starts
    /// firing once the run loop runs.
    pub fn addToCurrentRunLoop(self: Tap) Error!void {
        const source = raw.CFMachPortCreateRunLoopSource(null, self.handle, 0);
        const checked = try errors.checkPtr(source);
        defer raw.CFRelease(checked);

        raw.CFRunLoopAddSource(
            raw.CFRunLoopGetCurrent(),
            checked,
            raw.kCFRunLoopCommonModes,
        );
    }
};

/// Moves the pointer without generating a mouse event, so nothing sees a
/// move. Needs Accessibility permission, and unlike `Event.post` it does
/// report failure.
pub fn warpCursor(to: Point) Error!void {
    try errors.checkCode(raw.CGWarpMouseCursorPosition(to.toRaw()));
}

/// Whether this process has Input Monitoring permission, which is what a
/// tap needs.
pub fn hasListenAccess() bool {
    return raw.CGPreflightListenEventAccess();
}

/// Asks for Input Monitoring permission, which shows the system prompt the
/// first time and does nothing on later calls. Returns whether it is
/// already granted.
pub fn requestListenAccess() bool {
    return raw.CGRequestListenEventAccess();
}

test "flags pack into the mask CoreGraphics expects" {
    const shifted: Flags = .{ .shift = true };
    try std.testing.expectEqual(@as(u64, raw.kCGEventFlagMaskShift), shifted.toRaw());

    const combo: Flags = .{ .command = true, .shift = true };
    try std.testing.expectEqual(
        @as(u64, raw.kCGEventFlagMaskCommand) | @as(u64, raw.kCGEventFlagMaskShift),
        combo.toRaw(),
    );

    try std.testing.expectEqual(
        @as(u64, raw.kCGEventFlagMaskSecondaryFn),
        (Flags{ .secondary_fn = true }).toRaw(),
    );
    try std.testing.expectEqual(combo, Flags.fromRaw(combo.toRaw()));
}

test "a mouse event remembers what it was built with" {
    const source = try Source.init(.private);
    defer source.deinit();

    const click = try Event.initMouse(source, .left_mouse_down, .init(100, 200), .left);
    defer click.deinit();

    try std.testing.expectEqual(Type.left_mouse_down, click.kind());
    try std.testing.expect(click.location().eql(Point.init(100, 200)));

    click.setLocation(.init(10, 20));
    try std.testing.expect(click.location().eql(Point.init(10, 20)));

    // Click state is how a double click is synthesized.
    click.setIntegerField(.mouse_click_state, 2);
    try std.testing.expectEqual(@as(i64, 2), click.integerField(.mouse_click_state));
}

test "a keyboard event carries its key code and flags" {
    const source = try Source.init(.private);
    defer source.deinit();

    const press = try Event.initKeyboard(source, .a, true);
    defer press.deinit();

    try std.testing.expectEqual(Type.key_down, press.kind());
    try std.testing.expectEqual(
        @as(i64, @backingInt(KeyCode.a)),
        press.integerField(.keyboard_keycode),
    );

    press.setFlags(.{ .command = true });
    try std.testing.expect(press.flags().command);
    try std.testing.expect(!press.flags().shift);

    // Typing a character regardless of layout.
    try press.setUnicodeString("é");
}

test "a scroll event has one axis or two" {
    const source = try Source.init(.private);
    defer source.deinit();

    const one_axis = try Event.initScroll(source, .line, 3, null);
    defer one_axis.deinit();
    try std.testing.expectEqual(Type.scroll_wheel, one_axis.kind());
    try std.testing.expectEqual(@as(i64, 3), one_axis.integerField(.scroll_delta_axis_1));

    const two_axis = try Event.initScroll(source, .pixel, 5, -7);
    defer two_axis.deinit();

    // A pixel-unit event keeps the pixel amounts in the point-delta fields;
    // the plain delta fields report the rounded line equivalent, which for
    // 5 and -7 pixels is 1 and -1.
    try std.testing.expectEqual(@as(i64, 5), two_axis.integerField(.scroll_point_delta_axis_1));
    try std.testing.expectEqual(@as(i64, -7), two_axis.integerField(.scroll_point_delta_axis_2));
    try std.testing.expectEqual(@as(i64, 1), two_axis.integerField(.scroll_delta_axis_1));
    try std.testing.expectEqual(@as(i64, -1), two_axis.integerField(.scroll_delta_axis_2));
}

test "an event mask sets one bit per type" {
    const mask = Tap.maskOf(&.{ .key_down, .key_up });
    const expected = (@as(u64, 1) << @backingInt(Type.key_down)) |
        (@as(u64, 1) << @backingInt(Type.key_up));
    try std.testing.expectEqual(expected, mask);
}

test "the current state can be read without any permission" {
    const state = try Event.initCurrentState(null);
    defer state.deinit();

    // Whatever the pointer's position is, it is a real point.
    const where = state.location();
    try std.testing.expect(!std.math.isNan(where.x));
    try std.testing.expect(!std.math.isNan(where.y));
}
