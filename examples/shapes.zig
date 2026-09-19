//! Paths, strokes, clipping and shadows, written to a PNG.
//!
//!     zig build run-shapes

const std = @import("std");
const cg = @import("cg");

const width = 480;
const height = 320;

pub fn main() !void {
    const ctx = try cg.Context.initBitmap(.{ .width = width, .height = height });
    defer ctx.deinit();

    // Background.
    ctx.setFillColor(.hex(0x14181F));
    ctx.fillRect(ctx.bitmapBounds());

    // A filled rounded rectangle with a shadow. The shadow is part of the
    // graphics state, so it is saved and restored rather than cleared.
    {
        ctx.save();
        defer ctx.restore();

        const shadow_color = try cg.Color.initSrgb(.rgba(0, 0, 0, 0.6));
        defer shadow_color.deinit();
        ctx.setShadow(.{ .offset = .init(0, -6), .blur = 12, .color = shadow_color });

        const card = try cg.Path.initRoundedRect(.init(32, 180, 180, 100), 16, 16);
        defer card.deinit();

        ctx.setFillColor(.hex(0x2ECC71));
        ctx.addPath(card);
        ctx.fillPath();
    }

    // A stroked, dashed star built by hand.
    {
        ctx.save();
        defer ctx.restore();

        const star = try cg.MutablePath.init();
        defer star.deinit();

        const center = cg.Point.init(320, 230);
        const outer: cg.Float = 64;
        const inner: cg.Float = 26;
        var i: usize = 0;
        while (i < 10) : (i += 1) {
            const angle = std.math.pi / 2.0 + @as(f64, @floatFromInt(i)) * std.math.pi / 5.0;
            const radius = if (i % 2 == 0) outer else inner;
            const point = cg.Point.init(
                center.x + radius * @cos(angle),
                center.y + radius * @sin(angle),
            );
            if (i == 0) star.moveTo(point) else star.lineTo(point);
        }
        star.closeSubpath();

        ctx.setStrokeColor(.hex(0xF1C40F));
        ctx.setLineWidth(3);
        ctx.setLineJoin(.round);
        ctx.setLineDash(0, &.{ 9, 5 });
        ctx.addPath(star.asPath());
        ctx.strokePath();
    }

    // A gradient, clipped to a circle. Clipping only ever shrinks, so the
    // save/restore pair is what puts it back.
    {
        ctx.save();
        defer ctx.restore();

        ctx.addEllipseInRect(.init(32, 32, 120, 120));
        ctx.clip();

        const ramp = try cg.Gradient.initTwoColor(.hex(0x3498DB), .hex(0x9B59B6));
        defer ramp.deinit();
        ctx.drawLinearGradient(ramp, .init(32, 152), .init(152, 32), .both);
    }

    // Boolean path operations: a square with a bite taken out of it.
    {
        const square = try cg.Path.initRect(.init(200, 40, 100, 100));
        defer square.deinit();
        const bite = try cg.Path.initEllipse(.init(270, 110, 80, 80));
        defer bite.deinit();

        const carved = try square.subtracting(bite, false);
        defer carved.deinit();

        ctx.setFillColor(.hex(0xE74C3C));
        ctx.addPath(carved);
        ctx.fillPath();
    }

    // Overlapping translucent circles, composited as a group so that the
    // shared alpha applies once instead of per circle.
    {
        ctx.save();
        defer ctx.restore();

        ctx.setAlpha(0.55);
        ctx.beginTransparencyLayer();
        defer ctx.endTransparencyLayer();

        ctx.setFillColor(.hex(0xECF0F1));
        ctx.fillEllipseInRect(.init(360, 40, 70, 70));
        ctx.fillEllipseInRect(.init(395, 70, 70, 70));
    }

    try cg.imageio.writeContext(ctx, "shapes.png", .png, .{});
    std.debug.print("wrote shapes.png ({d}x{d})\n", .{ width, height });
}
