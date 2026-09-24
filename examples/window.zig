//! A Mac app in Zig: a window, a view that draws with CoreGraphics, mouse
//! and keyboard, a menu bar, and work handed to a background queue and
//! back to the main thread.
//!
//!     zig build run-window
//!     zig build run-window -- --snapshot window.png   # draw once, save, quit
//!     zig build run-window -- --quit-after 2          # quit on a timer

const std = @import("std");
const mac = @import("mac");
const objc = mac.objc;
const appkit = mac.appkit;
const dispatch = mac.dispatch;
const cg = mac.cg;

const print = std.debug.print;

/// The view: a Zig struct whose fields are its state and whose `pub fn`s
/// override NSView's methods.
const Canvas = objc.Subclass(.{ .name = "MacZigExampleCanvas", .superclass = "NSView" }, struct {
    dots: [64]cg.Point = undefined,
    count: usize = 0,
    clicks: usize = 0,
    backdrop: ?cg.Gradient = null,

    const Self = @This();

    pub fn @"drawRect:"(self: *Self, _: cg.Rect) void {
        const ctx = appkit.app.currentContext() orelse return;
        const bounds = viewOf(Canvas.fromState(self)).bounds();

        // Made on first draw, kept, and released by `deinit` with the view.
        if (self.backdrop == null) self.backdrop = cg.Gradient.init(std.heap.page_allocator, &.{
            .{ .location = 0, .color = .hex(0x1B2436) },
            .{ .location = 1, .color = .hex(0x3A2B4F) },
        }) catch null;
        if (self.backdrop) |gradient| {
            ctx.drawLinearGradient(gradient, .init(0, 0), .init(0, bounds.size.height), .both);
        }

        for (self.dots[0..self.count], 0..) |dot, i| {
            const t: cg.Float = @as(cg.Float, @floatFromInt(i + 1)) / @as(cg.Float, @floatFromInt(self.count));
            ctx.setFillColor(cg.Rgba.hex(0x2ECC71).withAlpha(0.25 + 0.75 * t));
            ctx.fillEllipseInRect(.init(dot.x - 12, dot.y - 12, 24, 24));
        }

        if (mac.features.coretext) {
            const font = cg.text.Font.initSystem(15) catch return;
            defer font.deinit();
            var buffer: [96]u8 = undefined;
            const caption = std.fmt.bufPrint(&buffer, "click anywhere  ·  esc closes  ·  {d} click{s}", .{
                self.clicks, if (self.clicks == 1) "" else "s",
            }) catch return;
            ctx.setFillColor(.hex(0xECF0F1));
            cg.text.draw(ctx, caption, font, .init(16, 16), null) catch {};
        }
    }

    pub fn @"mouseDown:"(self: *Self, event: appkit.Event) void {
        const view = viewOf(Canvas.fromState(self));
        const where = view.convertPointFromView(event.locationInWindow(), null);
        if (self.count == self.dots.len) {
            std.mem.copyForwards(cg.Point, self.dots[0 .. self.dots.len - 1], self.dots[1..]);
            self.count -= 1;
        }
        self.dots[self.count] = where;
        self.count += 1;
        self.clicks += 1;
        view.setNeedsDisplay(true);
    }

    pub fn @"keyDown:"(self: *Self, event: appkit.Event) void {
        const escape = 53;
        if (event.keyCode() == escape) viewOf(Canvas.fromState(self)).window().?.performClose(null);
    }

    pub fn acceptsFirstResponder(_: *Self) bool {
        return true;
    }

    /// A click that brings the window forward also draws a dot, rather
    /// than only activating the window.
    pub fn @"acceptsFirstMouse:"(_: *Self, _: ?appkit.Event) bool {
        return true;
    }

    pub fn deinit(self: *Self) void {
        if (self.backdrop) |gradient| gradient.deinit();
    }
});

/// The typed `View`, for the inherited methods.
fn viewOf(canvas: Canvas) appkit.View {
    return appkit.View.from(canvas.object);
}

const App = struct {
    snapshot: ?[]const u8 = null,
    quit_after: ?f64 = null,
    window: ?appkit.Window = null,
    canvas: ?Canvas = null,
    answer: u64 = 0,

    pub fn launched(self: *App) void {
        const window = appkit.Window.alloc().initWithContentRectStyleMaskBackingDefer(
            .init(0, 0, 560, 360),
            .{ .titled = true, .closable = true, .miniaturizable = true, .resizable = true },
            .buffered,
            false,
        );
        window.setTitle(.literal("mac-zig"));
        window.setReleasedWhenClosed(false); // `self` releases it, after `run`

        const canvas = Canvas.alloc().msgSend(Canvas, "initWithFrame:", .{cg.Rect.init(0, 0, 560, 360)});
        window.setContentView(viewOf(canvas));
        _ = window.makeFirstResponder(viewOf(canvas).into(appkit.Responder));
        window.center();
        window.makeKeyAndOrderFront(null);
        self.window = window;
        self.canvas = canvas;

        if (self.snapshot) |path| {
            saveSnapshot(viewOf(canvas), path) catch |err| print("snapshot failed: {t}\n", .{err});
            appkit.app.stop();
            return;
        }
        if (self.quit_after) |seconds| dispatch.Queue.main().after(seconds, self, struct {
            fn quit(_: *App) void {
                appkit.app.requestQuit();
            }
        }.quit);

        // Some work off the main thread, and the answer brought back to it:
        // AppKit may only be touched from the main thread.
        dispatch.Queue.global(.utility).async(self, work);
    }

    fn work(self: *App) void {
        var sum: u64 = 0;
        for (0..50_000_000) |i| sum +%= i * i;
        self.answer = sum;
        appkit.app.onMain(self, showAnswer);
    }

    fn showAnswer(self: *App) void {
        if (self.window) |window| window.setTitle(.literal("mac-zig — computed in the background"));
        print("background work done: {d}\n", .{self.answer});
    }

    pub fn willQuit(self: *App) void {
        if (self.canvas) |canvas| print("quitting after {d} click(s)\n", .{canvas.state().clicks});
    }

    fn deinit(self: *App) void {
        if (self.canvas) |canvas| canvas.release();
        if (self.window) |window| window.release();
    }
};

fn saveSnapshot(view: appkit.View, path: []const u8) !void {
    if (!mac.features.imageio) return error.ImageIoDisabled;
    const bounds = view.bounds();
    const rep = view.bitmapImageRepForCachingDisplayInRect(bounds) orelse return error.Failed;
    view.cacheDisplayInRectToBitmapImageRep(bounds, rep);
    const image = cg.Image.fromRaw(@ptrCast(rep.CGImage() orelse return error.Failed)).?; // borrowed
    try cg.imageio.writeImage(image, path, .png, .{});
    print("wrote {s} ({d}x{d})\n", .{ path, image.width(), image.height() });
}

pub fn main(init: std.process.Init) !void {
    if (!mac.features.appkit) {
        print("built with -Dappkit=false; there is no AppKit to show a window with\n", .{});
        return;
    }

    var app: App = .{};
    defer app.deinit(); // runs, because `run` returns when the app quits

    const args = try init.minimal.args.toSlice(init.arena.allocator());
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--snapshot") and i + 1 < args.len) {
            i += 1;
            app.snapshot = args[i];
        } else if (std.mem.eql(u8, args[i], "--quit-after") and i + 1 < args.len) {
            i += 1;
            app.quit_after = try std.fmt.parseFloat(f64, args[i]);
        }
    }

    appkit.app.run(.{ .name = "mac-zig" }, &app, App);
    print("run returned; cleaning up\n", .{});
}
