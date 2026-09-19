//! The drawing target: a bitmap in memory, or a PDF being written.
//!
//! ## The y axis points up
//!
//! A CoreGraphics context puts the origin at the **bottom left** and the y
//! axis points up, like graph paper. AppKit views, layout maths and every
//! image file format put the origin at the top left with y pointing down.
//!
//! Left alone, this costs nothing: shapes land where you put them, and
//! images and text drawn into an unflipped context come out the right way
//! up, including once the context is written to a PNG.
//!
//! `flipVertically` switches the context to top-left, y-down coordinates,
//! which is worth doing when the numbers are coming from a layout that
//! already thinks that way:
//!
//! ```zig
//! const ctx = try cg.Context.initBitmap(.{ .width = 400, .height = 300 });
//! defer ctx.deinit();
//! ctx.flipVertically(300);   // now y grows downwards, origin top left
//! ```
//!
//! It is a transform like any other, so it can be saved and restored. The
//! catch is that it flips *everything*, images and glyphs included, so in
//! a flipped context:
//!
//! - draw images with `drawImageUpright` rather than `drawImage`;
//! - set `setTextMatrix(.scaling(1, -1))` before drawing text.
//!
//! Both are one line, and neither is needed if the context is left
//! unflipped.
//!
//! ## Graphics state
//!
//! Colours, line width, the transform, the clip and the blend mode all live
//! in a stack of graphics states. `save` pushes a copy and `restore` pops
//! it, which pairs exactly with `defer`:
//!
//! ```zig
//! ctx.save();
//! defer ctx.restore();
//! ctx.clipToRect(.init(0, 0, 100, 100));
//! // ... the clip goes away at the end of the block ...
//! ```
//!
//! The one thing *not* in the graphics state is the current path, which is
//! why every drawing call that uses it also clears it.
//!
//! ## The current path
//!
//! `beginPath`, `moveTo`, `lineTo` and friends build a path inside the
//! context, and `fillPath`, `strokePath` and `drawPath` consume it --
//! consume, not read: after any of them the current path is empty. Drawing
//! the same shape twice means either building it twice or building a
//! `Path` once and calling `addPath` before each draw.

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const cf = @import("../cf.zig");
const geometry = @import("geometry.zig");
const color_mod = @import("color.zig");
const image_mod = @import("image.zig");
const path_mod = @import("path.zig");
const pdf_mod = @import("pdf.zig");

const Error = errors.Error;
const Float = geometry.Float;
const Point = geometry.Point;
const Size = geometry.Size;
const Rect = geometry.Rect;
const AffineTransform = geometry.AffineTransform;
const ColorSpace = color_mod.ColorSpace;
const Color = color_mod.Color;
const Rgba = color_mod.Rgba;
const Gray = color_mod.Gray;
const Cmyk = color_mod.Cmyk;
const BitmapInfo = image_mod.BitmapInfo;
const Image = image_mod.Image;
const InterpolationQuality = image_mod.InterpolationQuality;
const Path = path_mod.Path;
const LineCap = path_mod.LineCap;
const LineJoin = path_mod.LineJoin;
const DrawingMode = path_mod.DrawingMode;

/// How source and destination pixels are combined. `.normal` is ordinary
/// source-over compositing; the first sixteen are the Photoshop-style
/// separable modes and the rest are the Porter-Duff operators.
pub const BlendMode = enum(i32) {
    normal = 0,
    multiply = 1,
    screen = 2,
    overlay = 3,
    darken = 4,
    lighten = 5,
    color_dodge = 6,
    color_burn = 7,
    soft_light = 8,
    hard_light = 9,
    difference = 10,
    exclusion = 11,
    hue = 12,
    saturation = 13,
    color = 14,
    luminosity = 15,

    /// Erases to transparent, ignoring the fill colour. `clearRect` is
    /// usually what is wanted instead.
    clear = 16,
    /// Replaces rather than composites, alpha and all. This is how to draw
    /// a translucent thing *over* a background without the background
    /// showing through.
    copy = 17,
    source_in = 18,
    source_out = 19,
    source_atop = 20,
    destination_over = 21,
    destination_in = 22,
    destination_out = 23,
    destination_atop = 24,
    xor = 25,
    plus_darker = 26,
    plus_lighter = 27,
    _,
};

/// What `showGlyphs` does with the glyphs it is given.
pub const TextDrawingMode = enum(i32) {
    fill = 0,
    stroke = 1,
    fill_stroke = 2,
    /// Draws nothing, which is how text is measured or turned into a clip.
    invisible = 3,
    fill_clip = 4,
    stroke_clip = 5,
    fill_stroke_clip = 6,
    clip = 7,
    _,
};

/// Which parts of a gradient's axis are painted beyond its ends.
pub const GradientDrawingOptions = packed struct(u32) {
    /// Extends the first colour backwards past the start point.
    before_start: bool = false,
    /// Extends the last colour forwards past the end point.
    after_end: bool = false,
    _reserved: u30 = 0,

    /// Paint the whole axis, which is nearly always what a background
    /// gradient wants.
    pub const both: GradientDrawingOptions = .{ .before_start = true, .after_end = true };
};

/// A shadow. `blur` is a radius in the *base* coordinate space, so it does
/// not scale with the current transform.
pub const Shadow = struct {
    offset: Size,
    blur: Float,
    /// null uses CoreGraphics' default: black at one third alpha.
    color: ?Color = null,
};

pub const Context = struct {
    handle: *raw.struct_CGContext,

    pub const BitmapOptions = struct {
        width: usize,
        height: usize,

        /// null creates an sRGB space for the duration of this call and
        /// releases it afterwards -- the context keeps its own reference.
        space: ?ColorSpace = null,

        /// Bits per component. 8 is the ordinary case; 16 and 32 need a
        /// matching `bitmap_info.component`.
        bits_per_component: usize = 8,

        /// 0 lets CoreGraphics choose, which also lets it pad rows for
        /// alignment. Required when `pixels` is supplied.
        bytes_per_row: usize = 0,

        /// The default is the layout a Mac composites fastest: alpha first,
        /// premultiplied, 32-bit little-endian, which read byte by byte is
        /// B, G, R, A. If the bytes are going to be read directly rather
        /// than handed back to CoreGraphics, `.rgba8888` is the one that
        /// means what its name says.
        bitmap_info: BitmapInfo = .bgra8888,

        /// null lets CoreGraphics allocate and own the pixels, which is
        /// almost always right. A supplied buffer must outlive the context
        /// and must be at least `bytes_per_row * height` long.
        pixels: ?[]u8 = null,
    };

    /// A context that draws into memory.
    ///
    /// Zero width or height, or a layout a bitmap context does not support,
    /// is rejected here -- CoreGraphics would return NULL and say nothing.
    pub fn initBitmap(options: BitmapOptions) Error!Context {
        if (options.width == 0 or options.height == 0) return Error.IllegalArgument;
        if (!options.bitmap_info.isDrawable()) return Error.IllegalArgument;

        const space = options.space orelse try ColorSpace.named(.srgb);
        defer if (options.space == null) space.deinit();

        if (options.pixels) |buffer| {
            if (options.bytes_per_row == 0) return Error.IllegalArgument;
            if (buffer.len < options.bytes_per_row * options.height) return Error.RangeCheck;
        }

        const created = raw.CGBitmapContextCreate(
            if (options.pixels) |buffer| buffer.ptr else null,
            options.width,
            options.height,
            options.bits_per_component,
            options.bytes_per_row,
            space.toRaw(),
            options.bitmap_info.toRaw(),
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub const PdfOptions = struct {
        /// The page size in points, 72 to the inch. A4 is 595x842 and US
        /// Letter is 612x792. null means 612x792.
        media_box: ?Rect = null,
        /// Written into the PDF's metadata.
        title: ?[]const u8 = null,
        author: ?[]const u8 = null,
        creator: ?[]const u8 = null,
    };

    /// A context that writes a PDF to a file.
    ///
    /// Unlike a bitmap context this one is not finished when it is
    /// released: call `closePdf` to flush the trailer, or the file is
    /// truncated. `deinit` after that.
    pub fn initPdfFile(
        allocator: std.mem.Allocator,
        path: []const u8,
        options: PdfOptions,
    ) !Context {
        const url = try cf.Url.initFilePath(path);
        defer url.deinit();

        const info = try pdfInfoDictionary(allocator, options);
        defer if (info) |d| d.deinit();

        var media_box = (options.media_box orelse Rect.init(0, 0, 612, 792)).toRaw();
        const created = raw.CGPDFContextCreateWithURL(
            url.toRaw(),
            &media_box,
            if (info) |d| d.toRaw() else null,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// A context that writes a PDF into memory. The bytes are complete
    /// once `closePdf` has been called.
    pub fn initPdfData(
        allocator: std.mem.Allocator,
        into: cf.MutableData,
        options: PdfOptions,
    ) !Context {
        const consumer = raw.CGDataConsumerCreateWithCFData(into.toRaw());
        const checked_consumer = try errors.checkPtr(consumer);
        defer raw.CGDataConsumerRelease(checked_consumer);

        const info = try pdfInfoDictionary(allocator, options);
        defer if (info) |d| d.deinit();

        var media_box = (options.media_box orelse Rect.init(0, 0, 612, 792)).toRaw();
        const created = raw.CGPDFContextCreate(
            checked_consumer,
            &media_box,
            if (info) |d| d.toRaw() else null,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    fn pdfInfoDictionary(
        allocator: std.mem.Allocator,
        options: PdfOptions,
    ) !?cf.Dictionary {
        if (options.title == null and options.author == null and options.creator == null) {
            return null;
        }

        var pairs: std.ArrayList(cf.Dictionary.Pair) = .empty;
        defer pairs.deinit(allocator);
        // Values are retained by the dictionary, so the strings made here
        // are released once it exists.
        var strings: std.ArrayList(cf.String) = .empty;
        defer {
            for (strings.items) |s| s.deinit();
            strings.deinit(allocator);
        }

        inline for (.{
            .{ options.title, raw.kCGPDFContextTitle },
            .{ options.author, raw.kCGPDFContextAuthor },
            .{ options.creator, raw.kCGPDFContextCreator },
        }) |entry| {
            if (entry[0]) |text| {
                const value = try cf.String.init(text);
                try strings.append(allocator, value);
                try pairs.append(allocator, .{
                    .key = .{ .handle = entry[1].? },
                    .value = value.asType(),
                });
            }
        }

        return try cf.Dictionary.init(allocator, pairs.items);
    }

    pub fn deinit(self: Context) void {
        raw.CGContextRelease(self.handle);
    }

    pub fn retain(self: Context) Context {
        return .{ .handle = raw.CGContextRetain(self.handle).? };
    }

    pub fn fromRaw(value: raw.CGContextRef) ?Context {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: Context) raw.CGContextRef {
        return self.handle;
    }

    // -- graphics state -------------------------------------------------

    /// Pushes a copy of the current colours, line attributes, transform,
    /// clip and blend mode. Pair with `defer self.restore()`.
    pub fn save(self: Context) void {
        raw.CGContextSaveGState(self.handle);
    }

    /// Pops the state `save` pushed. Restoring more than was saved is
    /// undefined, so keep them paired with `defer`.
    pub fn restore(self: Context) void {
        raw.CGContextRestoreGState(self.handle);
    }

    // -- the coordinate system ------------------------------------------

    /// Flips the y axis so the origin is at the top left and y grows
    /// downwards, matching AppKit and most layout maths. `height` is the
    /// context's height in *user space* units.
    ///
    /// This is a transform, so it can be saved and restored -- and it
    /// applies to everything drawn after it, images and glyphs included.
    /// Use `drawImageUpright` and a `setTextMatrix(.scaling(1, -1))` to
    /// put those back the right way up.
    pub fn flipVertically(self: Context, height: Float) void {
        self.translate(0, height);
        self.scale(1, -1);
    }

    pub fn translate(self: Context, tx: Float, ty: Float) void {
        raw.CGContextTranslateCTM(self.handle, tx, ty);
    }

    pub fn scale(self: Context, sx: Float, sy: Float) void {
        raw.CGContextScaleCTM(self.handle, sx, sy);
    }

    /// Rotates by `angle` radians about the current origin,
    /// counter-clockwise in an unflipped context.
    pub fn rotate(self: Context, angle: Float) void {
        raw.CGContextRotateCTM(self.handle, angle);
    }

    pub fn concat(self: Context, matrix: AffineTransform) void {
        raw.CGContextConcatCTM(self.handle, matrix.toRaw());
    }

    /// The current transformation matrix.
    pub fn transform(self: Context) AffineTransform {
        return .fromRaw(raw.CGContextGetCTM(self.handle));
    }

    /// User space to device pixels -- on a Retina-backed context this is
    /// not the identity even before anything is drawn.
    pub fn userToDeviceTransform(self: Context) AffineTransform {
        return .fromRaw(raw.CGContextGetUserSpaceToDeviceSpaceTransform(self.handle));
    }

    pub fn convertPointToDeviceSpace(self: Context, point: Point) Point {
        return .fromRaw(raw.CGContextConvertPointToDeviceSpace(self.handle, point.toRaw()));
    }

    pub fn convertPointToUserSpace(self: Context, point: Point) Point {
        return .fromRaw(raw.CGContextConvertPointToUserSpace(self.handle, point.toRaw()));
    }

    pub fn convertRectToDeviceSpace(self: Context, area: Rect) Rect {
        return .fromRaw(raw.CGContextConvertRectToDeviceSpace(self.handle, area.toRaw()));
    }

    pub fn convertRectToUserSpace(self: Context, area: Rect) Rect {
        return .fromRaw(raw.CGContextConvertRectToUserSpace(self.handle, area.toRaw()));
    }

    // -- colour ---------------------------------------------------------

    /// The fill colour, in device RGB. Nothing is allocated.
    pub fn setFillColor(self: Context, value: Rgba) void {
        raw.CGContextSetRGBFillColor(self.handle, value.r, value.g, value.b, value.a);
    }

    pub fn setStrokeColor(self: Context, value: Rgba) void {
        raw.CGContextSetRGBStrokeColor(self.handle, value.r, value.g, value.b, value.a);
    }

    /// The fill colour as a `Color`, which is how to use a colour space
    /// other than device RGB.
    pub fn setFillColorRef(self: Context, value: Color) void {
        raw.CGContextSetFillColorWithColor(self.handle, value.toRaw());
    }

    pub fn setStrokeColorRef(self: Context, value: Color) void {
        raw.CGContextSetStrokeColorWithColor(self.handle, value.toRaw());
    }

    pub fn setFillGray(self: Context, value: Gray) void {
        raw.CGContextSetGrayFillColor(self.handle, value.level, value.a);
    }

    pub fn setStrokeGray(self: Context, value: Gray) void {
        raw.CGContextSetGrayStrokeColor(self.handle, value.level, value.a);
    }

    pub fn setFillCmyk(self: Context, value: Cmyk) void {
        raw.CGContextSetCMYKFillColor(self.handle, value.c, value.m, value.y, value.k, value.a);
    }

    pub fn setStrokeCmyk(self: Context, value: Cmyk) void {
        raw.CGContextSetCMYKStrokeColor(self.handle, value.c, value.m, value.y, value.k, value.a);
    }

    /// A multiplier applied to everything drawn afterwards, on top of each
    /// colour's own alpha.
    pub fn setAlpha(self: Context, alpha: Float) void {
        raw.CGContextSetAlpha(self.handle, alpha);
    }

    pub fn setBlendMode(self: Context, mode: BlendMode) void {
        raw.CGContextSetBlendMode(self.handle, @backingInt(mode));
    }

    // -- line attributes -------------------------------------------------

    pub fn setLineWidth(self: Context, width: Float) void {
        raw.CGContextSetLineWidth(self.handle, width);
    }

    pub fn setLineCap(self: Context, cap: LineCap) void {
        raw.CGContextSetLineCap(self.handle, @backingInt(cap));
    }

    pub fn setLineJoin(self: Context, join: LineJoin) void {
        raw.CGContextSetLineJoin(self.handle, @backingInt(join));
    }

    pub fn setMiterLimit(self: Context, limit: Float) void {
        raw.CGContextSetMiterLimit(self.handle, limit);
    }

    /// A dash pattern alternating on and off, starting with on. An empty
    /// `lengths` turns dashing off.
    pub fn setLineDash(self: Context, phase: Float, lengths: []const Float) void {
        if (lengths.len == 0) {
            raw.CGContextSetLineDash(self.handle, 0, null, 0);
            return;
        }
        raw.CGContextSetLineDash(self.handle, phase, lengths.ptr, lengths.len);
    }

    pub fn setShouldAntialias(self: Context, enabled: bool) void {
        raw.CGContextSetShouldAntialias(self.handle, enabled);
    }

    pub fn setInterpolationQuality(self: Context, quality: InterpolationQuality) void {
        raw.CGContextSetInterpolationQuality(self.handle, @backingInt(quality));
    }

    // -- shadows ---------------------------------------------------------

    pub fn setShadow(self: Context, shadow: Shadow) void {
        if (shadow.color) |c| {
            raw.CGContextSetShadowWithColor(
                self.handle,
                shadow.offset.toRaw(),
                shadow.blur,
                c.toRaw(),
            );
        } else {
            raw.CGContextSetShadow(self.handle, shadow.offset.toRaw(), shadow.blur);
        }
    }

    /// Turns the shadow off. Setting a shadow with a null colour is *not*
    /// the same thing -- that sets the default black shadow.
    pub fn clearShadow(self: Context) void {
        raw.CGContextSetShadowWithColor(self.handle, Size.zero.toRaw(), 0, null);
    }

    // -- the current path ------------------------------------------------

    pub fn beginPath(self: Context) void {
        raw.CGContextBeginPath(self.handle);
    }

    pub fn moveTo(self: Context, point: Point) void {
        raw.CGContextMoveToPoint(self.handle, point.x, point.y);
    }

    pub fn lineTo(self: Context, point: Point) void {
        raw.CGContextAddLineToPoint(self.handle, point.x, point.y);
    }

    pub fn quadCurveTo(self: Context, control: Point, end: Point) void {
        raw.CGContextAddQuadCurveToPoint(self.handle, control.x, control.y, end.x, end.y);
    }

    pub fn curveTo(self: Context, control1: Point, control2: Point, end: Point) void {
        raw.CGContextAddCurveToPoint(
            self.handle,
            control1.x,
            control1.y,
            control2.x,
            control2.y,
            end.x,
            end.y,
        );
    }

    pub fn closePath(self: Context) void {
        raw.CGContextClosePath(self.handle);
    }

    pub fn addRect(self: Context, area: Rect) void {
        raw.CGContextAddRect(self.handle, area.toRaw());
    }

    pub fn addRects(self: Context, areas: []const Rect) void {
        raw.CGContextAddRects(self.handle, @ptrCast(areas.ptr), areas.len);
    }

    pub fn addLines(self: Context, points: []const Point) void {
        raw.CGContextAddLines(self.handle, @ptrCast(points.ptr), points.len);
    }

    pub fn addEllipseInRect(self: Context, area: Rect) void {
        raw.CGContextAddEllipseInRect(self.handle, area.toRaw());
    }

    /// Angles are in radians, counter-clockwise in an unflipped context.
    /// A line is drawn from the current point to the start of the arc.
    pub fn addArc(
        self: Context,
        center: Point,
        radius: Float,
        start_angle: Float,
        end_angle: Float,
        clockwise: bool,
    ) void {
        raw.CGContextAddArc(
            self.handle,
            center.x,
            center.y,
            radius,
            start_angle,
            end_angle,
            @intFromBool(clockwise),
        );
    }

    pub fn addArcToPoint(self: Context, corner: Point, end: Point, radius: Float) void {
        raw.CGContextAddArcToPoint(self.handle, corner.x, corner.y, end.x, end.y, radius);
    }

    /// Appends a prebuilt `Path`. This is how the same shape is drawn more
    /// than once without rebuilding it, since drawing clears the path.
    pub fn addPath(self: Context, path: Path) void {
        raw.CGContextAddPath(self.handle, path.toRaw());
    }

    pub fn isPathEmpty(self: Context) bool {
        return raw.CGContextIsPathEmpty(self.handle);
    }

    pub fn pathCurrentPoint(self: Context) Point {
        return .fromRaw(raw.CGContextGetPathCurrentPoint(self.handle));
    }

    pub fn pathBoundingBox(self: Context) Rect {
        return .fromRaw(raw.CGContextGetPathBoundingBox(self.handle));
    }

    /// A copy of the current path, which the caller owns. Taking this
    /// before drawing is the other way to reuse a shape.
    pub fn copyPath(self: Context) Error!Path {
        return .{ .handle = try errors.checkPtr(raw.CGContextCopyPath(self.handle)) };
    }

    // -- drawing the current path ----------------------------------------
    //
    // Every one of these empties the current path.

    pub fn drawPath(self: Context, mode: DrawingMode) void {
        raw.CGContextDrawPath(self.handle, @backingInt(mode));
    }

    /// Fills using the non-zero winding rule.
    pub fn fillPath(self: Context) void {
        raw.CGContextFillPath(self.handle);
    }

    /// Fills using the even-odd rule, which is what makes a shape inside a
    /// shape a hole.
    pub fn eoFillPath(self: Context) void {
        raw.CGContextEOFillPath(self.handle);
    }

    pub fn strokePath(self: Context) void {
        raw.CGContextStrokePath(self.handle);
    }

    // -- drawing a shape directly ----------------------------------------
    //
    // These do not touch the current path.

    pub fn fillRect(self: Context, area: Rect) void {
        raw.CGContextFillRect(self.handle, area.toRaw());
    }

    pub fn fillRects(self: Context, areas: []const Rect) void {
        raw.CGContextFillRects(self.handle, @ptrCast(areas.ptr), areas.len);
    }

    pub fn strokeRect(self: Context, area: Rect) void {
        raw.CGContextStrokeRect(self.handle, area.toRaw());
    }

    pub fn strokeRectWithWidth(self: Context, area: Rect, width: Float) void {
        raw.CGContextStrokeRectWithWidth(self.handle, area.toRaw(), width);
    }

    pub fn fillEllipseInRect(self: Context, area: Rect) void {
        raw.CGContextFillEllipseInRect(self.handle, area.toRaw());
    }

    pub fn strokeEllipseInRect(self: Context, area: Rect) void {
        raw.CGContextStrokeEllipseInRect(self.handle, area.toRaw());
    }

    /// Strokes each *pair* of points as a separate segment, so `points`
    /// must have an even length. For a connected run, use `addLines`.
    pub fn strokeLineSegments(self: Context, points: []const Point) void {
        std.debug.assert(points.len % 2 == 0);
        raw.CGContextStrokeLineSegments(self.handle, @ptrCast(points.ptr), points.len);
    }

    /// Erases `area` to transparent, ignoring the fill colour and the blend
    /// mode. In a context without an alpha channel it paints black.
    pub fn clearRect(self: Context, area: Rect) void {
        raw.CGContextClearRect(self.handle, area.toRaw());
    }

    // -- clipping ---------------------------------------------------------
    //
    // Clipping only ever *shrinks* the visible area. There is no call to
    // widen it again -- that is what `save` and `restore` are for.

    /// Intersects the clip with the current path, using the non-zero rule,
    /// and clears the path.
    pub fn clip(self: Context) void {
        raw.CGContextClip(self.handle);
    }

    /// The same with the even-odd rule.
    pub fn eoClip(self: Context) void {
        raw.CGContextEOClip(self.handle);
    }

    pub fn clipToRect(self: Context, area: Rect) void {
        raw.CGContextClipToRect(self.handle, area.toRaw());
    }

    pub fn clipToRects(self: Context, areas: []const Rect) void {
        raw.CGContextClipToRects(self.handle, @ptrCast(areas.ptr), areas.len);
    }

    /// Clips to a prebuilt path.
    ///
    /// CoreGraphics has no call that clips to a path directly, so this goes
    /// through the current path and therefore **replaces** it. Take a
    /// `copyPath` first if the current path is still needed.
    pub fn clipToPath(self: Context, path: Path, even_odd: bool) void {
        self.beginPath();
        self.addPath(path);
        if (even_odd) self.eoClip() else self.clip();
    }

    /// Clips through an image's alpha, so the result is a soft-edged mask
    /// rather than a hard outline.
    pub fn clipToMask(self: Context, area: Rect, mask: Image) void {
        raw.CGContextClipToMask(self.handle, area.toRaw(), mask.toRaw());
    }

    pub fn clipBoundingBox(self: Context) Rect {
        return .fromRaw(raw.CGContextGetClipBoundingBox(self.handle));
    }

    /// Throws the clip away entirely, back to the whole context.
    pub fn resetClip(self: Context) void {
        raw.CGContextResetClip(self.handle);
    }

    // -- images ------------------------------------------------------------

    /// Draws `img` scaled to fill `area`.
    ///
    /// The image comes out the right way up in an ordinary context, and
    /// upside down in one that `flipVertically` has been called on --
    /// `drawImageUpright` is the version for that case.
    pub fn drawImage(self: Context, area: Rect, img: Image) void {
        raw.CGContextDrawImage(self.handle, area.toRaw(), img.toRaw());
    }

    /// Draws `img` scaled to fill `area`, the right way up in a context
    /// that has been flipped with `flipVertically`.
    ///
    /// It flips back over `area` for the duration of the draw, so it is
    /// exactly `drawImage` in an unflipped context and the correction in a
    /// flipped one.
    pub fn drawImageUpright(self: Context, area: Rect, img: Image) void {
        self.save();
        defer self.restore();

        self.translate(area.minX(), area.minY() + area.height());
        self.scale(1, -1);
        raw.CGContextDrawImage(
            self.handle,
            (Rect{ .size = area.size }).toRaw(),
            img.toRaw(),
        );
    }

    /// Tiles `img` across the clip, using `area` as the size and phase of
    /// one tile.
    pub fn drawTiledImage(self: Context, area: Rect, img: Image) void {
        raw.CGContextDrawTiledImage(self.handle, area.toRaw(), img.toRaw());
    }

    // -- gradients ----------------------------------------------------------

    /// A gradient along the line from `start` to `end`.
    pub fn drawLinearGradient(
        self: Context,
        gradient: Gradient,
        start: Point,
        end: Point,
        options: GradientDrawingOptions,
    ) void {
        raw.CGContextDrawLinearGradient(
            self.handle,
            gradient.toRaw(),
            start.toRaw(),
            end.toRaw(),
            @backingInt(options),
        );
    }

    /// A gradient between two circles. Equal centres and a zero start
    /// radius give the ordinary radial gradient.
    pub fn drawRadialGradient(
        self: Context,
        gradient: Gradient,
        start_center: Point,
        start_radius: Float,
        end_center: Point,
        end_radius: Float,
        options: GradientDrawingOptions,
    ) void {
        raw.CGContextDrawRadialGradient(
            self.handle,
            gradient.toRaw(),
            start_center.toRaw(),
            start_radius,
            end_center.toRaw(),
            end_radius,
            @backingInt(options),
        );
    }

    /// A gradient sweeping around `center`, starting at `angle` radians.
    pub fn drawConicGradient(
        self: Context,
        gradient: Gradient,
        center: Point,
        angle: Float,
    ) void {
        raw.CGContextDrawConicGradient(self.handle, gradient.toRaw(), center.toRaw(), angle);
    }

    // -- transparency layers -------------------------------------------------

    /// Starts a group that is composited as a unit. Everything until
    /// `endTransparencyLayer` is drawn to a scratch buffer and then applied
    /// once, so a shared alpha or shadow covers the group rather than each
    /// piece separately -- which is how overlapping translucent shapes stop
    /// showing their seams.
    pub fn beginTransparencyLayer(self: Context) void {
        raw.CGContextBeginTransparencyLayer(self.handle, null);
    }

    /// The same, bounded to `area`, which lets CoreGraphics allocate a
    /// smaller scratch buffer.
    pub fn beginTransparencyLayerInRect(self: Context, area: Rect) void {
        raw.CGContextBeginTransparencyLayerWithRect(self.handle, area.toRaw(), null);
    }

    pub fn endTransparencyLayer(self: Context) void {
        raw.CGContextEndTransparencyLayer(self.handle);
    }

    // -- layers -----------------------------------------------------------

    pub fn drawLayerInRect(self: Context, area: Rect, layer: Layer) void {
        raw.CGContextDrawLayerInRect(self.handle, area.toRaw(), layer.toRaw());
    }

    pub fn drawLayerAtPoint(self: Context, point: Point, layer: Layer) void {
        raw.CGContextDrawLayerAtPoint(self.handle, point.toRaw(), layer.toRaw());
    }

    // -- text position ------------------------------------------------------
    //
    // Laying text out needs CoreText; see `cg.text`. These are the pieces
    // CoreGraphics itself owns.

    pub fn setTextPosition(self: Context, point: Point) void {
        raw.CGContextSetTextPosition(self.handle, point.x, point.y);
    }

    pub fn textPosition(self: Context) Point {
        return .fromRaw(raw.CGContextGetTextPosition(self.handle));
    }

    /// The transform applied to glyphs, separately from the CTM. In a
    /// flipped context this must be flipped back -- `.scaling(1, -1)` --
    /// or text draws mirrored.
    pub fn setTextMatrix(self: Context, matrix: AffineTransform) void {
        raw.CGContextSetTextMatrix(self.handle, matrix.toRaw());
    }

    pub fn textMatrix(self: Context) AffineTransform {
        return .fromRaw(raw.CGContextGetTextMatrix(self.handle));
    }

    pub fn setTextDrawingMode(self: Context, mode: TextDrawingMode) void {
        raw.CGContextSetTextDrawingMode(self.handle, @backingInt(mode));
    }

    // -- what a bitmap context is -------------------------------------------

    /// The live pixel buffer, or null when this is not a bitmap context.
    ///
    /// These are the context's own bytes, not a copy: writing to them
    /// changes what is drawn. The slice is `bytesPerRow * height` long,
    /// which is not always `width * 4` -- rows can be padded.
    pub fn bitmapData(self: Context) ?[]u8 {
        const base = raw.CGBitmapContextGetData(self.handle) orelse return null;
        const stride = raw.CGBitmapContextGetBytesPerRow(self.handle);
        const rows = raw.CGBitmapContextGetHeight(self.handle);
        if (stride == 0 or rows == 0) return null;
        return @as([*]u8, @ptrCast(base))[0 .. stride * rows];
    }

    pub fn bitmapWidth(self: Context) usize {
        return raw.CGBitmapContextGetWidth(self.handle);
    }

    pub fn bitmapHeight(self: Context) usize {
        return raw.CGBitmapContextGetHeight(self.handle);
    }

    pub fn bitmapBytesPerRow(self: Context) usize {
        return raw.CGBitmapContextGetBytesPerRow(self.handle);
    }

    pub fn bitmapBitsPerComponent(self: Context) usize {
        return raw.CGBitmapContextGetBitsPerComponent(self.handle);
    }

    pub fn bitmapBitsPerPixel(self: Context) usize {
        return raw.CGBitmapContextGetBitsPerPixel(self.handle);
    }

    pub fn bitmapInfo(self: Context) BitmapInfo {
        return .fromRaw(raw.CGBitmapContextGetBitmapInfo(self.handle));
    }

    /// The colour space, borrowed -- do not `deinit` it.
    pub fn bitmapSpace(self: Context) ?ColorSpace {
        return ColorSpace.fromRaw(raw.CGBitmapContextGetColorSpace(self.handle));
    }

    /// The context's size as a rectangle at the origin -- what to pass to
    /// `clearRect` or `fillRect` to cover the whole thing.
    pub fn bitmapBounds(self: Context) Rect {
        return .init(
            0,
            0,
            @floatFromInt(self.bitmapWidth()),
            @floatFromInt(self.bitmapHeight()),
        );
    }

    /// A snapshot of everything drawn so far, as an image the caller owns.
    /// The context stays usable and the image does not change with it.
    pub fn createImage(self: Context) Error!Image {
        const created = raw.CGBitmapContextCreateImage(self.handle);
        return .{ .handle = try errors.checkPtr(created) };
    }

    // -- PDF ------------------------------------------------------------------

    /// Draws a page of an existing document. The page arrives in its own
    /// coordinate system, so concatenate `Page.drawingTransform` first to
    /// place it.
    pub fn drawPdfPage(self: Context, page: pdf_mod.Page) void {
        raw.CGContextDrawPDFPage(self.handle, page.toRaw());
    }

    /// Starts a page in a PDF context. Nothing can be drawn outside a page.
    pub fn beginPdfPage(self: Context) void {
        raw.CGPDFContextBeginPage(self.handle, null);
    }

    pub fn endPdfPage(self: Context) void {
        raw.CGPDFContextEndPage(self.handle);
    }

    /// Finishes the document. A PDF context is not complete until this is
    /// called -- releasing the context without it leaves a truncated file.
    pub fn closePdf(self: Context) void {
        raw.CGPDFContextClose(self.handle);
    }

    /// Makes `area` on the current page a link to `url`.
    pub fn setPdfUrlForRect(self: Context, url: cf.Url, area: Rect) void {
        raw.CGPDFContextSetURLForRect(self.handle, url.toRaw(), area.toRaw());
    }
};

/// A gradient: a set of colours at positions along a 0..1 axis. Which
/// direction that axis points is decided when it is drawn, not here, so one
/// gradient can be used linearly and radially.
pub const Gradient = struct {
    handle: *raw.struct_CGGradient,

    /// A stop: a colour and where it sits on the 0..1 axis.
    pub const Stop = struct {
        location: Float,
        color: Rgba,
    };

    /// A gradient in device RGB from a list of stops.
    ///
    /// `allocator` is for the flattened component and location arrays that
    /// CoreGraphics wants, and both are freed before this returns.
    pub fn init(
        allocator: std.mem.Allocator,
        stops: []const Stop,
    ) (Error || std.mem.Allocator.Error)!Gradient {
        if (stops.len < 2) return Error.IllegalArgument;

        const space = try ColorSpace.deviceRgb();
        defer space.deinit();

        const components = try allocator.alloc(Float, stops.len * 4);
        defer allocator.free(components);
        const locations = try allocator.alloc(Float, stops.len);
        defer allocator.free(locations);

        for (stops, 0..) |stop, i| {
            components[i * 4 + 0] = stop.color.r;
            components[i * 4 + 1] = stop.color.g;
            components[i * 4 + 2] = stop.color.b;
            components[i * 4 + 3] = stop.color.a;
            locations[i] = stop.location;
        }

        const created = raw.CGGradientCreateWithColorComponents(
            space.toRaw(),
            components.ptr,
            locations.ptr,
            stops.len,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// The two-stop case, which does not need an allocator.
    pub fn initTwoColor(from: Rgba, to: Rgba) Error!Gradient {
        const space = try ColorSpace.deviceRgb();
        defer space.deinit();

        const components = [_]Float{ from.r, from.g, from.b, from.a, to.r, to.g, to.b, to.a };
        const locations = [_]Float{ 0, 1 };

        const created = raw.CGGradientCreateWithColorComponents(
            space.toRaw(),
            &components,
            &locations,
            2,
        );
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Gradient) void {
        raw.CGGradientRelease(self.handle);
    }

    pub fn retain(self: Gradient) Gradient {
        return .{ .handle = raw.CGGradientRetain(self.handle).? };
    }

    pub inline fn toRaw(self: Gradient) raw.CGGradientRef {
        return self.handle;
    }
};

/// An offscreen buffer tied to a context, for drawing the same thing many
/// times. A layer is the right tool when a shape is expensive and repeated;
/// for a one-off, draw straight into the context.
pub const Layer = struct {
    handle: *raw.struct_CGLayer,

    /// A layer of `size` compatible with `context` -- same colour space,
    /// same resolution, so drawing it back is a straight copy.
    pub fn init(in: Context, of_size: Size) Error!Layer {
        const created = raw.CGLayerCreateWithContext(in.toRaw(), of_size.toRaw(), null);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Layer) void {
        raw.CGLayerRelease(self.handle);
    }

    pub fn retain(self: Layer) Layer {
        return .{ .handle = raw.CGLayerRetain(self.handle).? };
    }

    pub inline fn toRaw(self: Layer) raw.CGLayerRef {
        return self.handle;
    }

    pub fn size(self: Layer) Size {
        return .fromRaw(raw.CGLayerGetSize(self.handle));
    }

    /// The context that draws *into* the layer, borrowed -- do not
    /// `deinit` it. Its coordinate system is the layer's own, with the
    /// origin at the bottom left of the layer.
    pub fn context(self: Layer) ?Context {
        return Context.fromRaw(raw.CGLayerGetContext(self.handle));
    }
};

// ---------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------

/// The four bytes of one pixel of a `.bgra8888` bitmap context, in memory
/// order: blue, green, red, alpha.
fn pixelAt(ctx: Context, x: usize, y: usize) [4]u8 {
    const data = ctx.bitmapData().?;
    const offset = y * ctx.bitmapBytesPerRow() + x * 4;
    return data[offset..][0..4].*;
}

test "a bitmap context starts transparent and fills to the colour it is given" {
    const ctx = try Context.initBitmap(.{ .width = 4, .height = 4 });
    defer ctx.deinit();

    try std.testing.expectEqual(@as(usize, 4), ctx.bitmapWidth());
    try std.testing.expectEqual(@as(usize, 8), ctx.bitmapBitsPerComponent());
    try std.testing.expectEqual(BitmapInfo.bgra8888, ctx.bitmapInfo());

    // Nothing drawn yet.
    try std.testing.expectEqual([4]u8{ 0, 0, 0, 0 }, pixelAt(ctx, 0, 0));

    ctx.setFillColor(.rgb(1, 0, 0));
    ctx.fillRect(ctx.bitmapBounds());

    // B, G, R, A -- the name of the layout is not the order of the bytes.
    try std.testing.expectEqual([4]u8{ 0, 0, 255, 255 }, pixelAt(ctx, 2, 2));
}

test "rgba8888 puts the bytes in the order its name says" {
    const ctx = try Context.initBitmap(.{
        .width = 2,
        .height = 2,
        .bitmap_info = .rgba8888,
    });
    defer ctx.deinit();

    ctx.setFillColor(.rgb(1, 0, 0));
    ctx.fillRect(ctx.bitmapBounds());

    const data = ctx.bitmapData().?;
    try std.testing.expectEqual([4]u8{ 255, 0, 0, 255 }, data[0..4].*);
}

test "the y axis points up until it is flipped" {
    const ctx = try Context.initBitmap(.{ .width = 4, .height = 4 });
    defer ctx.deinit();

    // A rectangle at y = 0 lands at the *bottom* of the bitmap, which in
    // memory is the last row.
    ctx.setFillColor(.rgb(0, 1, 0));
    ctx.fillRect(.init(0, 0, 4, 1));

    try std.testing.expectEqual(@as(u8, 255), pixelAt(ctx, 0, 3)[1]);
    try std.testing.expectEqual(@as(u8, 0), pixelAt(ctx, 0, 0)[3]);

    // After flipping, y = 0 is the top row.
    ctx.flipVertically(4);
    ctx.setFillColor(.rgb(0, 0, 1));
    ctx.fillRect(.init(0, 0, 4, 1));

    try std.testing.expectEqual(@as(u8, 255), pixelAt(ctx, 0, 0)[0]);
}

test "restore undoes everything save captured" {
    const ctx = try Context.initBitmap(.{ .width = 8, .height = 8 });
    defer ctx.deinit();

    ctx.save();
    ctx.clipToRect(.init(0, 0, 2, 2));
    ctx.setFillColor(.rgb(1, 0, 0));
    ctx.fillRect(ctx.bitmapBounds());
    try std.testing.expect(ctx.clipBoundingBox().eql(Rect.init(0, 0, 2, 2)));
    ctx.restore();

    // The clip is gone, so this covers the whole bitmap.
    try std.testing.expect(ctx.clipBoundingBox().eql(Rect.init(0, 0, 8, 8)));
    ctx.setFillColor(.rgb(0, 1, 0));
    ctx.fillRect(ctx.bitmapBounds());
    try std.testing.expectEqual(@as(u8, 255), pixelAt(ctx, 7, 7)[1]);
}

test "drawing consumes the current path" {
    const ctx = try Context.initBitmap(.{ .width = 4, .height = 4 });
    defer ctx.deinit();

    ctx.beginPath();
    ctx.moveTo(.init(0, 0));
    ctx.lineTo(.init(4, 4));
    try std.testing.expect(!ctx.isPathEmpty());

    ctx.strokePath();
    try std.testing.expect(ctx.isPathEmpty());
}

test "a prebuilt path can be drawn more than once" {
    const ctx = try Context.initBitmap(.{ .width = 16, .height = 16 });
    defer ctx.deinit();

    const square = try Path.initRect(.init(0, 0, 4, 4));
    defer square.deinit();

    ctx.setFillColor(.rgb(1, 1, 1));
    for ([_]Float{ 0, 8 }) |offset| {
        ctx.save();
        defer ctx.restore();
        ctx.translate(offset, offset);
        ctx.addPath(square);
        ctx.fillPath();
    }

    try std.testing.expectEqual(@as(u8, 255), pixelAt(ctx, 1, 14)[0]);
    try std.testing.expectEqual(@as(u8, 255), pixelAt(ctx, 9, 6)[0]);
    try std.testing.expectEqual(@as(u8, 0), pixelAt(ctx, 9, 14)[3]);
}

test "initBitmap rejects what CoreGraphics would refuse silently" {
    try std.testing.expectError(
        Error.IllegalArgument,
        Context.initBitmap(.{ .width = 0, .height = 4 }),
    );
    // Non-premultiplied alpha is a valid image layout but not a valid
    // context layout.
    try std.testing.expectError(
        Error.IllegalArgument,
        Context.initBitmap(.{ .width = 4, .height = 4, .bitmap_info = .{ .alpha = .last } }),
    );
    // A caller-supplied buffer has to say how long its rows are.
    var pixels: [64]u8 = @splat(0);
    try std.testing.expectError(
        Error.IllegalArgument,
        Context.initBitmap(.{ .width = 4, .height = 4, .pixels = &pixels }),
    );
    try std.testing.expectError(
        Error.RangeCheck,
        Context.initBitmap(.{
            .width = 4,
            .height = 4,
            .bytes_per_row = 32,
            .pixels = &pixels,
        }),
    );
}

test "a caller-supplied buffer is the one that gets drawn into" {
    var pixels: [4 * 4 * 4]u8 = @splat(0);
    const ctx = try Context.initBitmap(.{
        .width = 4,
        .height = 4,
        .bytes_per_row = 16,
        .pixels = &pixels,
    });
    defer ctx.deinit();

    ctx.setFillColor(.rgb(1, 1, 1));
    ctx.fillRect(ctx.bitmapBounds());

    try std.testing.expectEqual(@as(u8, 255), pixels[0]);
}

test "createImage snapshots without freezing the context" {
    const ctx = try Context.initBitmap(.{ .width = 4, .height = 4 });
    defer ctx.deinit();

    ctx.setFillColor(.rgb(1, 0, 0));
    ctx.fillRect(ctx.bitmapBounds());

    const snapshot = try ctx.createImage();
    defer snapshot.deinit();
    try std.testing.expectEqual(@as(usize, 4), snapshot.width());

    // Drawing afterwards changes the context, not the snapshot.
    ctx.setFillColor(.rgb(0, 1, 0));
    ctx.fillRect(ctx.bitmapBounds());
    try std.testing.expectEqual(@as(u8, 255), pixelAt(ctx, 0, 0)[1]);
    try std.testing.expectEqual(@as(usize, 4), snapshot.width());
}

test "a gradient needs at least two stops" {
    try std.testing.expectError(
        Error.IllegalArgument,
        Gradient.init(std.testing.allocator, &.{.{ .location = 0, .color = .white }}),
    );

    const ramp = try Gradient.init(std.testing.allocator, &.{
        .{ .location = 0, .color = .black },
        .{ .location = 0.5, .color = .hex(0x2ECC71) },
        .{ .location = 1, .color = .white },
    });
    defer ramp.deinit();
}

test "a linear gradient paints between its endpoints" {
    const ctx = try Context.initBitmap(.{ .width = 16, .height = 4 });
    defer ctx.deinit();

    const ramp = try Gradient.initTwoColor(.rgb(0, 0, 0), .rgb(1, 1, 1));
    defer ramp.deinit();

    ctx.drawLinearGradient(ramp, .init(0, 0), .init(16, 0), .both);

    const left = pixelAt(ctx, 0, 2)[0];
    const middle = pixelAt(ctx, 8, 2)[0];
    const right = pixelAt(ctx, 15, 2)[0];

    // Monotonic from black to white. Neither end reaches 0 or 255 exactly:
    // a pixel is sampled at its centre, so the last one sits at 15.5/16
    // along the axis rather than at the endpoint.
    try std.testing.expect(left < middle);
    try std.testing.expect(middle < right);
    try std.testing.expect(left < 16);
    try std.testing.expect(right > 240);
}

test "a layer draws back into the context that made it" {
    const ctx = try Context.initBitmap(.{ .width = 16, .height = 16 });
    defer ctx.deinit();

    const layer = try Layer.init(ctx, .init(4, 4));
    defer layer.deinit();
    try std.testing.expect(layer.size().eql(Size.init(4, 4)));

    const inner = layer.context().?;
    inner.setFillColor(.rgb(1, 0, 1));
    inner.fillRect(.init(0, 0, 4, 4));

    ctx.drawLayerAtPoint(.init(8, 8), layer);

    // Drawn at (8, 8) from the bottom left, so rows 4..7 from the top.
    const drawn = pixelAt(ctx, 9, 5);
    try std.testing.expectEqual(@as(u8, 255), drawn[0]);
    try std.testing.expectEqual(@as(u8, 255), drawn[2]);
    try std.testing.expectEqual(@as(u8, 0), pixelAt(ctx, 1, 1)[3]);
}

test "clipToPath replaces the current path" {
    const ctx = try Context.initBitmap(.{ .width = 8, .height = 8 });
    defer ctx.deinit();

    const circle = try Path.initEllipse(.init(0, 0, 8, 8));
    defer circle.deinit();

    ctx.save();
    defer ctx.restore();

    ctx.moveTo(.init(0, 0));
    ctx.clipToPath(circle, false);
    try std.testing.expect(ctx.isPathEmpty());

    ctx.setFillColor(.rgb(1, 1, 1));
    ctx.fillRect(ctx.bitmapBounds());

    // Inside the circle is painted; the corner is outside it.
    try std.testing.expectEqual(@as(u8, 255), pixelAt(ctx, 4, 4)[0]);
    try std.testing.expectEqual(@as(u8, 0), pixelAt(ctx, 0, 0)[3]);
}
