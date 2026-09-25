//! [IOSurface](https://developer.apple.com/documentation/iosurface):
//! pixel buffers that more than one party can see -- reached as
//! `mac.iosurface`, under `-Diosurface`.
//!
//! A surface is memory the kernel manages on behalf of everyone using it:
//! the CPU through `lock`, the GPU through a Metal texture made over it,
//! Core Animation by setting it as a layer's contents, and another process
//! by its ID or a Mach port. Nothing is copied between them. This is how a
//! renderer hands frames to a window without a round trip -- Ghostty's
//! Metal renderer draws into one and shows it in a `CALayer`.
//!
//! ```zig
//! const surface = try iosurface.Surface.init(.{ .width = 640, .height = 480 });
//! defer surface.deinit();
//!
//! {
//!     const locked = try surface.lock(.{});
//!     defer locked.unlock();
//!     const ctx = try locked.initContext();      // draw into it with cg
//!     defer ctx.deinit();
//!     ctx.fillRect(.init(0, 0, 640, 480));
//! }
//!
//! const texture = device.newTextureWithDescriptorIosurfacePlane(descriptor, surface, 0);  // or the GPU
//! layer.setContents(objc.Object.fromCf(surface));                                           // or a layer
//! ```
//!
//! ## Locking
//!
//! The CPU may only touch a surface's memory while it is locked, because
//! the GPU may otherwise be using it, or the memory may not be mapped at
//! all. `lock` returns a `Locked`, which is the only way to reach the
//! bytes; `unlock` it -- with `defer` -- when done.

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const cf = @import("../cf.zig");
const cg = @import("../cg/cg.zig");

const Error = errors.Error;

/// True when the package was built with `-Diosurface` (the default).
pub const enabled = true;

/// What a surface's pixels are: a four-character code, spelled the way
/// Core Video spells it. Only the packed, single-plane formats are named;
/// any other code is `@enumFromInt` away.
pub const PixelFormat = enum(u32) {
    /// B, G, R, A, a byte each: what the display composites fastest, and
    /// Metal's `bgra8_unorm`.
    bgra = fourcc("BGRA"),
    /// R, G, B, A, a byte each.
    rgba = fourcc("RGBA"),
    /// A, R, G, B, a byte each.
    argb = fourcc("ARGB"),
    /// Ten bits per channel and two of alpha, little-endian: Metal's
    /// `bgr10a2_unorm`.
    l10r = fourcc("l10r"),
    /// Half-float R, G, B, A: Metal's `rgba16_float`.
    rgba_half = fourcc("RGhA"),
    /// One byte of gray.
    one_component8 = fourcc("L008"),
    _,

    fn fourcc(comptime code: *const [4]u8) u32 {
        return @as(u32, code[0]) << 24 | @as(u32, code[1]) << 16 | @as(u32, code[2]) << 8 | code[3];
    }
};

/// How a lock is taken.
pub const LockOptions = packed struct(u32) {
    /// Only read: the surface's seed does not change, and nothing is
    /// written back.
    read_only: bool = false,
    /// Do not wait for the GPU to finish with the surface first. Faster,
    /// and wrong unless something else guarantees it is finished.
    avoid_sync: bool = false,
    _: u30 = 0,
};

/// A shared pixel buffer. `init` makes one that is yours to `deinit`.
pub const Surface = struct {
    handle: *raw.struct___IOSurface,

    pub const Options = struct {
        width: usize,
        height: usize,
        pixel_format: PixelFormat = .bgra,
        /// Bytes per pixel.
        bytes_per_element: usize = 4,
        /// null lets IOSurface choose, aligned for the GPU -- which is
        /// usually wider than `width * bytes_per_element`.
        bytes_per_row: ?usize = null,
        /// Shows up in Instruments and in a debugger. macOS 11 and later.
        name: ?[]const u8 = null,
    };

    pub fn typeId() raw.CFTypeID {
        return raw.IOSurfaceGetTypeID();
    }

    /// A new surface, its memory allocated but not yet written. Yours.
    pub fn init(options: Options) Error!Surface {
        const wide = try cf.Number.initInt(@intCast(options.width));
        defer wide.deinit();
        const high = try cf.Number.initInt(@intCast(options.height));
        defer high.deinit();
        const element = try cf.Number.initInt(@intCast(options.bytes_per_element));
        defer element.deinit();
        const format = try cf.Number.initInt(@backingInt(options.pixel_format));
        defer format.deinit();
        const row = try cf.Number.initInt(@intCast(options.bytes_per_row orelse
            raw.IOSurfaceAlignProperty(raw.kIOSurfaceBytesPerRow, options.width * options.bytes_per_element)));
        defer row.deinit();
        const label = if (options.name) |text| try cf.String.init(text) else null;
        defer if (label) |l| l.deinit();

        var keys: [6]cf.Type = .{
            key(raw.kIOSurfaceWidth),           key(raw.kIOSurfaceHeight),
            key(raw.kIOSurfaceBytesPerElement), key(raw.kIOSurfacePixelFormat),
            key(raw.kIOSurfaceBytesPerRow),     key(raw.kIOSurfaceName),
        };
        var values: [6]cf.Type = .{ wide.asType(), high.asType(), element.asType(), format.asType(), row.asType(), undefined };
        const count: usize = if (label) |l| blk: {
            values[5] = l.asType();
            break :blk 6;
        } else 5;

        var pairs: [6]cf.Dictionary.Pair = undefined;
        for (keys[0..count], values[0..count], pairs[0..count]) |k, v, *pair| pair.* = .{ .key = k, .value = v };
        var buffer: [256]u8 = undefined;
        var fixed = std.heap.FixedBufferAllocator.init(&buffer);
        const properties = cf.Dictionary.init(fixed.allocator(), pairs[0..count]) catch return Error.Failed;
        defer properties.deinit();

        return .{ .handle = raw.IOSurfaceCreate(properties.toRaw()) orelse return Error.Failed };
    }

    fn key(value: raw.CFStringRef) cf.Type {
        return .{ .handle = value.? };
    }

    /// The surface another process published with `surface_id`, or null when
    /// there is none -- or when this process may not see it. Yours.
    pub fn lookup(surface_id: u32) ?Surface {
        return .{ .handle = raw.IOSurfaceLookup(surface_id) orelse return null };
    }

    /// The surface behind a port from `createMachPort`, received from
    /// another process. Yours; the port is not consumed.
    pub fn fromMachPort(port: raw.mach_port_t) ?Surface {
        return .{ .handle = raw.IOSurfaceLookupFromMachPort(port) orelse return null };
    }

    pub fn fromRaw(value: raw.IOSurfaceRef) ?Surface {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: Surface) raw.IOSurfaceRef {
        return self.handle;
    }

    pub fn deinit(self: Surface) void {
        raw.CFRelease(self.handle);
    }

    pub fn retain(self: Surface) Surface {
        return .{ .handle = @ptrCast(@constCast(raw.CFRetain(self.handle).?)) };
    }

    pub fn asType(self: Surface) cf.Type {
        return .{ .handle = self.handle };
    }

    /// A send right to this surface, for handing it to another process
    /// over XPC or a Mach message -- the secure way to share one. Yours to
    /// deallocate with `mach_port_deallocate`.
    pub fn createMachPort(self: Surface) raw.mach_port_t {
        return raw.IOSurfaceCreateMachPort(self.handle);
    }

    /// A system-wide ID. `lookup` finds the surface from it -- in another
    /// process only if that process is allowed to.
    pub fn id(self: Surface) u32 {
        return raw.IOSurfaceGetID(self.handle);
    }

    pub fn width(self: Surface) usize {
        return raw.IOSurfaceGetWidth(self.handle);
    }

    pub fn height(self: Surface) usize {
        return raw.IOSurfaceGetHeight(self.handle);
    }

    /// Bytes from one row to the next, padding included.
    pub fn bytesPerRow(self: Surface) usize {
        return raw.IOSurfaceGetBytesPerRow(self.handle);
    }

    pub fn bytesPerElement(self: Surface) usize {
        return raw.IOSurfaceGetBytesPerElement(self.handle);
    }

    pub fn pixelFormat(self: Surface) PixelFormat {
        return @fromBackingInt(@intCast(raw.IOSurfaceGetPixelFormat(self.handle)));
    }

    /// The whole allocation, in bytes.
    pub fn allocSize(self: Surface) usize {
        return raw.IOSurfaceGetAllocSize(self.handle);
    }

    /// A number that changes every time the surface is written through a
    /// lock -- how a reader tells whether there is a new frame.
    pub fn seed(self: Surface) u32 {
        return raw.IOSurfaceGetSeed(self.handle);
    }

    /// Whether any process -- the window server included -- is using the
    /// surface. A renderer recycles one that is not.
    pub fn isInUse(self: Surface) bool {
        return raw.IOSurfaceIsInUse(self.handle) != 0;
    }

    /// Locks the surface for the CPU. See the note at the top of this
    /// file.
    pub fn lock(self: Surface, options: LockOptions) Error!Locked {
        var seed_value: u32 = 0;
        if (raw.IOSurfaceLock(self.handle, @bitCast(options), &seed_value) != 0) return Error.Failed;
        return .{ .surface = self, .options = options, .seed = seed_value };
    }
};

/// A surface locked for the CPU. Its memory is valid until `unlock`.
pub const Locked = struct {
    surface: Surface,
    options: LockOptions,
    /// The surface's seed when the lock was taken.
    seed: u32,

    pub fn unlock(self: Locked) void {
        _ = raw.IOSurfaceUnlock(self.surface.handle, @bitCast(self.options), null);
    }

    /// Every byte of the surface: `bytesPerRow() * height()` and then some.
    /// Only for as long as the lock is held.
    pub fn bytes(self: Locked) []u8 {
        const base: [*]u8 = @ptrCast(raw.IOSurfaceGetBaseAddress(self.surface.handle).?);
        return base[0..self.surface.allocSize()];
    }

    /// Row `y`, from the top, without its padding.
    pub fn row(self: Locked, y: usize) []u8 {
        const stride = self.surface.bytesPerRow();
        const start = y * stride;
        return self.bytes()[start..][0 .. self.surface.width() * self.surface.bytesPerElement()];
    }

    /// A CoreGraphics context drawing straight into the surface -- no
    /// copy, and visible to the GPU and to anyone else holding the surface
    /// once unlocked. Only for `.bgra` surfaces. Yours to `deinit`, before
    /// `unlock`.
    ///
    /// The context's origin is at the bottom left, as always; row 0 of the
    /// surface is its top.
    pub fn initContext(self: Locked) Error!cg.Context {
        if (self.surface.pixelFormat() != .bgra or self.options.read_only) return Error.IllegalArgument;
        return cg.Context.initBitmap(.{
            .width = self.surface.width(),
            .height = self.surface.height(),
            .bytes_per_row = self.surface.bytesPerRow(),
            .bitmap_info = .bgra8888,
            .pixels = self.bytes(),
        });
    }
};

test "a surface, written through a lock and read back" {
    const surface = try Surface.init(.{ .width = 20, .height = 10, .name = "mac-zig test" });
    defer surface.deinit();

    try std.testing.expectEqual(@as(usize, 20), surface.width());
    try std.testing.expectEqual(PixelFormat.bgra, surface.pixelFormat());
    // Aligned for the GPU: at least a row of pixels, usually more.
    try std.testing.expect(surface.bytesPerRow() >= 20 * 4);

    const before = surface.seed();
    {
        const locked = try surface.lock(.{});
        defer locked.unlock();
        const ctx = try locked.initContext();
        defer ctx.deinit();
        ctx.setFillColor(.rgb(1, 0, 0));
        ctx.fillRect(.init(0, 0, 20, 5)); // the bottom half
    }
    try std.testing.expect(surface.seed() != before);

    const locked = try surface.lock(.{ .read_only = true });
    defer locked.unlock();
    // B, G, R, A: red at the bottom, untouched at the top.
    try std.testing.expectEqualSlices(u8, &.{ 0, 0, 255, 255 }, locked.row(9)[0..4]);
    try std.testing.expectEqual(@as(u8, 0), locked.row(0)[3]);
    try std.testing.expectError(Error.IllegalArgument, locked.initContext());
}

test "a surface can be found again by its ID" {
    const surface = try Surface.init(.{ .width = 4, .height = 4 });
    defer surface.deinit();
    const found = Surface.lookup(surface.id()).?;
    defer found.deinit();
    // A new reference, not the same pointer -- but the same memory.
    try std.testing.expectEqual(surface.id(), found.id());
    {
        const locked = try surface.lock(.{});
        defer locked.unlock();
        locked.row(2)[0] = 0xAB;
    }
    const locked = try found.lock(.{ .read_only = true });
    defer locked.unlock();
    try std.testing.expectEqual(@as(u8, 0xAB), locked.row(2)[0]);
}
