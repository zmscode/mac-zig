//! Images, and the pixel-layout word that describes them.
//!
//! ## The bitmap info word
//!
//! `CGBitmapInfo` is the single most error-prone value in CoreGraphics. In
//! C it is a `uint32_t` holding four unrelated fields, and it is built by
//! or-ing constants from three different enums together:
//!
//! ```c
//! kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little
//! ```
//!
//! Get it wrong and `CGBitmapContextCreate` returns NULL with no
//! explanation, or -- worse -- succeeds and gives you an image with the red
//! and blue channels swapped. Here it is a `packed struct`, so the fields
//! are named, they cannot collide, and the combination that a context
//! actually supports is available as a constant:
//!
//! ```zig
//! const info: BitmapInfo = .bgra8888;  // what a Mac bitmap context wants
//! ```
//!
//! ## Which combinations work
//!
//! A bitmap context accepts far fewer layouts than the type suggests. For
//! 8 bits per component in an RGB space, the supported ones are
//! `premultiplied_first`, `premultiplied_last`, `none_skip_first` and
//! `none_skip_last` -- notably **not** `.last` or `.first`, the
//! non-premultiplied forms. `BitmapInfo.bgra8888` and `.rgba8888` are both
//! supported; `.bgra8888` is the native order and the faster of the two.

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const cf = @import("../cf.zig");
const geometry = @import("geometry.zig");
const color = @import("color.zig");

const Error = errors.Error;
const Float = geometry.Float;
const Size = geometry.Size;
const Rect = geometry.Rect;
const ColorSpace = color.ColorSpace;
const RenderingIntent = color.RenderingIntent;

/// Where alpha sits in a pixel, and whether the colour components have
/// already been multiplied by it.
///
/// "Premultiplied" means each colour component is stored already scaled by
/// alpha. It is what every context draws into, because compositing is then
/// a multiply-add instead of a divide.
pub const AlphaInfo = enum(u5) {
    /// No alpha channel at all.
    none = 0,
    /// Alpha is the last component, colours premultiplied. RGBA.
    premultiplied_last = 1,
    /// Alpha is the first component, colours premultiplied. ARGB.
    premultiplied_first = 2,
    /// Alpha last, colours *not* premultiplied. Images only -- a bitmap
    /// context will refuse this.
    last = 3,
    /// Alpha first, not premultiplied. Images only.
    first = 4,
    /// A padding byte where alpha would be, at the end. XRGB read as RGBX.
    none_skip_last = 5,
    /// A padding byte where alpha would be, at the start.
    none_skip_first = 6,
    /// A mask: alpha and nothing else.
    alpha_only = 7,
    _,
};

/// Whether components are integers or floats.
pub const ComponentKind = enum(u4) {
    integer = 0,
    /// 16- or 32-bit floating point components, for high dynamic range.
    float = 1,
    _,
};

pub const ByteOrder = enum(u3) {
    /// The platform's own order.
    default = 0,
    little_16 = 1,
    little_32 = 2,
    big_16 = 3,
    big_32 = 4,
    _,
};

/// How components are packed into a pixel. `.standard` means one component
/// per `bits_per_component`, which is nearly always what is wanted; the
/// others are the packed video formats.
pub const PixelPacking = enum(u4) {
    standard = 0,
    rgb555 = 1,
    rgb565 = 2,
    rgb101010 = 3,
    rgb_cif10 = 4,
    _,
};

/// `CGBitmapInfo`, with its four fields separated.
pub const BitmapInfo = packed struct(u32) {
    alpha: AlphaInfo = .none,
    _reserved0: u3 = 0,
    component: ComponentKind = .integer,
    byte_order: ByteOrder = .default,
    _reserved1: u1 = 0,
    packing: PixelPacking = .standard,
    _reserved2: u12 = 0,

    /// 8 bits per component, alpha first, premultiplied, little-endian --
    /// which read a byte at a time is B, G, R, A. This is the native layout
    /// on Apple silicon and Intel alike, and the fastest thing to draw
    /// into.
    pub const bgra8888: BitmapInfo = .{
        .alpha = .premultiplied_first,
        .byte_order = .little_32,
    };

    /// 8 bits per component, alpha last, premultiplied, in memory order --
    /// R, G, B, A. What most file formats and GPU APIs expect, so this is
    /// the one to use when the bytes are going somewhere else.
    pub const rgba8888: BitmapInfo = .{
        .alpha = .premultiplied_last,
        .byte_order = .default,
    };

    /// 8 bits per component, no alpha, with a padding byte first. Use with
    /// an RGB colour space when transparency is not wanted.
    pub const xrgb8888: BitmapInfo = .{
        .alpha = .none_skip_first,
        .byte_order = .little_32,
    };

    /// A single 8-bit channel. Use with a grayscale colour space, or with
    /// `alpha_only` for a mask.
    pub const gray8: BitmapInfo = .{ .alpha = .none };

    /// An alpha-only mask.
    pub const mask8: BitmapInfo = .{ .alpha = .alpha_only };

    pub inline fn toRaw(self: BitmapInfo) raw.CGBitmapInfo {
        return @backingInt(self);
    }

    pub inline fn fromRaw(value: raw.CGBitmapInfo) BitmapInfo {
        return @fromBackingInt(value);
    }

    /// True for the layouts a bitmap context will accept at 8 bits per
    /// component in a three-component colour space. `Context.initBitmap`
    /// checks this so that a bad layout is an error here rather than a
    /// null return from CoreGraphics with nothing said about why.
    pub fn isDrawable(self: BitmapInfo) bool {
        return switch (self.alpha) {
            .premultiplied_first,
            .premultiplied_last,
            .none_skip_first,
            .none_skip_last,
            .none,
            .alpha_only,
            => true,
            else => false,
        };
    }
};

/// How pixels are resampled when an image is drawn at a size other than its
/// own.
pub const InterpolationQuality = enum(i32) {
    default = 0,
    /// Nearest neighbour. What pixel art wants.
    none = 1,
    low = 2,
    high = 3,
    medium = 4,
    _,
};

/// A source of bytes. Images are built on these rather than on raw
/// pointers, so that the image can outlive the call that made it.
pub const DataProvider = struct {
    handle: *raw.struct_CGDataProvider,

    /// Copies `bytes`. The provider owns the copy, so the caller's buffer
    /// can go away immediately.
    pub fn initCopy(bytes: []const u8) Error!DataProvider {
        const data = try cf.Data.init(bytes);
        defer data.deinit();
        return initData(data);
    }

    /// Wraps a `cf.Data`, retaining it. No copy.
    pub fn initData(data: cf.Data) Error!DataProvider {
        const created = raw.CGDataProviderCreateWithCFData(data.toRaw());
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// Wraps `bytes` **without copying and without taking ownership**. The
    /// buffer must stay alive and unmoved for as long as this provider or
    /// any image built on it exists. When in doubt use `initCopy`.
    pub fn initBorrowed(bytes: []const u8) Error!DataProvider {
        const created = raw.CGDataProviderCreateWithData(
            null,
            bytes.ptr,
            bytes.len,
            null,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// Reads a file lazily -- the bytes are mapped, not loaded, so this is
    /// cheap even for a large image.
    pub fn initFile(path: [:0]const u8) Error!DataProvider {
        const created = raw.CGDataProviderCreateWithFilename(path.ptr);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: DataProvider) void {
        raw.CGDataProviderRelease(self.handle);
    }

    pub fn retain(self: DataProvider) DataProvider {
        return .{ .handle = raw.CGDataProviderRetain(self.handle).? };
    }

    pub fn fromRaw(value: raw.CGDataProviderRef) ?DataProvider {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: DataProvider) raw.CGDataProviderRef {
        return self.handle;
    }

    /// All of the bytes, as a `cf.Data` the caller owns.
    pub fn copyData(self: DataProvider) Error!cf.Data {
        const copied = raw.CGDataProviderCopyData(self.handle);
        return .{ .handle = try errors.checkPtr(copied) };
    }
};

/// An immutable bitmap. Images are reference counted and freely shared;
/// drawing one does not consume it.
pub const Image = struct {
    handle: *raw.struct_CGImage,

    pub const Options = struct {
        width: usize,
        height: usize,
        /// Bits per *component*, not per pixel: 8 for the usual byte-per
        /// channel layouts.
        bits_per_component: usize = 8,
        /// Bits per pixel, which for a four-channel 8-bit image is 32.
        bits_per_pixel: usize = 32,
        /// Bytes per row. Rows are usually padded, so this is not always
        /// `width * bits_per_pixel / 8`.
        bytes_per_row: usize,
        space: ColorSpace,
        bitmap_info: BitmapInfo = .rgba8888,
        provider: DataProvider,
        /// Whether CoreGraphics may smooth this image when it is scaled up.
        interpolate: bool = true,
        intent: RenderingIntent = .default,
    };

    /// An image over pixels a `DataProvider` supplies.
    pub fn init(options: Options) Error!Image {
        const created = raw.CGImageCreate(
            options.width,
            options.height,
            options.bits_per_component,
            options.bits_per_pixel,
            options.bytes_per_row,
            options.space.toRaw(),
            options.bitmap_info.toRaw(),
            options.provider.toRaw(),
            null,
            options.interpolate,
            @backingInt(options.intent),
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// Decodes a PNG. CoreGraphics can do this without ImageIO; for any
    /// other format, use `cg.imageio`.
    pub fn initPng(provider: DataProvider, intent: RenderingIntent) Error!Image {
        const created = raw.CGImageCreateWithPNGDataProvider(
            provider.toRaw(),
            null,
            true,
            @backingInt(intent),
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// Decodes a JPEG.
    pub fn initJpeg(provider: DataProvider, intent: RenderingIntent) Error!Image {
        const created = raw.CGImageCreateWithJPEGDataProvider(
            provider.toRaw(),
            null,
            true,
            @backingInt(intent),
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Image) void {
        raw.CGImageRelease(self.handle);
    }

    pub fn retain(self: Image) Image {
        return .{ .handle = raw.CGImageRetain(self.handle).? };
    }

    pub fn fromRaw(value: raw.CGImageRef) ?Image {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: Image) raw.CGImageRef {
        return self.handle;
    }

    // -- what it is -----------------------------------------------------

    pub fn width(self: Image) usize {
        return raw.CGImageGetWidth(self.handle);
    }

    pub fn height(self: Image) usize {
        return raw.CGImageGetHeight(self.handle);
    }

    /// The size in pixels, as a `Size` for the rectangle to draw it into.
    pub fn size(self: Image) Size {
        return .{
            .width = @floatFromInt(self.width()),
            .height = @floatFromInt(self.height()),
        };
    }

    /// A rectangle at the origin the size of this image -- what
    /// `Context.drawImage` wants to draw it unscaled.
    pub fn bounds(self: Image) Rect {
        return .fromSize(self.size());
    }

    pub fn bitsPerComponent(self: Image) usize {
        return raw.CGImageGetBitsPerComponent(self.handle);
    }

    pub fn bitsPerPixel(self: Image) usize {
        return raw.CGImageGetBitsPerPixel(self.handle);
    }

    pub fn bytesPerRow(self: Image) usize {
        return raw.CGImageGetBytesPerRow(self.handle);
    }

    pub fn bitmapInfo(self: Image) BitmapInfo {
        return .fromRaw(raw.CGImageGetBitmapInfo(self.handle));
    }

    pub fn alphaInfo(self: Image) AlphaInfo {
        return @fromBackingInt(@intCast(raw.CGImageGetAlphaInfo(self.handle)));
    }

    /// The colour space, borrowed -- do not `deinit` it. Null for a mask,
    /// which has no colour.
    pub fn space(self: Image) ?ColorSpace {
        return ColorSpace.fromRaw(raw.CGImageGetColorSpace(self.handle));
    }

    pub fn isMask(self: Image) bool {
        return raw.CGImageIsMask(self.handle);
    }

    /// The pixel bytes, as a `cf.Data` the caller owns. This goes through
    /// the image's data provider, so for an image that came out of a
    /// bitmap context it is a copy, not the context's live buffer.
    pub fn copyData(self: Image) Error!cf.Data {
        const provider = DataProvider.fromRaw(raw.CGImageGetDataProvider(self.handle)) orelse
            return Error.Failed;
        return provider.copyData();
    }

    // -- derived images -------------------------------------------------

    /// A sub-rectangle, as a new image. CoreGraphics shares the pixels
    /// rather than copying them, so this is cheap.
    ///
    /// `area` is in pixels with the origin at the **top left**, unlike the
    /// rest of CoreGraphics, and it is rounded outwards to whole pixels.
    /// A rectangle outside the image gives `error.Failed`.
    pub fn cropped(self: Image, area: Rect) Error!Image {
        const created = raw.CGImageCreateWithImageInRect(self.handle, area.toRaw());
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// The same pixels reinterpreted in another colour space.
    pub fn convertedTo(self: Image, to: ColorSpace) Error!Image {
        const created = raw.CGImageCreateCopyWithColorSpace(self.handle, to.toRaw());
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// This image masked by another. `mask` must be an image made with an
    /// `alpha_only` layout, or an image whose colour space is grayscale.
    pub fn masked(self: Image, mask: Image) Error!Image {
        const created = raw.CGImageCreateWithMask(self.handle, mask.toRaw());
        return .{ .handle = try errors.checkPtr(created) };
    }
};

test "bitmap info packs into the word CoreGraphics expects" {
    // kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little
    const expected: u32 = @as(u32, raw.kCGImageAlphaPremultipliedFirst) |
        @as(u32, raw.kCGBitmapByteOrder32Little);
    try std.testing.expectEqual(expected, BitmapInfo.bgra8888.toRaw());

    try std.testing.expectEqual(
        @as(u32, raw.kCGImageAlphaPremultipliedLast),
        BitmapInfo.rgba8888.toRaw(),
    );
    try std.testing.expectEqual(@as(u32, raw.kCGImageAlphaOnly), BitmapInfo.mask8.toRaw());
}

test "bitmap info round-trips through the raw word" {
    const original: BitmapInfo = .{
        .alpha = .none_skip_last,
        .component = .float,
        .byte_order = .big_32,
        .packing = .rgb565,
    };
    const round_tripped = BitmapInfo.fromRaw(original.toRaw());
    try std.testing.expectEqual(original, round_tripped);
}

test "the non-premultiplied layouts are not drawable" {
    try std.testing.expect(BitmapInfo.bgra8888.isDrawable());
    try std.testing.expect(!(BitmapInfo{ .alpha = .last }).isDrawable());
    try std.testing.expect(!(BitmapInfo{ .alpha = .first }).isDrawable());
}

test "an image reports the layout it was built with" {
    const pixels: [16]u8 = @splat(0xFF);
    const provider = try DataProvider.initCopy(&pixels);
    defer provider.deinit();

    const space = try ColorSpace.deviceRgb();
    defer space.deinit();

    const image = try Image.init(.{
        .width = 2,
        .height = 2,
        .bytes_per_row = 8,
        .space = space,
        .bitmap_info = .rgba8888,
        .provider = provider,
    });
    defer image.deinit();

    try std.testing.expectEqual(@as(usize, 2), image.width());
    try std.testing.expectEqual(@as(usize, 2), image.height());
    try std.testing.expectEqual(@as(usize, 32), image.bitsPerPixel());
    try std.testing.expectEqual(AlphaInfo.premultiplied_last, image.alphaInfo());
    try std.testing.expect(image.bounds().eql(Rect.init(0, 0, 2, 2)));
}

test "cropping shares pixels and reports the smaller size" {
    const pixels: [64]u8 = @splat(0x80);
    const provider = try DataProvider.initCopy(&pixels);
    defer provider.deinit();

    const space = try ColorSpace.deviceRgb();
    defer space.deinit();

    const image = try Image.init(.{
        .width = 4,
        .height = 4,
        .bytes_per_row = 16,
        .space = space,
        .provider = provider,
    });
    defer image.deinit();

    const corner = try image.cropped(.init(0, 0, 2, 2));
    defer corner.deinit();
    try std.testing.expectEqual(@as(usize, 2), corner.width());
    try std.testing.expectEqual(@as(usize, 2), corner.height());
}
