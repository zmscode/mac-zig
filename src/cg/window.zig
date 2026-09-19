//! The window list: what windows exist on this machine, who owns them and
//! where they are.
//!
//! In C this is `CGWindowListCopyWindowInfo`, which returns a `CFArray` of
//! `CFDictionary`, each holding `CFNumber`s and `CFString`s under string
//! keys -- so reading a window's width means a dictionary lookup, a type
//! check, an unbox into a `CGRect` via
//! `CGRectMakeWithDictionaryRepresentation`, and a float. Here it is
//! `window.bounds.size.width`.
//!
//! ## Permission
//!
//! Window *titles* need Screen Recording permission on macOS 10.15 and
//! later. Everything else -- the owning application's name, the process ID,
//! the geometry, the layer -- is available without it. A `null` `title` on
//! a window that plainly has one means the permission is missing, not that
//! the window is untitled, and no error is reported for it.
//!
//! `hasScreenCaptureAccess` answers the question directly, and
//! `requestScreenCaptureAccess` prompts -- once, and once only, for the
//! life of a process that has been refused.

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const cf = @import("../cf.zig");
const geometry = @import("geometry.zig");
const image_mod = @import("image.zig");

const Error = errors.Error;
const Float = geometry.Float;
const Rect = geometry.Rect;
const Image = image_mod.Image;

/// Which windows to list. All false is `kCGWindowListOptionAll`: every
/// window, on screen or not.
pub const ListOptions = packed struct(u32) {
    /// Only windows currently on screen, in front-to-back order.
    on_screen_only: bool = false,
    /// Only the on-screen windows in front of `relative_to`.
    on_screen_above: bool = false,
    /// Only the on-screen windows behind `relative_to`.
    on_screen_below: bool = false,
    /// Include `relative_to` itself in an above or below listing.
    include_relative: bool = false,
    /// Leave out the desktop picture, the icons and the other pieces of
    /// the Finder's desktop. Usually wanted.
    exclude_desktop_elements: bool = false,
    _reserved: u27 = 0,

    /// The windows a person can actually see.
    pub const visible: ListOptions = .{
        .on_screen_only = true,
        .exclude_desktop_elements = true,
    };
};

/// One window, with its CoreFoundation dictionary already unpacked.
pub const Window = struct {
    /// The window's ID, for `relative_to` and for `createImage`.
    id: u32,
    /// The process that owns it.
    owner_pid: i32,
    /// The window's stacking layer. 0 is the ordinary application layer;
    /// higher is closer to the front, and the menu bar and dock are far
    /// above it.
    layer: i32,
    /// Where it is, in the global display space -- origin at the main
    /// display's top left, y downwards.
    bounds: Rect,
    /// 0 for a fully transparent window, 1 for an opaque one.
    alpha: Float,
    is_on_screen: bool,
    /// The owning application's name. Available without any permission.
    owner_name: ?[]const u8,
    /// The window's title. **Null without Screen Recording permission**,
    /// whether or not the window has one.
    title: ?[]const u8,

    /// A picture of this window, as an image the caller owns, at the
    /// window's real pixel size.
    ///
    /// Needs Screen Recording permission -- check `hasScreenCaptureAccess`
    /// first. **Apple marks this obsoleted as of macOS 15**
    /// (`obsoleted=15.0`, "Please use ScreenCaptureKit instead"), which in
    /// C is a hard compile error. Zig's C translator ignores availability
    /// attributes, so this compiles where clang would refuse, and it was
    /// still working on macOS 26.6. There will be no warning on the day it
    /// stops, only a null return.
    pub fn createImage(self: Window) Error!Image {
        const created = raw.CGWindowListCreateImage(
            Rect.nullRect().toRaw(),
            @backingInt(ListOptions{ .include_relative = true }),
            self.id,
            raw.kCGWindowImageDefault,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }
};

/// A snapshot of the window list. The strings inside the windows belong to
/// this list, so `deinit` frees them too.
pub const List = struct {
    windows: []const Window,

    pub fn deinit(self: List, allocator: std.mem.Allocator) void {
        for (self.windows) |window| {
            if (window.owner_name) |name| allocator.free(name);
            if (window.title) |name| allocator.free(name);
        }
        allocator.free(self.windows);
    }
};

/// Whether this process has Screen Recording permission.
///
/// This is what window titles, `Window.createImage` and
/// `Display.createImage` all need, and none of them report its absence as
/// an error -- a missing title is indistinguishable from an untitled
/// window, and a capture comes back null or blank depending on the
/// version. Check here instead of inferring it from a failure.
///
/// The input-monitoring equivalents are `cg.event.hasListenAccess` and
/// `requestListenAccess`.
pub fn hasScreenCaptureAccess() bool {
    return raw.CGPreflightScreenCaptureAccess();
}

/// Asks for Screen Recording permission, showing the system prompt.
///
/// **A process that has been denied once is never prompted again.** Apple's
/// own header says so: after a refusal the only way back is System
/// Settings -> Privacy & Security -> Screen Recording. So a `false` from
/// this is final for the life of the process, and the right response is to
/// tell the user where to go rather than to ask again.
///
/// Returns whether access is granted. Use `hasScreenCaptureAccess` to
/// check without prompting.
pub fn requestScreenCaptureAccess() bool {
    return raw.CGRequestScreenCaptureAccess();
}

/// Every window matching `options`, in front-to-back order.
///
/// `relative_to` is the window the above/below options are measured
/// against, and is ignored otherwise -- pass 0.
pub fn list(
    allocator: std.mem.Allocator,
    options: ListOptions,
    relative_to: u32,
) !List {
    const info = raw.CGWindowListCopyWindowInfo(@backingInt(options), relative_to);
    const array = cf.Array.fromRaw(try errors.checkPtr(info)) orelse return Error.Failed;
    defer array.deinit();

    var windows: std.ArrayList(Window) = .empty;
    // Frees whatever was parsed before the failure, strings included.
    errdefer {
        for (windows.items) |window| {
            if (window.owner_name) |name| allocator.free(name);
            if (window.title) |name| allocator.free(name);
        }
        windows.deinit(allocator);
    }

    var it = array.iterator();
    while (it.next()) |entry| {
        const dictionary = entry.as(cf.Dictionary) orelse continue;
        try windows.append(allocator, try parse(allocator, dictionary));
    }

    return .{ .windows = try windows.toOwnedSlice(allocator) };
}

fn parse(allocator: std.mem.Allocator, dictionary: cf.Dictionary) !Window {
    var window: Window = .{
        .id = @intCast(dictionary.getInt(raw.kCGWindowNumber) orelse 0),
        .owner_pid = @intCast(dictionary.getInt(raw.kCGWindowOwnerPID) orelse 0),
        .layer = @intCast(dictionary.getInt(raw.kCGWindowLayer) orelse 0),
        .bounds = .zero,
        .alpha = dictionary.getFloat(raw.kCGWindowAlpha) orelse 1,
        .is_on_screen = dictionary.getBool(raw.kCGWindowIsOnscreen) orelse false,
        .owner_name = null,
        .title = null,
    };

    // The bounds arrive as a nested dictionary of X, Y, Height and Width,
    // and CoreGraphics has a call to turn one back into a rectangle.
    if (dictionary.getAs(cf.Dictionary, raw.kCGWindowBounds)) |bounds_dictionary| {
        var area: raw.CGRect = undefined;
        if (raw.CGRectMakeWithDictionaryRepresentation(bounds_dictionary.toRaw(), &area)) {
            window.bounds = .fromRaw(area);
        }
    }

    window.owner_name = try dictionary.getString(allocator, raw.kCGWindowOwnerName);
    errdefer if (window.owner_name) |name| allocator.free(name);

    window.title = try dictionary.getString(allocator, raw.kCGWindowName);

    return window;
}

test "the window list parses into readable structs" {
    const found = try list(std.testing.allocator, .{}, 0);
    defer found.deinit(std.testing.allocator);

    // A machine with a window server always has something in the list,
    // but a headless one legitimately has nothing.
    if (found.windows.len == 0) return;

    for (found.windows) |window| {
        try std.testing.expect(window.alpha >= 0 and window.alpha <= 1);
        try std.testing.expect(window.bounds.width() >= 0);
        if (window.owner_name) |name| try std.testing.expect(name.len > 0);
    }
}

test "the visible preset is a subset of everything" {
    const everything = try list(std.testing.allocator, .{}, 0);
    defer everything.deinit(std.testing.allocator);

    const visible = try list(std.testing.allocator, .visible, 0);
    defer visible.deinit(std.testing.allocator);

    try std.testing.expect(visible.windows.len <= everything.windows.len);
    for (visible.windows) |window| {
        try std.testing.expect(window.is_on_screen);
    }
}

test "screen capture access can be checked without prompting" {
    // Only the preflight is called here. `requestScreenCaptureAccess`
    // would put a system dialog in front of whoever is running the tests.
    const granted = hasScreenCaptureAccess();

    const found = try list(std.testing.allocator, .visible, 0);
    defer found.deinit(std.testing.allocator);

    if (!granted) {
        // Without the permission no window reports a title, which is the
        // symptom this call exists to explain.
        for (found.windows) |window| try std.testing.expect(window.title == null);
    }
}

test "the list options pack into the word CoreGraphics expects" {
    const all: ListOptions = .{};
    try std.testing.expectEqual(@as(u32, raw.kCGWindowListOptionAll), @backingInt(all));

    const on_screen: ListOptions = .{ .on_screen_only = true };
    try std.testing.expectEqual(
        @as(u32, raw.kCGWindowListOptionOnScreenOnly),
        @backingInt(on_screen),
    );

    try std.testing.expectEqual(
        @as(u32, raw.kCGWindowListOptionOnScreenOnly) |
            @as(u32, raw.kCGWindowListExcludeDesktopElements),
        @backingInt(ListOptions.visible),
    );
}
