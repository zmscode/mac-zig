//! Tests that use the package the way a dependent does -- through the
//! public `cg` module only, with no access to the internals.

const std = @import("std");
const mac = @import("mac");
const cg = mac.cg;

test "the shape of a drawing program" {
    const ctx = try cg.Context.initBitmap(.{ .width = 64, .height = 64 });
    defer ctx.deinit();

    ctx.setFillColor(.hex(0x1E2430));
    ctx.fillRect(ctx.bitmapBounds());

    ctx.setFillColor(.hex(0x2ECC71));
    ctx.fillEllipseInRect(.init(8, 8, 48, 48));

    ctx.setStrokeColor(.white);
    ctx.setLineWidth(2);
    ctx.strokeEllipseInRect(.init(8, 8, 48, 48));

    const snapshot = try ctx.createImage();
    defer snapshot.deinit();

    try std.testing.expectEqual(@as(usize, 64), snapshot.width());
    try std.testing.expectEqual(@as(usize, 64), snapshot.height());
}

test "an image drawn into an unflipped context keeps its orientation" {
    // Two rows: the image's own top row is red, its bottom row is blue.
    const pixels = [_]u8{
        255, 0, 0,   255,
        0,   0, 255, 255,
    };
    const provider = try cg.DataProvider.initCopy(&pixels);
    defer provider.deinit();

    const space = try cg.ColorSpace.deviceRgb();
    defer space.deinit();

    const source = try cg.Image.init(.{
        .width = 1,
        .height = 2,
        .bytes_per_row = 4,
        .space = space,
        .bitmap_info = .rgba8888,
        .provider = provider,
    });
    defer source.deinit();

    const upright = try cg.Context.initBitmap(.{
        .width = 1,
        .height = 2,
        .bitmap_info = .rgba8888,
    });
    defer upright.deinit();
    upright.drawImage(upright.bitmapBounds(), source);

    // Memory row 0 is the top row of the result, and it is the image's own
    // top row: no flip happened.
    try std.testing.expectEqual([3]u8{ 255, 0, 0 }, rowRgb(upright, 0));
    try std.testing.expectEqual([3]u8{ 0, 0, 255 }, rowRgb(upright, 1));
}

test "flipping the context flips images, and drawImageUpright undoes it" {
    const pixels = [_]u8{
        255, 0, 0,   255,
        0,   0, 255, 255,
    };
    const provider = try cg.DataProvider.initCopy(&pixels);
    defer provider.deinit();

    const space = try cg.ColorSpace.deviceRgb();
    defer space.deinit();

    const source = try cg.Image.init(.{
        .width = 1,
        .height = 2,
        .bytes_per_row = 4,
        .space = space,
        .bitmap_info = .rgba8888,
        .provider = provider,
    });
    defer source.deinit();

    const flipped = try cg.Context.initBitmap(.{
        .width = 1,
        .height = 2,
        .bitmap_info = .rgba8888,
    });
    defer flipped.deinit();
    flipped.flipVertically(2);

    flipped.drawImage(.init(0, 0, 1, 2), source);
    try std.testing.expectEqual([3]u8{ 0, 0, 255 }, rowRgb(flipped, 0));

    flipped.drawImageUpright(.init(0, 0, 1, 2), source);
    try std.testing.expectEqual([3]u8{ 255, 0, 0 }, rowRgb(flipped, 0));
    try std.testing.expectEqual([3]u8{ 0, 0, 255 }, rowRgb(flipped, 1));
}

test "a drawing round-trips through a PNG file" {
    if (!mac.features.imageio) return error.SkipZigTest;

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const path = try std.fmt.allocPrint(
        std.testing.allocator,
        ".zig-cache/tmp/{s}/round-trip.png",
        .{tmp.sub_path},
    );
    defer std.testing.allocator.free(path);

    const ctx = try cg.Context.initBitmap(.{ .width = 10, .height = 4 });
    defer ctx.deinit();
    ctx.setFillColor(.hex(0x2ECC71));
    ctx.fillRect(ctx.bitmapBounds());

    try cg.imageio.writeContext(ctx, path, .png, .{});

    const loaded = try cg.imageio.readImage(path);
    defer loaded.deinit();
    try std.testing.expectEqual(@as(usize, 10), loaded.width());
    try std.testing.expectEqual(@as(usize, 4), loaded.height());
}

test "a PDF written to memory reads back with the pages it was given" {
    const buffer = try cg.cf.MutableData.init(0);
    defer buffer.deinit();

    {
        const ctx = try cg.Context.initPdfData(std.testing.allocator, buffer, .{
            .media_box = .init(0, 0, 200, 100),
            .title = "mac-zig round trip",
        });
        defer ctx.deinit();

        for (0..3) |i| {
            ctx.beginPdfPage();
            ctx.setFillColor(.gray(@as(cg.Float, @floatFromInt(i)) / 3));
            ctx.fillRect(.init(10, 10, 180, 80));
            ctx.endPdfPage();
        }
        // Without this the document has no trailer and will not open.
        ctx.closePdf();
    }

    try std.testing.expect(buffer.bytes().len > 0);
    try std.testing.expectEqualSlices(u8, "%PDF", buffer.bytes()[0..4]);

    const document = try cg.pdf.Document.initData(buffer.asData());
    defer document.deinit();

    try std.testing.expectEqual(@as(usize, 3), document.pageCount());
    try std.testing.expect(document.page(0) == null);
    try std.testing.expect(document.page(4) == null);

    const first = document.page(1).?;
    try std.testing.expectEqual(@as(usize, 1), first.number());
    try std.testing.expect(first.box(.media).eql(cg.Rect.init(0, 0, 200, 100)));

    var seen: usize = 0;
    var it = document.pages();
    while (it.next()) |_| seen += 1;
    try std.testing.expectEqual(@as(usize, 3), seen);
}

test "a PDF page renders back into a bitmap" {
    const buffer = try cg.cf.MutableData.init(0);
    defer buffer.deinit();

    {
        const ctx = try cg.Context.initPdfData(std.testing.allocator, buffer, .{
            .media_box = .init(0, 0, 40, 40),
        });
        defer ctx.deinit();
        ctx.beginPdfPage();
        ctx.setFillColor(.rgb(1, 0, 0));
        ctx.fillRect(.init(0, 0, 40, 40));
        ctx.endPdfPage();
        ctx.closePdf();
    }

    const document = try cg.pdf.Document.initData(buffer.asData());
    defer document.deinit();

    const ctx = try cg.Context.initBitmap(.{ .width = 40, .height = 40 });
    defer ctx.deinit();
    ctx.drawPdfPage(document.page(1).?);

    // B, G, R, A -- the page was filled red.
    try std.testing.expectEqual(@as(u8, 255), rowRgb(ctx, 20)[2]);
}

test "text measures and draws through the public API" {
    if (!mac.features.coretext) return error.SkipZigTest;

    const font = try cg.text.Font.initSystem(16);
    defer font.deinit();

    const metrics = try cg.text.measure("mac-zig", font);
    try std.testing.expect(metrics.width > 0);
    try std.testing.expect(metrics.height() > 0);

    const ctx = try cg.Context.initBitmap(.{ .width = 120, .height = 32 });
    defer ctx.deinit();
    ctx.setFillColor(.white);
    try cg.text.draw(ctx, "mac-zig", font, .init(4, 8), null);

    try std.testing.expect(paintedPixels(ctx) > 0);
}

test "power reads through the public API" {
    if (!mac.features.iokit) return error.SkipZigTest;

    const state = try mac.iokit.power.snapshot(std.testing.allocator);
    defer state.deinit(std.testing.allocator);

    // Whatever this machine is, it is being powered by something.
    try std.testing.expect(state.providing != .unknown);

    if (state.battery()) |b| {
        try std.testing.expect(b.percent <= 100);
        try std.testing.expect(b.is_present);
        // On battery, the machine cannot also be charging.
        if (state.onBattery()) try std.testing.expect(!b.is_charging);
    }
}

test "objc: CoreGraphics geometry goes through a message unchanged" {
    if (!mac.features.objc) return error.SkipZigTest;
    const objc = mac.objc;

    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    // NSValue boxes a CGRect, so a cg.Rect goes in and comes back as is.
    const rect: cg.Rect = .init(10, 20, 300, 400);
    const boxed = objc.getClass("NSValue").?.msgSend(objc.Object, "valueWithRect:", .{rect});
    try std.testing.expectEqual(rect, boxed.msgSend(cg.Rect, "rectValue", .{}));
}

test "objc: a cf.String is an NSString" {
    if (!mac.features.objc) return error.SkipZigTest;
    const objc = mac.objc;

    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const text = try mac.cf.String.init("toll-free");
    defer text.deinit();

    const upper = objc.Object.fromCf(text).msgSend(objc.Object, "uppercaseString", .{});
    const copy = try upper.asCf(mac.cf.String).?.toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(copy);
    try std.testing.expectEqualStrings("TOLL-FREE", copy);
}

test "the raw layer is reachable for anything not wrapped" {
    // The wrapper does not cover CGColorSpaceGetColorTableCount, so this is
    // what dropping through to `cg.raw` looks like.
    const space = try cg.ColorSpace.deviceRgb();
    defer space.deinit();

    const count = cg.raw.CGColorSpaceGetColorTableCount(space.toRaw());
    try std.testing.expectEqual(@as(usize, 0), count);
}

// -- helpers ----------------------------------------------------------

fn rowRgb(ctx: cg.Context, row: usize) [3]u8 {
    const data = ctx.bitmapData().?;
    const offset = row * ctx.bitmapBytesPerRow();
    return .{ data[offset], data[offset + 1], data[offset + 2] };
}

fn paintedPixels(ctx: cg.Context) usize {
    const data = ctx.bitmapData().?;
    var painted: usize = 0;
    var i: usize = 3;
    while (i < data.len) : (i += 4) {
        if (data[i] != 0) painted += 1;
    }
    return painted;
}
