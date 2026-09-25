//! `CVMetalTextureCache`: Metal textures over pixel buffers, without a
//! copy -- how a camera frame, a decoded video frame or a screen capture
//! reaches a shader.
//!
//! The cache keeps a texture per buffer and plane it has seen, so a stream
//! that recycles a small pool of buffers -- which every video source does
//! -- stops allocating after the first few frames.
//!
//! These calls take `id<MTLDevice>` and so are declared to Objective-C
//! only; the C translator never sees them, and they are declared here.

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const objc = @import("../objc/objc.zig");
const metal = @import("../metal/metal.zig");
const corevideo = @import("corevideo.zig");
const PixelBuffer = @import("pixel_buffer.zig").PixelBuffer;

const Error = errors.Error;

const CacheHandle = opaque {};

extern fn CVMetalTextureCacheCreate(
    allocator: raw.CFAllocatorRef,
    cache_attributes: raw.CFDictionaryRef,
    metal_device: *anyopaque,
    texture_attributes: raw.CFDictionaryRef,
    cache_out: *?*CacheHandle,
) raw.CVReturn;
extern fn CVMetalTextureCacheCreateTextureFromImage(
    allocator: raw.CFAllocatorRef,
    texture_cache: *CacheHandle,
    source_image: raw.CVImageBufferRef,
    texture_attributes: raw.CFDictionaryRef,
    pixel_format: objc.UInteger,
    width: usize,
    height: usize,
    plane_index: usize,
    texture_out: *raw.CVBufferRef,
) raw.CVReturn;
extern fn CVMetalTextureCacheFlush(texture_cache: *CacheHandle, options: raw.CVOptionFlags) void;
extern fn CVMetalTextureGetTexture(image: raw.CVBufferRef) ?*anyopaque;
extern fn CVMetalTextureIsFlipped(image: raw.CVBufferRef) raw.Boolean;

/// A texture cache for one device. Yours to `deinit`.
pub const MetalTextureCache = struct {
    handle: *CacheHandle,

    pub fn init(device: metal.Device) Error!MetalTextureCache {
        var out: ?*CacheHandle = null;
        try corevideo.check(CVMetalTextureCacheCreate(null, null, device.object.value, null, &out));
        return .{ .handle = out orelse return Error.Failed };
    }

    pub fn deinit(self: MetalTextureCache) void {
        raw.CFRelease(self.handle);
    }

    pub const TextureOptions = struct {
        /// How the shader sees the pixels. It has to agree with the
        /// buffer's layout: `.bgra8_unorm` for `.bgra`; `.r8_unorm` for the
        /// luma plane of `.ycbcr420_video` and `.rg8_unorm` for its chroma.
        pixel_format: metal.PixelFormat = .bgra8_unorm,
        /// For a planar buffer, which plane. Ignored otherwise.
        plane: usize = 0,
    };

    /// A texture over `buffer`'s memory. Yours to `deinit`; hold it for as
    /// long as the GPU may read the texture, since the buffer is only
    /// recycled once nobody does.
    pub fn texture(self: MetalTextureCache, buffer: PixelBuffer, options: TextureOptions) Error!MetalTexture {
        const w, const h = if (buffer.isPlanar()) .{
            raw.CVPixelBufferGetWidthOfPlane(buffer.handle, options.plane),
            raw.CVPixelBufferGetHeightOfPlane(buffer.handle, options.plane),
        } else .{ buffer.width(), buffer.height() };
        var out: raw.CVBufferRef = null;
        try corevideo.check(CVMetalTextureCacheCreateTextureFromImage(
            null,
            self.handle,
            buffer.handle,
            null,
            @backingInt(options.pixel_format),
            w,
            h,
            options.plane,
            &out,
        ));
        return .{ .handle = out orelse return Error.Failed };
    }

    /// Lets go of textures no longer in use. Worth calling now and then --
    /// once a frame is plenty -- or unused ones age out after a second.
    pub fn flush(self: MetalTextureCache) void {
        CVMetalTextureCacheFlush(self.handle, 0);
    }
};

/// A texture from `MetalTextureCache.texture`: the `CVMetalTexture` that
/// keeps the pixel buffer from being recycled, and the Metal texture in it.
pub const MetalTexture = struct {
    handle: *raw.struct___CVBuffer,

    pub fn deinit(self: MetalTexture) void {
        raw.CVBufferRelease(self.handle);
    }

    /// The Metal texture. Borrowed: it lives as long as this does.
    pub fn texture(self: MetalTexture) metal.Texture {
        return .{ .object = .{ .value = CVMetalTextureGetTexture(self.handle).? } };
    }

    /// Whether texture row 0 is the top of the image. It is, for every
    /// buffer this binding has met; a shader that cares should check.
    pub fn isFlipped(self: MetalTexture) bool {
        return CVMetalTextureIsFlipped(self.handle) != 0;
    }
};

test "a pixel buffer drawn by the CPU, read back through a Metal texture" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();
    const device = metal.createSystemDefaultDevice() orelse return error.SkipZigTest;
    defer device.object.release();

    const buffer = try PixelBuffer.init(.{ .width = 16, .height = 8 });
    defer buffer.deinit();
    {
        const locked = try buffer.lock(.{});
        defer locked.unlock();
        for (0..8) |y| {
            const r = locked.row(y);
            for (0..16) |x| @memcpy(r[x * 4 ..][0..4], &[4]u8{ 10, 20, 30, 255 });
        }
    }

    const cache = try MetalTextureCache.init(device);
    defer cache.deinit();
    const wrapped = try cache.texture(buffer, .{});
    defer wrapped.deinit();
    const tex = wrapped.texture();
    try std.testing.expectEqual(@as(objc.UInteger, 16), tex.width());
    try std.testing.expectEqual(@as(objc.UInteger, 8), tex.height());
    try std.testing.expectEqual(metal.PixelFormat.bgra8_unorm, tex.pixelFormat());

    // The texture reads the buffer's bytes: nothing was copied or uploaded.
    var pixel: [4]u8 = undefined;
    tex.getBytesBytesPerRowFromRegionMipmapLevel(&pixel, 16 * 4, .{
        .origin = .{ .x = 5, .y = 3, .z = 0 },
        .size = .{ .width = 1, .height = 1, .depth = 1 },
    }, 0);
    try std.testing.expectEqualSlices(u8, &.{ 10, 20, 30, 255 }, &pixel);
    cache.flush();
}
