//! Drawing a string, under `-Dcoretext` (on by default).
//!
//! CoreGraphics cannot lay text out. It can draw *glyphs* -- numbered
//! outlines at positions you work out yourself -- and the calls that took
//! a string (`CGContextShowText`, `CGContextSelectFont`) were deprecated in
//! macOS 10.9 and never handled anything beyond Latin-1. Turning characters
//! into positioned glyphs is CoreText's job.
//!
//! This is a bridge, not a CoreText binding. It covers one line of text in
//! one font -- enough to label a chart, stamp a caption or measure a
//! string -- and deliberately stops short of paragraphs, wrapping, rich
//! text and font descriptors. For those, use CoreText directly; the
//! handles here convert with `toRaw`.
//!
//! CoreText's own headers cannot be run through Zig's C translator (they
//! are full of blocks), so the handful of functions used here are declared
//! by hand at the bottom of this file rather than coming from `cg.raw`.
//!
//! ## Text in a flipped context
//!
//! Glyphs are positioned by the *text matrix*, which is separate from the
//! CTM. In a context that has been flipped with `flipVertically`, the CTM
//! turns glyphs upside down and the text matrix has to turn them back:
//!
//! ```zig
//! ctx.flipVertically(height);
//! ctx.setTextMatrix(.scaling(1, -1));   // or text draws mirrored
//! try cg.text.draw(ctx, "hello", font, .init(20, 40), null);
//! ```
//!
//! In an unflipped context the text matrix should be the identity, which is
//! what a fresh context already has.

const std = @import("std");
const raw = @import("mac_raw");
const errors = @import("../errors.zig");
const cf = @import("../cf.zig");
const geometry = @import("geometry.zig");
const color_mod = @import("color.zig");
const context_mod = @import("context.zig");

const Error = errors.Error;
const Float = geometry.Float;
const Point = geometry.Point;
const Rect = geometry.Rect;
const Color = color_mod.Color;
const Context = context_mod.Context;

/// True when the package was built with `-Dcoretext` (the default).
pub const enabled = true;

/// A font at a size. Reference counted; make one and keep it rather than
/// creating one per string.
pub const Font = struct {
    handle: *CTFont,

    /// A font by PostScript or full name -- `"Helvetica"`,
    /// `"SFMono-Regular"`. CoreText substitutes something else rather than
    /// failing when the name is unknown, so a typo produces the wrong font
    /// and not an error.
    pub fn init(name: []const u8, points: Float) Error!Font {
        const cf_name = try cf.String.init(name);
        defer cf_name.deinit();
        const created = CTFontCreateWithName(cf_name.toRaw(), points, null);
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// The system UI font, which is what matches the rest of the platform.
    pub fn initSystem(points: Float) Error!Font {
        return .{
            .handle = try errors.checkPtr(CTFontCreateUIFontForLanguage(ui_font_system, points, null)),
        };
    }

    /// The system's fixed-pitch font, for anything in columns.
    pub fn initMonospaced(points: Float) Error!Font {
        return .{
            .handle = try errors.checkPtr(
                CTFontCreateUIFontForLanguage(ui_font_user_fixed_pitch, points, null),
            ),
        };
    }

    pub fn deinit(self: Font) void {
        raw.CFRelease(self.handle);
    }

    pub fn retain(self: Font) Font {
        return .{ .handle = @ptrCast(raw.CFRetain(self.handle).?) };
    }

    pub inline fn toRaw(self: Font) *CTFont {
        return self.handle;
    }

    pub fn size(self: Font) Float {
        return CTFontGetSize(self.handle);
    }

    /// How far glyphs reach above the baseline.
    pub fn ascent(self: Font) Float {
        return CTFontGetAscent(self.handle);
    }

    /// How far glyphs reach below the baseline, as a positive number.
    pub fn descent(self: Font) Float {
        return CTFontGetDescent(self.handle);
    }

    /// The extra space the font asks for between lines, which is usually 0.
    pub fn leading(self: Font) Float {
        return CTFontGetLeading(self.handle);
    }

    /// Baseline to baseline: what to step by when stacking lines.
    pub fn lineHeight(self: Font) Float {
        return self.ascent() + self.descent() + self.leading();
    }

    /// The font's full name, in memory the caller owns. Worth checking
    /// after `init`, since an unknown name substitutes silently.
    pub fn fullName(self: Font, allocator: std.mem.Allocator) ![]u8 {
        const name = cf.String.fromRaw(CTFontCopyFullName(self.handle)) orelse
            return Error.Failed;
        defer name.deinit();
        return name.toOwnedSlice(allocator);
    }
};

/// One laid-out line of text. Laying out costs something, so a label drawn
/// every frame is worth keeping rather than rebuilding.
pub const Line = struct {
    handle: *CTLine,

    /// Lays `text` out in `font`.
    ///
    /// `color` null means the line takes the context's fill colour when it
    /// is drawn, so `ctx.setFillColor(...)` works the way it does for
    /// everything else. Give a `Color` to bind the colour to the line
    /// instead.
    ///
    /// Newlines are not line breaks here -- this is one line, and CoreText
    /// lays the whole string out along it. Split the text first.
    pub fn init(text: []const u8, font: Font, color: ?Color) Error!Line {
        const string = try cf.String.init(text);
        defer string.deinit();

        const font_key = cf.Type{ .handle = kCTFontAttributeName.? };
        const font_value = cf.Type{ .handle = font.handle };

        const attributes = if (color) |c|
            try cf.Dictionary.initFixed(.{
                .{ .key = font_key, .value = font_value },
                .{
                    .key = cf.Type{ .handle = kCTForegroundColorAttributeName.? },
                    .value = cf.Type{ .handle = c.toRaw().? },
                },
            })
        else
            try cf.Dictionary.initFixed(.{
                .{ .key = font_key, .value = font_value },
                .{
                    .key = cf.Type{ .handle = kCTForegroundColorFromContextAttributeName.? },
                    .value = cf.Boolean.of(true).asType(),
                },
            });
        defer attributes.deinit();

        const attributed = raw.CFAttributedStringCreate(
            null,
            string.toRaw(),
            attributes.toRaw(),
        );
        const checked = try errors.checkPtr(attributed);
        defer raw.CFRelease(checked);

        return .{ .handle = try errors.checkPtr(CTLineCreateWithAttributedString(checked)) };
    }

    pub fn deinit(self: Line) void {
        raw.CFRelease(self.handle);
    }

    pub inline fn toRaw(self: Line) *CTLine {
        return self.handle;
    }

    pub fn glyphCount(self: Line) usize {
        const count = CTLineGetGlyphCount(self.handle);
        return if (count < 0) 0 else @intCast(count);
    }

    pub const Metrics = struct {
        /// How far the pen moves: the width to advance by, which is not the
        /// same as the width of the ink -- see `imageBounds`.
        width: Float,
        ascent: Float,
        descent: Float,
        leading: Float,

        pub fn height(self: Metrics) Float {
            return self.ascent + self.descent + self.leading;
        }
    };

    /// The typographic metrics: what to lay out against.
    pub fn metrics(self: Line) Metrics {
        var ascent: Float = 0;
        var descent: Float = 0;
        var leading: Float = 0;
        const width = CTLineGetTypographicBounds(self.handle, &ascent, &descent, &leading);
        return .{
            .width = width,
            .ascent = ascent,
            .descent = descent,
            .leading = leading,
        };
    }

    /// The rectangle the ink actually covers, relative to the baseline
    /// origin. Tighter than `metrics` -- use this to centre text or to size
    /// a box around it, and `metrics` to position the next line.
    pub fn imageBounds(self: Line, ctx: Context) Rect {
        return .fromRaw(CTLineGetImageBounds(self.handle, ctx.toRaw()));
    }

    /// Draws with the baseline starting at the context's current text
    /// position.
    pub fn draw(self: Line, ctx: Context) void {
        CTLineDraw(self.handle, ctx.toRaw());
    }

    /// Draws with the baseline starting at `origin`. Note that `origin` is
    /// on the **baseline**, not at the top of the text -- add
    /// `metrics().ascent` to place the top instead.
    pub fn drawAt(self: Line, ctx: Context, origin: Point) void {
        ctx.setTextPosition(origin);
        CTLineDraw(self.handle, ctx.toRaw());
    }
};

/// Lays a string out and draws it in one call, for text that is drawn once.
/// Keep a `Line` instead when the same string is drawn repeatedly.
pub fn draw(
    ctx: Context,
    text: []const u8,
    font: Font,
    origin: Point,
    color: ?Color,
) Error!void {
    const line = try Line.init(text, font, color);
    defer line.deinit();
    line.drawAt(ctx, origin);
}

/// The advance width of `text` in `font`, without drawing it.
pub fn measure(text: []const u8, font: Font) Error!Line.Metrics {
    const line = try Line.init(text, font, null);
    defer line.deinit();
    return line.metrics();
}

// ---------------------------------------------------------------------
// The CoreText declarations this bridge uses.
//
// CoreText's headers declare block-typed callbacks throughout, which Zig's
// C translator cannot parse, so the framework is linked but not translated
// and these are written out by hand. Every one has been stable since macOS
// 10.5.
// ---------------------------------------------------------------------

pub const CTFont = opaque {};
pub const CTLine = opaque {};

const ui_font_user_fixed_pitch: u32 = 1;
const ui_font_system: u32 = 2;

extern fn CTFontCreateWithName(
    name: raw.CFStringRef,
    points: raw.CGFloat,
    matrix: ?*const raw.CGAffineTransform,
) ?*CTFont;
extern fn CTFontCreateUIFontForLanguage(
    ui_type: u32,
    points: raw.CGFloat,
    language: raw.CFStringRef,
) ?*CTFont;
extern fn CTFontGetSize(font: *CTFont) raw.CGFloat;
extern fn CTFontGetAscent(font: *CTFont) raw.CGFloat;
extern fn CTFontGetDescent(font: *CTFont) raw.CGFloat;
extern fn CTFontGetLeading(font: *CTFont) raw.CGFloat;
extern fn CTFontCopyFullName(font: *CTFont) raw.CFStringRef;

extern fn CTLineCreateWithAttributedString(string: *const anyopaque) ?*CTLine;
extern fn CTLineGetGlyphCount(line: *CTLine) raw.CFIndex;
extern fn CTLineDraw(line: *CTLine, context: raw.CGContextRef) void;
extern fn CTLineGetTypographicBounds(
    line: *CTLine,
    ascent: ?*raw.CGFloat,
    descent: ?*raw.CGFloat,
    leading: ?*raw.CGFloat,
) f64;
extern fn CTLineGetImageBounds(line: *CTLine, context: raw.CGContextRef) raw.CGRect;

extern const kCTFontAttributeName: raw.CFStringRef;
extern const kCTForegroundColorAttributeName: raw.CFStringRef;
extern const kCTForegroundColorFromContextAttributeName: raw.CFStringRef;

test "a font reports the metrics it was asked for" {
    const font = try Font.initSystem(24);
    defer font.deinit();

    try std.testing.expectEqual(@as(Float, 24), font.size());
    try std.testing.expect(font.ascent() > 0);
    try std.testing.expect(font.descent() > 0);
    try std.testing.expect(font.lineHeight() > font.ascent());

    const name = try font.fullName(std.testing.allocator);
    defer std.testing.allocator.free(name);
    try std.testing.expect(name.len > 0);
}

test "measuring gives a width that grows with the text" {
    const font = try Font.initMonospaced(12);
    defer font.deinit();

    const short = try measure("i", font);
    const long = try measure("iiiiiiiiii", font);

    try std.testing.expect(short.width > 0);
    try std.testing.expect(long.width > short.width);
    // A fixed-pitch font advances by the same amount per character.
    try std.testing.expectApproxEqAbs(short.width * 10, long.width, 0.001);
}

test "a line knows how many glyphs it laid out" {
    const font = try Font.initSystem(12);
    defer font.deinit();

    const line = try Line.init("abc", font, null);
    defer line.deinit();

    try std.testing.expectEqual(@as(usize, 3), line.glyphCount());
    try std.testing.expect(line.metrics().ascent > 0);
}

test "drawing text marks the context" {
    const ctx = try Context.initBitmap(.{ .width = 64, .height = 32 });
    defer ctx.deinit();

    const font = try Font.initSystem(20);
    defer font.deinit();

    // No text matrix to undo, because this context is not flipped.
    ctx.setFillColor(.rgb(1, 1, 1));
    try draw(ctx, "Hg", font, .init(2, 8), null);

    // Something was drawn: at least one pixel is no longer transparent.
    const pixels = ctx.bitmapData().?;
    var painted: usize = 0;
    var i: usize = 3;
    while (i < pixels.len) : (i += 4) {
        if (pixels[i] != 0) painted += 1;
    }
    try std.testing.expect(painted > 0);
}

test "the foreground colour can be bound to the line instead of the context" {
    const ctx = try Context.initBitmap(.{ .width = 64, .height = 32 });
    defer ctx.deinit();

    const font = try Font.initSystem(20);
    defer font.deinit();

    const red = try Color.initSrgb(.rgb(1, 0, 0));
    defer red.deinit();

    // The fill colour is green, but the line carries red.
    ctx.setFillColor(.rgb(0, 1, 0));
    try draw(ctx, "W", font, .init(2, 8), red);

    const pixels = ctx.bitmapData().?;
    var saw_red = false;
    var i: usize = 0;
    while (i + 4 <= pixels.len) : (i += 4) {
        // B, G, R, A
        if (pixels[i + 3] > 200 and pixels[i + 2] > 200 and pixels[i + 1] < 64) saw_red = true;
    }
    try std.testing.expect(saw_red);
}
