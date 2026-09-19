//! Displays: which screens exist, how big they are, and what they are
//! showing.
//!
//! A `Display` is an ID, not a handle -- there is nothing to release, but
//! also nothing keeping it valid. Unplugging a monitor or closing a laptop
//! lid invalidates one, and calls on a stale ID come back as
//! `error.IllegalArgument` rather than crashing. Re-read the list rather
//! than caching IDs across a reconfiguration.
//!
//! Coordinates here are in the global display space, where the main
//! display's top left is the origin and y grows **downwards** -- the
//! opposite of a drawing context. A second monitor placed to the left has a
//! negative x.

const std = @import("std");
const raw = @import("cg_raw");
const errors = @import("errors.zig");
const geometry = @import("geometry.zig");
const cf = @import("cf.zig");
const image_mod = @import("image.zig");

const Error = errors.Error;
const Float = geometry.Float;
const Rect = geometry.Rect;
const Size = geometry.Size;
const Image = image_mod.Image;

/// How many displays `all` and `online` will report before giving up.
/// macOS has never supported anything close to this many.
const max_displays = 64;

pub const Display = struct {
    id: raw.CGDirectDisplayID,

    /// The display with the menu bar, which is the origin of the global
    /// coordinate space.
    pub fn main() Display {
        return .{ .id = raw.CGMainDisplayID() };
    }

    /// Every display that can currently draw. `buffer` is filled and the
    /// populated prefix returned, so no allocation happens here.
    pub fn active(buffer: *[max_displays]Display) Error![]Display {
        var count: u32 = 0;
        try errors.checkCode(raw.CGGetActiveDisplayList(
            max_displays,
            @ptrCast(buffer),
            &count,
        ));
        return buffer[0..count];
    }

    /// Every display the system knows about, including ones mirrored into
    /// another and therefore not drawing on their own.
    pub fn online(buffer: *[max_displays]Display) Error![]Display {
        var count: u32 = 0;
        try errors.checkCode(raw.CGGetOnlineDisplayList(
            max_displays,
            @ptrCast(buffer),
            &count,
        ));
        return buffer[0..count];
    }

    /// The display's rectangle in the global space, in points. The main
    /// display is at the origin; others are placed around it.
    pub fn bounds(self: Display) Rect {
        return .fromRaw(raw.CGDisplayBounds(self.id));
    }

    /// The framebuffer size in pixels, which on a Retina display is larger
    /// than `bounds`.
    pub fn pixelSize(self: Display) Size {
        return .{
            .width = @floatFromInt(raw.CGDisplayPixelsWide(self.id)),
            .height = @floatFromInt(raw.CGDisplayPixelsHigh(self.id)),
        };
    }

    /// The physical size of the panel in millimetres, as the display
    /// reports it. Zero for a display that does not say.
    pub fn physicalSize(self: Display) Size {
        return .fromRaw(raw.CGDisplayScreenSize(self.id));
    }

    /// The rotation applied to this display, in degrees.
    pub fn rotation(self: Display) Float {
        return raw.CGDisplayRotation(self.id);
    }

    pub fn isMain(self: Display) bool {
        return raw.CGDisplayIsMain(self.id) != 0;
    }

    /// True for a laptop's internal panel.
    pub fn isBuiltin(self: Display) bool {
        return raw.CGDisplayIsBuiltin(self.id) != 0;
    }

    /// True when the display is drawing. A display mirrored into another is
    /// online but not active.
    pub fn isActive(self: Display) bool {
        return raw.CGDisplayIsActive(self.id) != 0;
    }

    pub fn isAsleep(self: Display) bool {
        return raw.CGDisplayIsAsleep(self.id) != 0;
    }

    pub fn vendorNumber(self: Display) u32 {
        return raw.CGDisplayVendorNumber(self.id);
    }

    pub fn modelNumber(self: Display) u32 {
        return raw.CGDisplayModelNumber(self.id);
    }

    pub fn serialNumber(self: Display) u32 {
        return raw.CGDisplaySerialNumber(self.id);
    }

    /// The mode the display is in. The caller owns it.
    pub fn currentMode(self: Display) Error!Mode {
        const copied = raw.CGDisplayCopyDisplayMode(self.id);
        return .{ .handle = try errors.checkPtr(copied) };
    }

    /// The modes this display supports, as a list the caller owns.
    ///
    /// **The display's current mode is often not in this list.** On a
    /// Retina display the current mode is a scaled one -- 3008x1692 points
    /// backed by 6016x3384 pixels -- and CoreGraphics leaves those out
    /// unless asked for them. Pass `.{ .include_scaled = true }` to get the
    /// list that contains the mode the display is actually in.
    pub fn modes(self: Display, options: ModeOptions) Error!ModeList {
        if (!options.include_scaled) {
            const copied = raw.CGDisplayCopyAllDisplayModes(self.id, null);
            return .{ .handle = try errors.checkPtr(copied) };
        }

        const bag = try cf.Dictionary.initFixed(.{
            .{
                .key = cf.Type{ .handle = raw.kCGDisplayShowDuplicateLowResolutionModes.? },
                .value = cf.Boolean.of(true).asType(),
            },
        });
        defer bag.deinit();

        const copied = raw.CGDisplayCopyAllDisplayModes(self.id, bag.toRaw());
        return .{ .handle = try errors.checkPtr(copied) };
    }

    pub const ModeOptions = struct {
        /// Include the scaled and HiDPI modes, which is what it takes to
        /// see the mode a Retina display is currently in.
        include_scaled: bool = false,
    };

    /// A screenshot of this display, as an image the caller owns.
    ///
    /// On macOS 14 and later this needs Screen Recording permission, and
    /// without it returns `error.CgError` -- or, worse on some versions, a
    /// blank image. Apple deprecated it in macOS 15 in favour of
    /// ScreenCaptureKit, which is not part of CoreGraphics and so is not
    /// wrapped here.
    pub fn createImage(self: Display) Error!Image {
        const created = raw.CGDisplayCreateImage(self.id);
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// The same, for one rectangle of the display.
    pub fn createImageForRect(self: Display, area: Rect) Error!Image {
        const created = raw.CGDisplayCreateImageForRect(self.id, area.toRaw());
        return .{ .handle = try errors.checkPtr(created) };
    }
};

/// A resolution and refresh rate a display can be set to.
pub const Mode = struct {
    handle: raw.CGDisplayModeRef,

    pub fn deinit(self: Mode) void {
        raw.CGDisplayModeRelease(self.handle);
    }

    pub inline fn toRaw(self: Mode) raw.CGDisplayModeRef {
        return self.handle;
    }

    /// The size in points, which is what a window is laid out against.
    pub fn size(self: Mode) Size {
        return .{
            .width = @floatFromInt(raw.CGDisplayModeGetWidth(self.handle)),
            .height = @floatFromInt(raw.CGDisplayModeGetHeight(self.handle)),
        };
    }

    /// The size in pixels. Twice `size` on a Retina mode, equal to it
    /// otherwise -- comparing the two is how to tell a scaled mode apart
    /// from a native one.
    pub fn pixelSize(self: Mode) Size {
        return .{
            .width = @floatFromInt(raw.CGDisplayModeGetPixelWidth(self.handle)),
            .height = @floatFromInt(raw.CGDisplayModeGetPixelHeight(self.handle)),
        };
    }

    /// Hertz, or 0 for a display with no fixed rate -- which is what most
    /// built-in panels report.
    pub fn refreshRate(self: Mode) f64 {
        return raw.CGDisplayModeGetRefreshRate(self.handle);
    }

    pub fn isRetina(self: Mode) bool {
        return raw.CGDisplayModeGetPixelWidth(self.handle) >
            raw.CGDisplayModeGetWidth(self.handle);
    }
};

/// The modes a display supports. Owns the underlying array; the modes
/// handed out by the iterator are borrowed from it and must not be
/// released.
pub const ModeList = struct {
    handle: raw.CFArrayRef,

    pub fn deinit(self: ModeList) void {
        raw.CFRelease(self.handle);
    }

    pub fn count(self: ModeList) usize {
        return @intCast(raw.CFArrayGetCount(self.handle));
    }

    pub fn at(self: ModeList, index: usize) ?Mode {
        if (index >= self.count()) return null;
        const value = raw.CFArrayGetValueAtIndex(self.handle, @intCast(index)) orelse return null;
        return .{ .handle = @ptrCast(@constCast(value)) };
    }

    pub fn iterator(self: ModeList) Iterator {
        return .{ .list = self, .index = 0 };
    }

    pub const Iterator = struct {
        list: ModeList,
        index: usize,

        pub fn next(self: *Iterator) ?Mode {
            const found = self.list.at(self.index) orelse return null;
            self.index += 1;
            return found;
        }
    };
};

test "the main display is one of the active ones" {
    var buffer: [max_displays]Display = undefined;
    const displays = try Display.active(&buffer);

    // A machine running tests headlessly can legitimately have none.
    if (displays.len == 0) return;

    const primary = Display.main();
    var found = false;
    for (displays) |display| {
        if (display.id == primary.id) found = true;
    }
    try std.testing.expect(found);
    try std.testing.expect(primary.isMain());
}

test "the main display sits at the origin of the global space" {
    var buffer: [max_displays]Display = undefined;
    if ((try Display.active(&buffer)).len == 0) return;

    const primary = Display.main();
    const area = primary.bounds();

    try std.testing.expectEqual(@as(Float, 0), area.origin.x);
    try std.testing.expectEqual(@as(Float, 0), area.origin.y);
    try std.testing.expect(area.width() > 0);
    try std.testing.expect(area.height() > 0);
}

test "a display's pixels are at least its points" {
    var buffer: [max_displays]Display = undefined;
    if ((try Display.active(&buffer)).len == 0) return;

    const primary = Display.main();
    const points = primary.bounds().size;
    const pixels = primary.pixelSize();

    try std.testing.expect(pixels.width >= points.width);
    try std.testing.expect(pixels.height >= points.height);
}

test "a display lists its modes" {
    var buffer: [max_displays]Display = undefined;
    if ((try Display.active(&buffer)).len == 0) return;

    const primary = Display.main();

    const current = try primary.currentMode();
    defer current.deinit();
    try std.testing.expect(current.size().width > 0);
    try std.testing.expect(current.pixelSize().width >= current.size().width);

    const plain = try primary.modes(.{});
    defer plain.deinit();
    try std.testing.expect(plain.count() > 0);
    try std.testing.expect(plain.at(plain.count()) == null);

    // Asking for the scaled modes can only ever add to the list, and on a
    // Retina display it is the difference between seeing the current mode
    // and not -- see the note on `modes`.
    const scaled = try primary.modes(.{ .include_scaled = true });
    defer scaled.deinit();
    try std.testing.expect(scaled.count() >= plain.count());

    var matched = false;
    var it = scaled.iterator();
    while (it.next()) |mode| {
        if (mode.size().eql(current.size()) and mode.pixelSize().eql(current.pixelSize())) {
            matched = true;
        }
    }
    try std.testing.expect(matched);
}
