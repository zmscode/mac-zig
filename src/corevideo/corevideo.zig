//! [CoreVideo](https://developer.apple.com/documentation/corevideo):
//! pixel buffers, Metal textures over them, and the display link --
//! reached as `mac.corevideo`, under `-Dcorevideo`.
//!
//! ```zig
//! const buffer = try corevideo.PixelBuffer.init(.{ .width = 1280, .height = 720 });
//! defer buffer.deinit();
//!
//! const cache = try corevideo.MetalTextureCache.init(device);   // under -Dmetal
//! defer cache.deinit();
//! const texture = try cache.texture(buffer, .{});
//! defer texture.deinit();
//! encoder.setFragmentTextureAtIndex(texture.texture(), 0);
//! ```
//!
//! A pixel buffer is the form video takes on this platform: what a camera,
//! a decoder or ScreenCaptureKit hands out, and what an encoder takes. The
//! ones here sit on an IOSurface (`PixelBuffer.surface`), which is what
//! lets the texture cache give the GPU the same memory with no copy.
//!
//! The sample buffers those frames arrive in are CoreMedia's, in
//! `mac.coremedia`.

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const iosurface = @import("../iosurface/iosurface.zig");

const Error = errors.Error;

/// True when the package was built with `-Dcorevideo` (the default).
pub const enabled = true;

const pixel_buffer = @import("pixel_buffer.zig");
const display_link = @import("display_link.zig");

pub const PixelBuffer = pixel_buffer.PixelBuffer;
pub const Locked = pixel_buffer.Locked;
pub const Plane = pixel_buffer.Plane;
pub const LockOptions = pixel_buffer.LockOptions;
/// The same four-character codes IOSurface uses.
pub const PixelFormat = iosurface.PixelFormat;

pub const DisplayLink = display_link.DisplayLink;
pub const Tick = display_link.Tick;
pub const TimeStamp = display_link.TimeStamp;

const metal_enabled = @import("mac_build_options").metal;
const metal_texture_cache = if (metal_enabled) @import("metal_texture_cache.zig") else struct {};

/// Metal textures over pixel buffers. Under `-Dmetal`.
pub const MetalTextureCache = if (metal_enabled) metal_texture_cache.MetalTextureCache else void;
/// A texture from `MetalTextureCache`. Under `-Dmetal`.
pub const MetalTexture = if (metal_enabled) metal_texture_cache.MetalTexture else void;

/// Ticks per second of the host clock -- `mach_absolute_time` --
/// which every CoreVideo and CoreMedia host time counts in.
pub fn hostClockFrequency() f64 {
    return raw.CVGetHostClockFrequency();
}

/// Turns a `CVReturn` into an error union: `error.IllegalArgument` for
/// the argument and pixel-format complaints, `error.Failed` for the rest.
pub fn check(code: raw.CVReturn) Error!void {
    return switch (code) {
        raw.kCVReturnSuccess => {},
        raw.kCVReturnInvalidArgument,
        raw.kCVReturnInvalidPixelFormat,
        raw.kCVReturnInvalidSize,
        raw.kCVReturnInvalidPixelBufferAttributes,
        raw.kCVReturnPixelBufferNotMetalCompatible,
        => Error.IllegalArgument,
        else => Error.Failed,
    };
}

test {
    _ = pixel_buffer;
    _ = display_link;
    _ = metal_texture_cache;
}
