const std = @import("std");
const objc = @import("../objc/objc.zig");
const foundation = @import("../foundation/foundation.zig");
const cg = @import("../cg/cg.zig");
const appkit = @import("appkit.zig");
const generated = @import("generated.zig");

test "every generated method compiles" {
    // Taking each method's address makes the compiler analyse its body --
    // including each selector's colon count against the arguments. (Merely
    // naming it does not.) A method with a block parameter is generic, has
    // no address, and is checked only when called.
    @setEvalBranchQuota(1_000_000);
    inline for (@typeInfo(generated).@"struct".decl_names) |name| {
        const T = @field(generated, name);
        if (@TypeOf(T) == type and @typeInfo(T) == .@"struct" and (@hasDecl(T, "class_name") or @hasDecl(T, "protocol_name"))) {
            inline for (@typeInfo(T).@"struct".decl_names) |decl| {
                const member = @field(T, decl);
                const info = @typeInfo(@TypeOf(member));
                if (info == .@"fn" and !info.@"fn".is_generic) std.mem.doNotOptimizeAway(&member);
            }
        }
        // Every signature table resolves -- each is a function type built
        // from the other generated types.
        if (@TypeOf(T) == type and @typeInfo(T) == .@"struct" and @hasDecl(T, "signatures")) {
            inline for (@typeInfo(T.signatures).@"struct".decl_names) |decl| {
                std.debug.assert(@typeInfo(@field(T.signatures, decl)) == .@"fn");
            }
        }
    }
}

test "option sets match the SDK's constants" {
    const mask: appkit.WindowStyleMask = .{ .titled = true, .closable = true, .resizable = true };
    // NSWindowStyleMaskTitled | Closable | Resizable
    try std.testing.expectEqual(@as(u64, 1 | 2 | 8), @backingInt(mask));
    try std.testing.expectEqual(@as(u64, 1 << 15), @backingInt(appkit.WindowStyleMask{ .full_size_content_view = true }));
    try std.testing.expectEqual(@as(u64, 0), @backingInt(appkit.WindowStyleMask.borderless));
    try std.testing.expectEqual(@as(objc.UInteger, 2), @backingInt(appkit.BackingStoreType.buffered));
}

test "inherited methods need no conversion, and structs and cg types come through" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();
    _ = appkit.Application.sharedApplication();

    const window = appkit.Window.alloc().initWithContentRectStyleMaskBackingDefer(
        .init(0, 0, 100, 100),
        .borderless,
        .buffered,
        true,
    );
    window.setReleasedWhenClosed(false);
    defer window.release();

    // NSResponder's, called on the window directly.
    try std.testing.expect(window.acceptsFirstResponder() or !window.acceptsFirstResponder());
    try std.testing.expect(window.nextResponder() == null or window.nextResponder() != null);

    // NSEdgeInsets, as a generated extern struct.
    if (appkit.Screen.mainScreen()) |screen| {
        const insets: appkit.EdgeInsets = screen.safeAreaInsets();
        try std.testing.expect(insets.top >= 0 and insets.left >= 0);
    }

    // CGColorRef comes back as cg.Color, not a bare pointer.
    const red = appkit.Color.redColor();
    const cg_color: cg.Color = red.CGColor();
    try std.testing.expectEqual(@as(cg.Float, 1), cg_color.components()[0]);
}

test "inheritance is checked at compile time" {
    const window = appkit.Window.from(.{ .value = @ptrFromInt(0x1000) });
    try std.testing.expect(window.into(appkit.Responder).object.value == window.object.value);
    try std.testing.expect(window.into(objc.Object).value == window.object.value);
    // window.into(appkit.View) would not compile.
}

test "a window, through the generated wrappers" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    _ = appkit.Application.sharedApplication();

    const window = appkit.Window.alloc().initWithContentRectStyleMaskBackingDefer(
        .init(100, 100, 320, 200),
        .{ .titled = true, .closable = true },
        .buffered,
        true,
    );
    // Closing would release it; this test releases it itself.
    window.setReleasedWhenClosed(false);
    defer window.release();

    window.setTitle(.literal("mac-zig test"));
    try std.testing.expect(window.title().eql(.literal("mac-zig test")));

    const style = window.styleMask();
    try std.testing.expect(style.titled and style.closable and !style.resizable);

    window.setContentSize(.init(400, 300));
    const content = window.contentRectForFrameRect(window.frame());
    try std.testing.expectEqual(@as(cg.Float, 400), content.size.width);
    try std.testing.expect(!window.isVisible());

    const view = window.contentView().?;
    try std.testing.expect(view.into(objc.Object).isKindOf(appkit.View.class()));
}

test "screens come back as a typed array" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const screens = appkit.Screen.screens();
    if (screens.count() == 0) return error.SkipZigTest; // headless
    const main = screens.at(0).?;
    try std.testing.expect(main.frame().size.width > 0);
    try std.testing.expect(main.backingScaleFactor() >= 1);
}

// -- views that draw ------------------------------------------------------

const dispatch = @import("../dispatch/dispatch.zig");

const Swatch = objc.Subclass(.{ .name = "MacZigTestSwatch", .superclass = appkit.View }, struct {
    draws: u32 = 0,

    pub fn @"drawRect:"(self: *@This(), _: cg.Rect) void {
        self.draws += 1;
        const ctx = appkit.app.currentContext() orelse return;
        ctx.setFillColor(.rgb(1, 0, 0));
        ctx.fillRect(.init(0, 0, 10, 20)); // the bottom half of a 10x40 view
    }
});

test "a view drawn with cg, rendered offscreen" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const swatch = Swatch.alloc().msgSend(Swatch, "initWithFrame:", .{cg.Rect.init(0, 0, 10, 40)});
    defer swatch.release();
    const view = appkit.View.from(swatch.object);

    const rep = view.bitmapImageRepForCachingDisplayInRect(view.bounds()).?;
    view.cacheDisplayInRectToBitmapImageRep(view.bounds(), rep);
    try std.testing.expect(swatch.state().draws >= 1);

    // Image-rep rows run top to bottom; the red half is at the bottom.
    // pixelsWide is NSImageRep's, the superclass.
    const scale: objc.Integer = @divExact(rep.into(appkit.ImageRep).pixelsWide(), 10);
    const top = rep.colorAtXY(5 * scale, 5 * scale).?;
    const bottom = rep.colorAtXY(5 * scale, 35 * scale).?;
    try std.testing.expect(bottom.alphaComponent() > 0.9);
    try std.testing.expect(bottom.object.msgSend(cg.Float, "redComponent", .{}) > 0.9);
    try std.testing.expect(top.alphaComponent() < 0.1);
}

// -- running an application ----------------------------------------------

test "run launches, services the main queue, and returns on quit" {
    const Run = struct {
        did_launch: bool = false,
        dispatched: bool = false,
        refusals: u32 = 0,
        quitting: bool = false,

        pub fn launched(self: *@This()) void {
            self.did_launch = true;
            dispatch.Queue.main().after(0.05, self, onMainQueue);
        }

        fn onMainQueue(self: *@This()) void {
            self.dispatched = dispatch.isMainThread();
            appkit.app.requestQuit(); // refused once, below
            appkit.app.requestQuit(); // then allowed
        }

        pub fn shouldQuit(self: *@This()) bool {
            if (self.refusals == 0) {
                self.refusals += 1;
                return false;
            }
            return true;
        }

        pub fn willQuit(self: *@This()) void {
            self.quitting = true;
        }
    };

    var state: Run = .{};
    // No Dock icon or menu bar for a test, and nothing brought forward.
    appkit.app.run(.{ .activation_policy = .accessory, .activate = false }, &state, Run);

    // Getting here at all is the point: quitting returned rather than exited.
    try std.testing.expect(state.did_launch);
    try std.testing.expect(state.dispatched);
    try std.testing.expectEqual(@as(u32, 1), state.refusals);
    try std.testing.expect(state.quitting);
}

// -- events reaching a view -----------------------------------------------

const Pad = objc.Subclass(.{ .name = "MacZigTestPad", .superclass = appkit.View }, struct {
    last_click: ?cg.Point = null,
    last_key: ?c_ushort = null,

    pub fn @"mouseDown:"(self: *@This(), event: appkit.Event) void {
        const view = appkit.View.from(Pad.fromState(self).object);
        self.last_click = view.convertPointFromView(event.locationInWindow(), null);
    }

    pub fn @"keyDown:"(self: *@This(), event: appkit.Event) void {
        self.last_key = event.keyCode();
    }

    pub fn acceptsFirstResponder(_: *@This()) bool {
        return true;
    }

    /// Without this, a click on a window that is not active only
    /// activates it; the view never hears about it.
    pub fn @"acceptsFirstMouse:"(_: *@This(), _: ?appkit.Event) bool {
        return true;
    }
});

test "mouse and key events reach a view through the window" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();
    _ = appkit.Application.sharedApplication();

    const window = appkit.Window.alloc().initWithContentRectStyleMaskBackingDefer(
        .init(0, 0, 200, 100),
        .borderless,
        .buffered,
        false,
    );
    window.setReleasedWhenClosed(false);
    defer window.release();

    const pad = Pad.alloc().msgSend(Pad, "initWithFrame:", .{cg.Rect.init(0, 0, 200, 100)});
    defer pad.release();
    const view = appkit.View.from(pad.object);
    window.setContentView(view);
    try std.testing.expect(window.makeFirstResponder(view.into(appkit.Responder)));

    // A window that is not on screen drops mouse events, so this one is
    // ordered in -- fully transparent, so nothing appears.
    window.setAlphaValue(0);
    window.orderFront(null);
    defer window.orderOut(null);

    // Built by hand and handed to the window: no real input is involved,
    // so the user's own mouse and keyboard are left alone.
    const click = appkit.Event.mouseEventWithTypeLocationModifierFlagsTimestampWindowNumberContextEventNumberClickCountPressure(
        .left_mouse_down,
        .init(30, 40),
        .{},
        0,
        window.windowNumber(),
        null,
        0,
        1,
        1,
    ).?;
    window.sendEvent(click);
    try std.testing.expectEqual(cg.Point.init(30, 40), pad.state().last_click.?);

    const key = appkit.Event.keyEventWithTypeLocationModifierFlagsTimestampWindowNumberContextCharactersCharactersIgnoringModifiersIsARepeatKeyCode(
        .key_down,
        .zero,
        .{},
        0,
        window.windowNumber(),
        null,
        .literal("\x1b"),
        .literal("\x1b"),
        false,
        53,
    ).?;
    window.sendEvent(key);
    try std.testing.expectEqual(@as(?c_ushort, 53), pad.state().last_key);
}

// -- Metal on screen -----------------------------------------------------

const build_options = @import("mac_build_options");
const raw = @import("mac_raw");

test "a MetalView draws frames from its display link" {
    if (!build_options.metal) return error.SkipZigTest;
    const metal = @import("../metal/metal.zig");

    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();
    _ = appkit.Application.sharedApplication();
    if (metal.createSystemDefaultDevice()) |device| device.release() else return error.SkipZigTest;

    const Counter = struct {
        frames: u32 = 0,
        last_size: cg.Size = .zero,
        resizes: u32 = 0,
        increasing_time: bool = true,
        last_time: f64 = -1,

        pub fn draw(self: *@This(), frame: appkit.MetalView.Frame) void {
            self.frames += 1;
            self.last_size = frame.size;
            if (frame.time < self.last_time) self.increasing_time = false;
            self.last_time = frame.time;
            const commands = frame.queue.commandBuffer().?;
            const encoder = commands.renderCommandEncoderWithDescriptor(frame.renderPass(metal.clearColor(0, 1, 0, 1))).?;
            encoder.endEncoding();
            frame.present(commands);
        }

        pub fn resized(self: *@This(), _: cg.Size) void {
            self.resizes += 1;
        }
    };
    var counter: Counter = .{};

    const view = try appkit.MetalView.init(.{ .frame = .init(0, 0, 64, 32) }, &counter, Counter);
    defer view.deinit();
    try std.testing.expect(counter.resizes >= 1);

    const window = appkit.Window.alloc().initWithContentRectStyleMaskBackingDefer(.init(0, 0, 64, 32), .borderless, .buffered, false);
    window.setReleasedWhenClosed(false);
    defer window.release();
    window.setContentView(view.asView());
    // On screen, so the display link runs -- transparent, so nothing shows.
    window.setAlphaValue(0);
    window.orderFront(null);
    defer window.orderOut(null);

    _ = raw.CFRunLoopRunInMode(raw.kCFRunLoopDefaultMode, 0.5, 0);

    try std.testing.expect(counter.frames >= 3);
    try std.testing.expect(counter.increasing_time);
    // Pixels, not points: at least the view's size, more on a Retina screen.
    try std.testing.expect(counter.last_size.width >= 64 and counter.last_size.height >= 32);
    try std.testing.expectEqual(counter.last_size.width / 64, counter.last_size.height / 32);
    try std.testing.expectEqual(@as(u64, counter.frames), view.frameCount());
}
