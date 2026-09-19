//! Reading and writing image files, under `-Dimageio` (on by default).
//!
//! CoreGraphics draws; it does not encode. It can decode PNG and JPEG --
//! `Image.initPng` and `Image.initJpeg` -- but it cannot write either, so
//! getting a drawing out of a bitmap context and into a file goes through
//! ImageIO, a separate framework that ships with the same systems.
//!
//! ```zig
//! const ctx = try cg.Context.initBitmap(.{ .width = 400, .height = 300 });
//! defer ctx.deinit();
//! // ... draw ...
//! try cg.imageio.writeContext(ctx, "out.png", .png, .{});
//! ```
//!
//! The formats are named rather than spelled as the uniform type
//! identifier strings ImageIO actually takes, so a typo is a compile error
//! instead of a null destination.

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const cf = @import("../cf.zig");
const image_mod = @import("image.zig");
const context_mod = @import("context.zig");

const Error = errors.Error;
const Image = image_mod.Image;
const Context = context_mod.Context;

/// True when the package was built with `-Dimageio` (the default). The
/// namespace still exists when it was not, with this set to false and
/// nothing else in it.
pub const enabled = true;

/// The formats this module names. ImageIO knows more -- the full list is
/// `CGImageDestinationCopyTypeIdentifiers` -- and `Format.other` passes a
/// uniform type identifier through for those.
pub const Format = union(enum) {
    png,
    jpeg,
    tiff,
    gif,
    bmp,
    /// HEIF with HEVC, the format an iPhone camera writes.
    heic,
    /// Any other uniform type identifier, such as `"public.jpeg-2000"`.
    other: [:0]const u8,

    fn identifier(self: Format) [:0]const u8 {
        return switch (self) {
            .png => "public.png",
            .jpeg => "public.jpeg",
            .tiff => "public.tiff",
            .gif => "com.compuserve.gif",
            .bmp => "com.microsoft.bmp",
            .heic => "public.heic",
            .other => |uti| uti,
        };
    }
};

pub const EncodeOptions = struct {
    /// 0 to 1, for the formats that lose detail -- JPEG and HEIC. Ignored
    /// by PNG and the other lossless formats.
    quality: ?f64 = null,
};

/// Encodes `img` and writes it to `path`, replacing whatever was there.
pub fn writeImage(img: Image, path: []const u8, format: Format, options: EncodeOptions) Error!void {
    const url = try cf.Url.initFilePath(path);
    defer url.deinit();

    const type_name = try cf.String.init(format.identifier());
    defer type_name.deinit();

    const destination = raw.CGImageDestinationCreateWithURL(
        url.toRaw(),
        type_name.toRaw(),
        1,
        null,
    );
    const checked = try errors.checkPtr(destination);
    defer raw.CFRelease(checked);

    try addAndFinalize(checked, img, options);
}

/// Encodes `img` into memory. The caller owns the returned `cf.Data`.
pub fn encodeImage(img: Image, format: Format, options: EncodeOptions) Error!cf.Data {
    const buffer = try cf.MutableData.init(0);
    errdefer buffer.deinit();

    const type_name = try cf.String.init(format.identifier());
    defer type_name.deinit();

    const destination = raw.CGImageDestinationCreateWithData(
        buffer.toRaw(),
        type_name.toRaw(),
        1,
        null,
    );
    const checked = try errors.checkPtr(destination);
    defer raw.CFRelease(checked);

    try addAndFinalize(checked, img, options);

    // The mutable buffer and the immutable view are the same object, so
    // this hands ownership over rather than copying.
    return .{ .handle = buffer.handle };
}

/// Snapshots a bitmap context and writes it out, which is the two calls
/// this is nearly always a pair of.
pub fn writeContext(
    ctx: Context,
    path: []const u8,
    format: Format,
    options: EncodeOptions,
) Error!void {
    const snapshot = try ctx.createImage();
    defer snapshot.deinit();
    try writeImage(snapshot, path, format, options);
}

fn addAndFinalize(
    destination: *raw.struct_CGImageDestination,
    img: Image,
    options: EncodeOptions,
) Error!void {
    if (options.quality) |quality| {
        const boxed = try cf.Number.initFloat(quality);
        defer boxed.deinit();

        const properties = try cf.Dictionary.initFixed(.{
            .{
                .key = cf.Type{ .handle = raw.kCGImageDestinationLossyCompressionQuality.? },
                .value = boxed.asType(),
            },
        });
        defer properties.deinit();

        raw.CGImageDestinationAddImage(destination, img.toRaw(), properties.toRaw());
    } else {
        raw.CGImageDestinationAddImage(destination, img.toRaw(), null);
    }

    // Nothing is written until this, and it is the only call that reports
    // whether the encode worked.
    try errors.check(raw.CGImageDestinationFinalize(destination));
}

/// Decodes the first image of a file, whatever format it is in.
pub fn readImage(path: []const u8) Error!Image {
    const source = try Source.initFile(path);
    defer source.deinit();
    return source.imageAt(0);
}

/// Decodes the first image of an encoded buffer.
pub fn decodeImage(data: cf.Data) Error!Image {
    const source = try Source.initData(data);
    defer source.deinit();
    return source.imageAt(0);
}

/// A decoder. Worth using directly for a file that holds more than one
/// image -- an animated GIF, a multi-page TIFF, an icon set -- or to read
/// the dimensions without decoding the pixels.
pub const Source = struct {
    handle: *raw.struct_CGImageSource,

    pub fn initFile(path: []const u8) Error!Source {
        const url = try cf.Url.initFilePath(path);
        defer url.deinit();

        const created = raw.CGImageSourceCreateWithURL(url.toRaw(), null);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn initData(data: cf.Data) Error!Source {
        const created = raw.CGImageSourceCreateWithData(data.toRaw(), null);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Source) void {
        raw.CFRelease(self.handle);
    }

    pub inline fn toRaw(self: Source) raw.CGImageSourceRef {
        return self.handle;
    }

    /// How many images the file holds. Indices below are 0-based, unlike
    /// PDF page numbers.
    pub fn count(self: Source) usize {
        return raw.CGImageSourceGetCount(self.handle);
    }

    /// The uniform type identifier of the format that was recognised,
    /// borrowed -- `"public.png"` and so on.
    pub fn format(self: Source) ?cf.String {
        return cf.String.fromRaw(raw.CGImageSourceGetType(self.handle));
    }

    /// Decodes image `index`. The caller owns the result.
    pub fn imageAt(self: Source, index: usize) Error!Image {
        if (index >= self.count()) return Error.RangeCheck;
        const created = raw.CGImageSourceCreateImageAtIndex(self.handle, index, null);
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// The metadata for image `index`, as a dictionary the caller owns.
    /// `size` reads the two entries that are almost always what is wanted.
    pub fn propertiesAt(self: Source, index: usize) Error!cf.Dictionary {
        if (index >= self.count()) return Error.RangeCheck;
        const copied = raw.CGImageSourceCopyPropertiesAtIndex(self.handle, index, null);
        return .{ .handle = try errors.checkPtr(copied) };
    }

    /// The pixel dimensions of image `index`, read from the header without
    /// decoding the image.
    pub fn sizeAt(self: Source, index: usize) Error!struct { width: usize, height: usize } {
        const properties = try self.propertiesAt(index);
        defer properties.deinit();

        const w = properties.getInt(raw.kCGImagePropertyPixelWidth) orelse return Error.Failed;
        const h = properties.getInt(raw.kCGImagePropertyPixelHeight) orelse return Error.Failed;
        return .{ .width = @intCast(w), .height = @intCast(h) };
    }
};

test "a drawing survives a round trip through PNG" {
    const ctx = try Context.initBitmap(.{ .width = 8, .height = 8 });
    defer ctx.deinit();

    ctx.setFillColor(.rgb(1, 0, 0));
    ctx.fillRect(ctx.bitmapBounds());

    const snapshot = try ctx.createImage();
    defer snapshot.deinit();

    const encoded = try encodeImage(snapshot, .png, .{});
    defer encoded.deinit();

    // A PNG starts with a fixed eight-byte signature.
    try std.testing.expectEqualSlices(
        u8,
        &.{ 0x89, 'P', 'N', 'G', 0x0D, 0x0A, 0x1A, 0x0A },
        encoded.bytes()[0..8],
    );

    const decoded = try decodeImage(encoded);
    defer decoded.deinit();
    try std.testing.expectEqual(@as(usize, 8), decoded.width());
    try std.testing.expectEqual(@as(usize, 8), decoded.height());
}

test "a source reads dimensions without decoding" {
    const ctx = try Context.initBitmap(.{ .width = 12, .height = 5 });
    defer ctx.deinit();
    ctx.setFillColor(.rgb(0, 0, 1));
    ctx.fillRect(ctx.bitmapBounds());

    const snapshot = try ctx.createImage();
    defer snapshot.deinit();

    const encoded = try encodeImage(snapshot, .png, .{});
    defer encoded.deinit();

    const source = try Source.initData(encoded);
    defer source.deinit();

    try std.testing.expectEqual(@as(usize, 1), source.count());
    const dimensions = try source.sizeAt(0);
    try std.testing.expectEqual(@as(usize, 12), dimensions.width);
    try std.testing.expectEqual(@as(usize, 5), dimensions.height);

    const identifier = try source.format().?.toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(identifier);
    try std.testing.expectEqualStrings("public.png", identifier);

    try std.testing.expectError(Error.RangeCheck, source.imageAt(1));
}

test "quality is honoured by the formats that lose detail" {
    const ctx = try Context.initBitmap(.{ .width = 64, .height = 64 });
    defer ctx.deinit();

    // Something with enough detail that quality actually changes the size.
    var i: usize = 0;
    while (i < 64) : (i += 2) {
        const f: f64 = @floatFromInt(i);
        ctx.setFillColor(.rgb(f / 64, 1 - f / 64, 0.5));
        ctx.fillRect(.init(f, 0, 2, 64));
    }

    const snapshot = try ctx.createImage();
    defer snapshot.deinit();

    const low = try encodeImage(snapshot, .jpeg, .{ .quality = 0.1 });
    defer low.deinit();
    const high = try encodeImage(snapshot, .jpeg, .{ .quality = 1.0 });
    defer high.deinit();

    try std.testing.expect(low.bytes().len < high.bytes().len);
}

test "writing to a file produces one that reads back" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    // `tmpDir` puts its directory at a known place relative to the cwd,
    // and CoreFoundation resolves a relative path against the cwd too.
    const file_path = try std.fmt.allocPrint(
        std.testing.allocator,
        ".zig-cache/tmp/{s}/out.png",
        .{tmp.sub_path},
    );
    defer std.testing.allocator.free(file_path);

    const ctx = try Context.initBitmap(.{ .width = 6, .height = 3 });
    defer ctx.deinit();
    ctx.setFillColor(.rgb(0, 1, 0));
    ctx.fillRect(ctx.bitmapBounds());

    try writeContext(ctx, file_path, .png, .{});

    const loaded = try readImage(file_path);
    defer loaded.deinit();
    try std.testing.expectEqual(@as(usize, 6), loaded.width());
    try std.testing.expectEqual(@as(usize, 3), loaded.height());
}
