//! Text: measuring, aligning, and the flipped-context correction.
//!
//!     zig build run-text

const std = @import("std");
const cg = @import("cg");

const width = 520;
const height = 260;

pub fn main() !void {
    if (!cg.features.coretext) {
        std.debug.print("built with -Dcoretext=false; nothing to draw\n", .{});
        return;
    }

    const ctx = try cg.Context.initBitmap(.{ .width = width, .height = height });
    defer ctx.deinit();

    ctx.setFillColor(.hex(0x16202A));
    ctx.fillRect(ctx.bitmapBounds());

    const title_font = try cg.text.Font.initSystem(34);
    defer title_font.deinit();
    const body_font = try cg.text.Font.initSystem(15);
    defer body_font.deinit();
    const mono_font = try cg.text.Font.initMonospaced(13);
    defer mono_font.deinit();

    // This context is flipped, so the numbers below read top-down. The
    // text matrix has to be flipped back or every glyph draws mirrored.
    ctx.flipVertically(height);
    ctx.setTextMatrix(.scaling(1, -1));

    // A left-aligned title. `origin` is the baseline, so the ascent is
    // added to place the top of the text at y = 32.
    const title = try cg.text.Line.init("cg-zig", title_font, null);
    defer title.deinit();

    ctx.setFillColor(.hex(0xECF0F1));
    const title_metrics = title.metrics();
    title.drawAt(ctx, .init(40, 32 + title_metrics.ascent));

    // A rule the exact width of the title, which is what measuring is for.
    ctx.setFillColor(.hex(0x2ECC71));
    ctx.fillRect(.init(40, 32 + title_metrics.height() + 6, title_metrics.width, 3));

    // Right-aligned text: measure, then subtract from the right edge.
    const version = try cg.text.Line.init("0.1.0", body_font, null);
    defer version.deinit();

    ctx.setFillColor(.hex(0x7F8C8D));
    const version_metrics = version.metrics();
    version.drawAt(ctx, .init(width - 40 - version_metrics.width, 32 + title_metrics.ascent));

    // A few stacked lines, stepped by the font's own line height.
    const lines = [_][]const u8{
        "CoreGraphics draws; CoreText lays out.",
        "Measuring is what makes alignment possible.",
        "A flipped context needs setTextMatrix(.scaling(1, -1)).",
    };

    ctx.setFillColor(.hex(0xBDC3C7));
    var y: cg.Float = 110 + body_font.ascent();
    for (lines) |line| {
        try cg.text.draw(ctx, line, body_font, .init(40, y), null);
        y += body_font.lineHeight() + 4;
    }

    // Colour bound to the line rather than taken from the context.
    const accent = try cg.Color.initSrgb(.hex(0xF1C40F));
    defer accent.deinit();

    ctx.setFillColor(.hex(0xFF00FF)); // deliberately not what gets used
    try cg.text.draw(ctx, "zig build run-text", mono_font, .init(40, 215), accent);

    try cg.imageio.writeContext(ctx, "text.png", .png, .{});
    std.debug.print("wrote text.png ({d}x{d})\n", .{ width, height });
}
