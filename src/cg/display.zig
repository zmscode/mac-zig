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
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const geometry = @import("geometry.zig");
const cf = @import("../cf.zig");
const image_mod = @import("image.zig");

const Error = errors.Error;
const Float = geometry.Float;
const Point = geometry.Point;
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

    /// A display from an id obtained elsewhere — SDL's
    /// `SDL_PROP_DISPLAY_KHRDISPLAY_...`, an AppKit `NSScreen`'s
    /// `NSScreenNumber`, or anything else that hands out a
    /// `CGDirectDisplayID`.
    ///
    /// Nothing is checked: an id for a display that has gone away fails at
    /// the call that uses it, not here.
    pub fn fromId(id: raw.CGDirectDisplayID) Display {
        return .{ .id = id };
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

    /// The display showing `point`, or null when nothing does -- which
    /// happens for a coordinate off the side of every screen.
    ///
    /// `point` is in the global display space: origin at the main
    /// display's top left, y downwards. That is the same space as
    /// `cg.event.Event.location()`, so the display under the cursor is:
    ///
    /// ```zig
    /// const now = try cg.event.Event.initCurrentState(null);
    /// defer now.deinit();
    /// const screen = cg.Display.containing(now.location()) orelse .main();
    /// ```
    ///
    /// It is also the space SDL reports window positions and display
    /// bounds in on macOS, so an SDL window's rectangle can be handed
    /// straight to `bestFor` without conversion.
    pub fn containing(point: Point) ?Display {
        var buffer: [max_displays]Display = undefined;
        const found = allContaining(point, &buffer) catch return null;
        if (found.len == 0) return null;
        return found[0];
    }

    /// Every display showing `point`. More than one means they are
    /// mirrored; zero means the point is off every screen.
    pub fn allContaining(point: Point, buffer: *[max_displays]Display) Error![]Display {
        var count: u32 = 0;
        try errors.checkCode(raw.CGGetDisplaysWithPoint(
            point.toRaw(),
            max_displays,
            @ptrCast(buffer),
            &count,
        ));
        return buffer[0..count];
    }

    /// Every display `area` overlaps, in no particular order.
    pub fn intersecting(area: Rect, buffer: *[max_displays]Display) Error![]Display {
        var count: u32 = 0;
        try errors.checkCode(raw.CGGetDisplaysWithRect(
            area.toRaw(),
            max_displays,
            @ptrCast(buffer),
            &count,
        ));
        return buffer[0..count];
    }

    /// The display `area` sits on most -- the one with the largest overlap.
    ///
    /// This is the question "which screen is this window on?" actually
    /// asks, since a window straddling two screens is on both and only one
    /// of them is the right place to go fullscreen. Null when `area`
    /// touches no display at all.
    pub fn bestFor(area: Rect) ?Display {
        var buffer: [max_displays]Display = undefined;
        const candidates = intersecting(area, &buffer) catch return null;

        var best: ?Display = null;
        var best_area: Float = 0;
        for (candidates) |candidate| {
            const overlap = candidate.bounds().intersection(area);
            if (overlap.isNull()) continue;

            const covered = overlap.width() * overlap.height();
            if (best == null or covered > best_area) {
                best = candidate;
                best_area = covered;
            }
        }
        return best;
    }

    /// The display's rectangle in the global space, in points. The main
    /// display is at the origin; others are placed around it.
    pub fn bounds(self: Display) Rect {
        return .fromRaw(raw.CGDisplayBounds(self.id));
    }

    /// The real backing-store size in pixels. On a Retina display this is
    /// larger than `bounds`, and it is the size a screen capture of this
    /// display comes back at.
    ///
    /// This deliberately does **not** use `CGDisplayPixelsWide`, which
    /// predates Retina and returns the size in *points* — on a 6016x3384
    /// panel it answers 3008x1692, and a capture buffer sized from it
    /// holds a quarter of the pixels. The number here comes from the
    /// current display mode instead, which reports both sizes honestly.
    ///
    /// `legacyPixelSize` is the old value, for anyone who needs to match
    /// what `CGDisplayPixelsWide` says.
    pub fn pixelSize(self: Display) Size {
        if (self.currentMode()) |mode| {
            defer mode.deinit();
            return mode.pixelSize();
        } else |_| {
            // Only reachable for a display that has gone away mid-call.
            return self.legacyPixelSize();
        }
    }

    /// What `CGDisplayPixelsWide` and `CGDisplayPixelsHigh` report, which
    /// is the size in points despite the name. Equal to `bounds().size`
    /// on every display this has been seen on.
    pub fn legacyPixelSize(self: Display) Size {
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

    /// A screenshot of this display, as an image the caller owns, at the
    /// display's real pixel size -- `pixelSize`, not `bounds`.
    ///
    /// Needs Screen Recording permission; check for it with
    /// `cg.window.hasScreenCaptureAccess` first, because without it this
    /// returns `error.Failed` on some versions and a blank image on
    /// others.
    ///
    /// **Apple marks this obsoleted as of macOS 15**
    /// (`obsoleted=15.0`, "Please use ScreenCaptureKit instead"), which in
    /// C is a hard compile error rather than a warning. Zig's C translator
    /// ignores availability attributes, so this compiles and links where
    /// clang would refuse -- and it was still working on macOS 26.6,
    /// returning a full-resolution image. That is a reprieve, not a
    /// guarantee: there will be no compiler warning on the day it stops,
    /// only a null return. ScreenCaptureKit is Objective-C and so is out
    /// of scope for this package.
    pub fn createImage(self: Display) Error!Image {
        const created = raw.CGDisplayCreateImage(self.id);
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// The same, for one rectangle of the display, with the same
    /// permission requirement and the same obsolescence.
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

test "pixelSize is the backing store, not the legacy point count" {
    var buffer: [max_displays]Display = undefined;
    if ((try Display.active(&buffer)).len == 0) return;

    const primary = Display.main();
    const points = primary.bounds().size;
    const pixels = primary.pixelSize();

    try std.testing.expect(pixels.width >= points.width);
    try std.testing.expect(pixels.height >= points.height);

    // The whole point of not using CGDisplayPixelsWide: on a Retina
    // display it answers in points, so it equals `bounds` where the real
    // backing store does not. Asserting `>=` alone passes either way,
    // which is how this was wrong in the first place.
    const mode = try primary.currentMode();
    defer mode.deinit();
    try std.testing.expect(pixels.eql(mode.pixelSize()));

    if (mode.isRetina()) {
        try std.testing.expect(pixels.width > points.width);
        try std.testing.expect(primary.legacyPixelSize().eql(points));
    }
}

test "a point on a display finds it, and one off every screen does not" {
    var buffer: [max_displays]Display = undefined;
    if ((try Display.active(&buffer)).len == 0) return;

    const primary = Display.main();
    const area = primary.bounds();

    // The centre of the main display is on the main display.
    try std.testing.expectEqual(primary.id, Display.containing(area.center()).?.id);

    // Far off the side of everything.
    try std.testing.expect(Display.containing(.init(-500_000, -500_000)) == null);
}

test "bestFor picks the display a rectangle mostly sits on" {
    var buffer: [max_displays]Display = undefined;
    if ((try Display.active(&buffer)).len == 0) return;

    const primary = Display.main();
    const area = primary.bounds();

    // A window wholly inside the main display is on the main display.
    const inside = Rect.init(area.minX() + 10, area.minY() + 10, 100, 100);
    try std.testing.expectEqual(primary.id, Display.bestFor(inside).?.id);

    // A rectangle touching nothing is on nothing.
    try std.testing.expect(Display.bestFor(.init(-500_000, -500_000, 10, 10)) == null);

    // Everything `intersecting` returns really does overlap.
    var overlap_buffer: [max_displays]Display = undefined;
    for (try Display.intersecting(inside, &overlap_buffer)) |screen| {
        try std.testing.expect(screen.bounds().intersects(inside));
    }
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
