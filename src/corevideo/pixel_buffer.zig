//! `CVPixelBuffer`: an image in memory, the currency of every video API
//! on the platform -- a camera frame, a decoded video frame, a screen
//! capture. Those made here, and nearly all the ones handed out, sit on an
//! IOSurface, so the GPU sees the same memory without a copy.

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const cf = @import("../cf.zig");
const cg = @import("../cg/cg.zig");
const iosurface = @import("../iosurface/iosurface.zig");
const corevideo = @import("corevideo.zig");

const Error = errors.Error;
const PixelFormat = iosurface.PixelFormat;

/// How a lock is taken. `CVPixelBufferLockFlags`.
pub const LockOptions = packed struct(u64) {
    /// Only read. Promising this lets CoreVideo skip invalidating whatever
    /// else caches the pixels, such as a texture over them.
    read_only: bool = false,
    _: u63 = 0,
};

/// A pixel buffer. From `init`, or `retain`ed, it is yours to `deinit`;
/// one handed to a callback -- `coremedia.SampleBuffer.imageBuffer` -- is
/// borrowed.
pub const PixelBuffer = struct {
    handle: *raw.struct___CVBuffer,

    pub const Options = struct {
        width: usize,
        height: usize,
        pixel_format: PixelFormat = .bgra,
        /// Backed by an IOSurface, and laid out so a Metal texture can be
        /// made over it. Off only for a buffer the CPU alone will use.
        metal_compatible: bool = true,
    };

    pub fn typeId() raw.CFTypeID {
        return raw.CVPixelBufferGetTypeID();
    }

    /// A new buffer, its memory allocated but not yet written. Yours.
    pub fn init(options: Options) Error!PixelBuffer {
        const no_properties = try cf.Dictionary.initFixed(.{});
        defer no_properties.deinit();
        // An IOSurface-properties entry, even an empty one, is what asks for
        // the IOSurface.
        const attributes = if (options.metal_compatible) try cf.Dictionary.initFixed(.{
            cf.Dictionary.Pair{ .key = key(raw.kCVPixelBufferIOSurfacePropertiesKey), .value = no_properties.asType() },
            cf.Dictionary.Pair{ .key = key(raw.kCVPixelBufferMetalCompatibilityKey), .value = cf.Boolean.of(true).asType() },
            cf.Dictionary.Pair{ .key = key(raw.kCVPixelBufferCGBitmapContextCompatibilityKey), .value = cf.Boolean.of(true).asType() },
        }) else try cf.Dictionary.initFixed(.{
            cf.Dictionary.Pair{ .key = key(raw.kCVPixelBufferCGBitmapContextCompatibilityKey), .value = cf.Boolean.of(true).asType() },
        });
        defer attributes.deinit();

        var out: raw.CVPixelBufferRef = null;
        try corevideo.check(raw.CVPixelBufferCreate(
            null,
            options.width,
            options.height,
            @backingInt(options.pixel_format),
            attributes.toRaw(),
            &out,
        ));
        return .{ .handle = out orelse return Error.Failed };
    }

    /// A buffer over an existing surface: the same memory, now in the form
    /// the video APIs take. Yours; it keeps the surface alive.
    pub fn initWithSurface(source: iosurface.Surface) Error!PixelBuffer {
        var out: raw.CVPixelBufferRef = null;
        try corevideo.check(raw.CVPixelBufferCreateWithIOSurface(null, source.toRaw(), null, &out));
        return .{ .handle = out orelse return Error.Failed };
    }

    fn key(value: raw.CFStringRef) cf.Type {
        return .{ .handle = value.? };
    }

    pub fn fromRaw(value: raw.CVPixelBufferRef) ?PixelBuffer {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: PixelBuffer) raw.CVPixelBufferRef {
        return self.handle;
    }

    pub fn deinit(self: PixelBuffer) void {
        raw.CVPixelBufferRelease(self.handle);
    }

    pub fn retain(self: PixelBuffer) PixelBuffer {
        return .{ .handle = raw.CVPixelBufferRetain(self.handle).? };
    }

    pub fn asType(self: PixelBuffer) cf.Type {
        return .{ .handle = self.handle };
    }

    pub fn width(self: PixelBuffer) usize {
        return raw.CVPixelBufferGetWidth(self.handle);
    }

    pub fn height(self: PixelBuffer) usize {
        return raw.CVPixelBufferGetHeight(self.handle);
    }

    pub fn size(self: PixelBuffer) cg.Size {
        return .{ .width = @floatFromInt(self.width()), .height = @floatFromInt(self.height()) };
    }

    /// Bytes from one row to the next, padding included. For a planar
    /// buffer, see `Locked.plane`.
    pub fn bytesPerRow(self: PixelBuffer) usize {
        return raw.CVPixelBufferGetBytesPerRow(self.handle);
    }

    pub fn pixelFormat(self: PixelBuffer) PixelFormat {
        return @fromBackingInt(raw.CVPixelBufferGetPixelFormatType(self.handle));
    }

    /// 0 for a packed format such as `.bgra`; 2 for `.ycbcr420_video`.
    pub fn planeCount(self: PixelBuffer) usize {
        return raw.CVPixelBufferGetPlaneCount(self.handle);
    }

    pub fn isPlanar(self: PixelBuffer) bool {
        return raw.CVPixelBufferIsPlanar(self.handle) != 0;
    }

    /// The surface underneath, or null for a buffer in ordinary memory.
    /// Borrowed from the buffer; `retain` it to keep it longer.
    pub fn surface(self: PixelBuffer) ?iosurface.Surface {
        return iosurface.Surface.fromRaw(raw.CVPixelBufferGetIOSurface(self.handle));
    }

    /// Locks the pixels for the CPU, as `iosurface.Surface.lock` does.
    pub fn lock(self: PixelBuffer, options: LockOptions) Error!Locked {
        try corevideo.check(raw.CVPixelBufferLockBaseAddress(self.handle, @bitCast(options)));
        return .{ .buffer = self, .options = options };
    }
};

/// A pixel buffer locked for the CPU. Its memory is valid until `unlock`.
pub const Locked = struct {
    buffer: PixelBuffer,
    options: LockOptions,

    pub fn unlock(self: Locked) void {
        _ = raw.CVPixelBufferUnlockBaseAddress(self.buffer.handle, @bitCast(self.options));
    }

    /// Every byte of a packed buffer, `bytesPerRow() * height()`. Only
    /// while the lock is held. A planar buffer's bytes are by `plane`.
    pub fn bytes(self: Locked) []u8 {
        std.debug.assert(!self.buffer.isPlanar());
        const base: [*]u8 = @ptrCast(raw.CVPixelBufferGetBaseAddress(self.buffer.handle).?);
        return base[0 .. self.buffer.bytesPerRow() * self.buffer.height()];
    }

    /// Row `y`, from the top, of a packed buffer -- padding included, since
    /// the pixel size is the format's business.
    pub fn row(self: Locked, y: usize) []u8 {
        const stride = self.buffer.bytesPerRow();
        return self.bytes()[y * stride ..][0..stride];
    }

    /// One plane of a planar buffer: luma is plane 0 of `.ycbcr420_video`,
    /// the interleaved chroma plane 1.
    pub fn plane(self: Locked, index: usize) Plane {
        const handle = self.buffer.handle;
        std.debug.assert(index < self.buffer.planeCount());
        const stride = raw.CVPixelBufferGetBytesPerRowOfPlane(handle, index);
        const rows = raw.CVPixelBufferGetHeightOfPlane(handle, index);
        const base: [*]u8 = @ptrCast(raw.CVPixelBufferGetBaseAddressOfPlane(handle, index).?);
        return .{
            .bytes = base[0 .. stride * rows],
            .bytes_per_row = stride,
            .width = raw.CVPixelBufferGetWidthOfPlane(handle, index),
            .height = rows,
        };
    }

    /// A CoreGraphics context drawing straight into the buffer. Only for
    /// `.bgra` buffers locked for writing. Yours to `deinit`, before
    /// `unlock`.
    pub fn initContext(self: Locked) Error!cg.Context {
        if (self.buffer.pixelFormat() != .bgra or self.options.read_only) return Error.IllegalArgument;
        return cg.Context.initBitmap(.{
            .width = self.buffer.width(),
            .height = self.buffer.height(),
            .bytes_per_row = self.buffer.bytesPerRow(),
            .bitmap_info = .bgra8888,
            .pixels = self.bytes(),
        });
    }
};

/// One plane of a locked planar buffer.
pub const Plane = struct {
    bytes: []u8,
    bytes_per_row: usize,
    /// In the plane's own samples: half the image's for 4:2:0 chroma.
    width: usize,
    height: usize,

    pub fn row(self: Plane, y: usize) []u8 {
        return self.bytes[y * self.bytes_per_row ..][0..self.bytes_per_row];
    }
};

test "a pixel buffer, drawn into and read back through its surface" {
    const buffer = try PixelBuffer.init(.{ .width = 32, .height = 16 });
    defer buffer.deinit();

    try std.testing.expectEqual(@as(usize, 32), buffer.width());
    try std.testing.expectEqual(PixelFormat.bgra, buffer.pixelFormat());
    try std.testing.expect(!buffer.isPlanar());
    {
        const locked = try buffer.lock(.{});
        defer locked.unlock();
        const ctx = try locked.initContext();
        defer ctx.deinit();
        ctx.setFillColor(.rgb(0, 1, 0));
        ctx.fillRect(.init(0, 0, 32, 8)); // the bottom half
    }

    // The same memory, seen as the surface.
    const surface = buffer.surface().?;
    try std.testing.expectEqual(@as(usize, 32), surface.width());
    const locked = try surface.lock(.{ .read_only = true });
    defer locked.unlock();
    try std.testing.expectEqualSlices(u8, &.{ 0, 255, 0, 255 }, locked.row(15)[0..4]);
    try std.testing.expectEqual(@as(u8, 0), locked.row(0)[3]);
}

test "a pixel buffer over a surface shares its memory" {
    const surface = try iosurface.Surface.init(.{ .width = 8, .height = 8 });
    defer surface.deinit();
    const buffer = try PixelBuffer.initWithSurface(surface);
    defer buffer.deinit();

    try std.testing.expectEqual(surface.id(), buffer.surface().?.id());
    {
        const locked = try buffer.lock(.{});
        defer locked.unlock();
        locked.row(3)[1] = 0x5A;
    }
    const locked = try surface.lock(.{ .read_only = true });
    defer locked.unlock();
    try std.testing.expectEqual(@as(u8, 0x5A), locked.row(3)[1]);
}

test "a planar buffer is reached by plane" {
    const buffer = try PixelBuffer.init(.{ .width = 16, .height = 8, .pixel_format = .ycbcr420_video });
    defer buffer.deinit();
    try std.testing.expect(buffer.isPlanar());
    try std.testing.expectEqual(@as(usize, 2), buffer.planeCount());

    const locked = try buffer.lock(.{});
    defer locked.unlock();
    const luma = locked.plane(0);
    const chroma = locked.plane(1);
    try std.testing.expectEqual(@as(usize, 16), luma.width);
    try std.testing.expectEqual(@as(usize, 8), chroma.width);
    try std.testing.expectEqual(@as(usize, 4), chroma.height);
    luma.row(7)[15] = 1;
    try std.testing.expectError(Error.IllegalArgument, locked.initContext());
}
