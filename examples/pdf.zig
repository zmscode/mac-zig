//! Writing a multi-page PDF, then reading it back and rasterising a page.
//!
//!     zig build run-pdf

const std = @import("std");
const mac = @import("mac");
const cg = mac.cg;

/// US Letter, in PDF points -- 72 to the inch.
const page_box = cg.Rect.init(0, 0, 612, 792);

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    defer _ = debug_allocator.deinit();
    const allocator = debug_allocator.allocator();

    try write(allocator, "out.pdf");
    std.debug.print("wrote out.pdf (3 pages, {f})\n", .{page_box.size});

    try readBack("out.pdf");
}

fn write(allocator: std.mem.Allocator, path: []const u8) !void {
    const ctx = try cg.Context.initPdfFile(allocator, path, .{
        .media_box = page_box,
        .title = "mac-zig sample",
        .author = "mac-zig",
        .creator = "zig build run-pdf",
    });
    defer ctx.deinit();
    // A PDF context is not finished when it is released -- without this
    // the file has no trailer and will not open.
    defer ctx.closePdf();

    for (0..3) |i| {
        ctx.beginPdfPage();
        defer ctx.endPdfPage();

        const shade = 0.96 - @as(cg.Float, @floatFromInt(i)) * 0.06;
        ctx.setFillGray(.{ .level = shade });
        ctx.fillRect(page_box);

        // A band across the top of the page. PDF pages use the same
        // bottom-left origin as every other context.
        ctx.setFillColor(.hex(0x2C5364));
        ctx.fillRect(.init(0, page_box.height() - 120, page_box.width(), 120));

        // A PDF context is unflipped, so the text matrix is already
        // right and nothing has to be undone.
        if (comptime mac.features.coretext) {
            const font = try cg.text.Font.initSystem(28);
            defer font.deinit();

            ctx.setFillColor(.white);
            var heading: [32]u8 = undefined;
            const label = try std.fmt.bufPrint(&heading, "Page {d} of 3", .{i + 1});
            try cg.text.draw(ctx, label, font, .init(56, page_box.height() - 78), null);
        }

        // A little vector content so the page is not just rectangles.
        ctx.setStrokeColor(.hex(0x2ECC71));
        ctx.setLineWidth(6);
        ctx.setLineCap(.round);

        const steps = 40;
        ctx.beginPath();
        for (0..steps + 1) |s| {
            const t = @as(cg.Float, @floatFromInt(s)) / steps;
            const x = 56 + t * (page_box.width() - 112);
            const phase = @as(cg.Float, @floatFromInt(i)) * 0.8;
            const y = 400 + @sin(t * std.math.tau + phase) * 120;
            if (s == 0) ctx.moveTo(.init(x, y)) else ctx.lineTo(.init(x, y));
        }
        ctx.strokePath();

        // A link on every page but the last.
        if (i < 2) {
            const url = try cg.cf.Url.initFilePath("out.pdf");
            defer url.deinit();
            ctx.setPdfUrlForRect(url, .init(56, 96, 200, 24));
        }
    }
}

fn readBack(path: []const u8) !void {
    const document = try cg.pdf.Document.initFile(path);
    defer document.deinit();

    std.debug.print("read back: PDF {f}, {d} pages, encrypted={}\n", .{
        document.version(),
        document.pageCount(),
        document.isEncrypted(),
    });

    var it = document.pages();
    while (it.next()) |page| {
        std.debug.print("  page {d}: media {f}\n", .{ page.number(), page.box(.media) });
    }

    // Rasterise page 2 at 2x into a bitmap, the way a thumbnailer would.
    const page = document.page(2) orelse return error.MissingPage;
    const scale = 2.0;
    const box = page.box(.media);

    const ctx = try cg.Context.initBitmap(.{
        .width = @intFromFloat(box.width() * scale),
        .height = @intFromFloat(box.height() * scale),
    });
    defer ctx.deinit();

    // PDF pages are drawn on transparency, so give it a page colour first.
    ctx.setFillColor(.white);
    ctx.fillRect(ctx.bitmapBounds());

    ctx.scale(scale, scale);
    ctx.concat(page.drawingTransform(.media, box, 0, true));
    ctx.drawPdfPage(page);

    if (!mac.features.imageio) return std.debug.print("built without -Dimageio: not writing {s}\n", .{"page-2.png"});
    try cg.imageio.writeContext(ctx, "page-2.png", .png, .{});
    std.debug.print("wrote page-2.png ({d}x{d})\n", .{
        ctx.bitmapWidth(),
        ctx.bitmapHeight(),
    });
}
