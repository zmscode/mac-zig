//! Gradients, transforms and layers -- a poster, written to a PNG.
//!
//!     zig build run-gradient

const std = @import("std");
const mac = @import("mac");
const cg = mac.cg;

const width = 420;
const height = 420;

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_allocator.deinit();
    const allocator = debug_allocator.allocator();

    const ctx = try cg.Context.initBitmap(.{ .width = width, .height = height });
    defer ctx.deinit();

    // A three-stop background gradient across the whole canvas.
    {
        const sky = try cg.Gradient.init(allocator, &.{
            .{ .location = 0, .color = .hex(0x0F2027) },
            .{ .location = 0.55, .color = .hex(0x203A43) },
            .{ .location = 1, .color = .hex(0x2C5364) },
        });
        defer sky.deinit();

        ctx.drawLinearGradient(sky, .init(0, 0), .init(0, height), .both);
    }

    // A radial glow, drawn with `screen` so it lightens what is behind it
    // instead of covering it.
    {
        ctx.save();
        defer ctx.restore();
        ctx.setBlendMode(.screen);

        const glow = try cg.Gradient.init(allocator, &.{
            .{ .location = 0, .color = cg.Rgba.hex(0xF1C40F).withAlpha(0.9) },
            .{ .location = 1, .color = cg.Rgba.hex(0xF1C40F).withAlpha(0) },
        });
        defer glow.deinit();

        ctx.drawRadialGradient(glow, .init(300, 320), 0, .init(300, 320), 140, .{});
    }

    // One ring drawn once into a layer, then stamped twelve times around a
    // circle. The layer is rasterised once; each stamp is a copy.
    {
        const ring = try cg.Layer.init(ctx, .init(40, 40));
        defer ring.deinit();

        {
            const into = ring.context().?;
            into.setStrokeColor(cg.Rgba.hex(0xECF0F1).withAlpha(0.85));
            into.setLineWidth(2);
            into.strokeEllipseInRect(.init(3, 3, 34, 34));
            into.setFillColor(.hex(0xE74C3C));
            into.fillEllipseInRect(.init(16, 16, 8, 8));
        }

        ctx.save();
        defer ctx.restore();
        ctx.translate(width / 2, height / 2);

        for (0..12) |i| {
            ctx.save();
            defer ctx.restore();

            const angle = @as(cg.Float, @floatFromInt(i)) * std.math.tau / 12.0;
            ctx.rotate(angle);
            ctx.translate(130, 0);
            // Undo the rotation so every stamp sits upright.
            ctx.rotate(-angle);
            ctx.drawLayerAtPoint(.init(-20, -20), ring);
        }
    }

    // A conic gradient in the middle, clipped to a circle.
    {
        ctx.save();
        defer ctx.restore();

        ctx.addEllipseInRect(.init(160, 160, 100, 100));
        ctx.clip();

        const wheel = try cg.Gradient.init(allocator, &.{
            .{ .location = 0, .color = .hex(0xE74C3C) },
            .{ .location = 0.33, .color = .hex(0x2ECC71) },
            .{ .location = 0.66, .color = .hex(0x3498DB) },
            .{ .location = 1, .color = .hex(0xE74C3C) },
        });
        defer wheel.deinit();

        ctx.drawConicGradient(wheel, .init(210, 210), 0);
    }

    if (!mac.features.imageio) return std.debug.print("built without -Dimageio: not writing {s}\n", .{"gradient.png"});
    try cg.imageio.writeContext(ctx, "gradient.png", .png, .{});
    std.debug.print("wrote gradient.png ({d}x{d})\n", .{ width, height });
}
