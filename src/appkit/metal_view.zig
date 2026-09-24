//! A view that shows Metal: backed by a `CAMetalLayer`, redrawn once per
//! display refresh, with the drawing done by Zig.
//!
//! ```zig
//! const Renderer = struct {
//!     pub fn draw(self: *Renderer, frame: appkit.MetalView.Frame) void {
//!         const commands = frame.queue.commandBuffer().?;
//!         const encoder = commands.renderCommandEncoderWithDescriptor(
//!             frame.renderPass(metal.clearColor(0.1, 0.1, 0.12, 1)),
//!         ).?;
//!         // ... draw ...
//!         encoder.endEncoding();
//!         frame.present(commands);
//!     }
//!
//!     pub fn resized(self: *Renderer, pixels: cg.Size) void { ... }   // optional
//! };
//!
//! var renderer: Renderer = .{};
//! const view = try appkit.MetalView.init(.{ .frame = rect }, &renderer, Renderer);
//! defer view.deinit();
//! window.setContentView(view.asView());
//! ```
//!
//! ## The loop
//!
//! Drawing is driven by a display link -- a callback timed to the screen
//! the view is on, at its refresh rate, ProMotion included -- which starts
//! when the view goes into a window and stops when it leaves one. Before
//! macOS 14, which has no display link for a view, a 60 Hz timer stands
//! in. Everything runs on the main thread, and each frame has its own
//! autorelease pool.
//!
//! A frame is skipped while the window is hidden or minimised, and when no
//! drawable is free -- which is how a frame that runs long shows up.

const std = @import("std");
const objc = @import("../objc/objc.zig");
const foundation = @import("../foundation/foundation.zig");
const cg = @import("../cg/cg.zig");
const metal = @import("../metal/metal.zig");
const errors = @import("../errors.zig");
const generated = @import("generated.zig");

const Error = errors.Error;

extern fn CACurrentMediaTime() f64;
extern var NSRunLoopCommonModes: objc.abi.Id;

pub const MetalView = struct {
    instance: Instance,

    pub const Options = struct {
        /// Where the view starts, in its superview's points.
        frame: cg.Rect,
        /// The GPU to draw with; null picks the system default.
        device: ?metal.Device = null,
        /// The drawable's pixel format. `bgra8_unorm` is what the display
        /// takes natively; `bgra8_unorm_srgb` for gamma-correct blending.
        pixel_format: metal.PixelFormat = .bgra8_unorm,
        /// Leave false unless the drawable's texture must be sampled or
        /// read back; true lets Metal keep it in a faster, write-only form.
        readable: bool = false,
    };

    /// One frame's worth of what `draw` needs.
    pub const Frame = struct {
        drawable: metal.MetalDrawable,
        /// The drawable's texture: what to render into.
        texture: metal.Texture,
        device: metal.Device,
        queue: metal.CommandQueue,
        /// In pixels -- points times the display's scale.
        size: cg.Size,
        /// Seconds since the view started drawing.
        time: f64,
        /// Seconds since the previous frame.
        delta: f64,
        /// How many frames came before this one.
        index: u64,

        /// A render pass into this frame's texture, cleared to `clear`
        /// first. Autoreleased.
        pub fn renderPass(self: Frame, clear: metal.ClearColor) metal.RenderPassDescriptor {
            const pass = metal.RenderPassDescriptor.renderPassDescriptor();
            const color = pass.colorAttachments().objectAtIndexedSubscript(0);
            color.setTexture(self.texture);
            color.setLoadAction(.clear);
            color.setClearColor(clear);
            color.setStoreAction(.store);
            return pass;
        }

        /// Schedules this frame's drawable to be shown when `commands`
        /// finishes, and commits them.
        pub fn present(self: Frame, commands: metal.CommandBuffer) void {
            commands.presentDrawable(self.drawable.into(metal.Drawable));
            commands.commit();
        }
    };

    /// A view that calls `Handlers.draw(context, frame)` each frame, and
    /// `Handlers.resized(context, pixels)` -- if there is one -- when its
    /// drawable changes size. `context` is a pointer that must outlive the
    /// view. Yours to `deinit`.
    pub fn init(options: Options, context: anytype, comptime Handlers: type) Error!MetalView {
        const C = @TypeOf(context);
        if (@typeInfo(C) != .pointer) @compileError("the context for a MetalView must be a pointer");
        if (!@hasDecl(Handlers, "draw")) @compileError(@typeName(Handlers) ++ " needs a draw(context, Frame) function");

        const Erased = struct {
            fn draw(pointer: ?*anyopaque, frame: Frame) void {
                Handlers.draw(@as(C, @ptrCast(@alignCast(pointer))), frame);
            }
            fn resized(pointer: ?*anyopaque, pixels: cg.Size) void {
                if (@hasDecl(Handlers, "resized")) Handlers.resized(@as(C, @ptrCast(@alignCast(pointer))), pixels);
            }
        };

        const gpu = if (options.device) |given| given.retain() else metal.createSystemDefaultDevice() orelse
            return Error.Failed;
        errdefer gpu.release();
        const queue = gpu.newCommandQueue() orelse return Error.Failed;
        errdefer queue.release();

        const metal_layer = metal.MetalLayer.new();
        metal_layer.setDevice(gpu);
        metal_layer.setPixelFormat(options.pixel_format);
        metal_layer.setFramebufferOnly(!options.readable);

        const instance = Instance.alloc().msgSend(Instance, "initWithFrame:", .{options.frame});
        instance.state().* = .{
            .context = @ptrCast(@constCast(context)),
            .draw = Erased.draw,
            .resized = Erased.resized,
            .device = gpu,
            .queue = queue,
            .layer = metal_layer,
        };

        // Layer-hosting: the view shows exactly this layer.
        const view = instance.into(generated.View);
        view.setLayer(metal_layer.object);
        view.setWantsLayer(true);
        instance.state().fitDrawable(instance);
        return .{ .instance = instance };
    }

    /// Stops drawing and releases the view. A window still showing it keeps
    /// its own reference.
    pub fn deinit(self: MetalView) void {
        self.instance.state().stop();
        self.instance.release();
    }

    /// The view, for `setContentView` and `addSubview`.
    pub fn asView(self: MetalView) generated.View {
        return self.instance.into(generated.View);
    }

    pub fn layer(self: MetalView) metal.MetalLayer {
        return self.instance.state().layer.?;
    }

    pub fn device(self: MetalView) metal.Device {
        return self.instance.state().device.?;
    }

    /// How many frames have been drawn.
    pub fn frameCount(self: MetalView) u64 {
        return self.instance.state().frames;
    }
};

const Instance = objc.Subclass(.{ .name = "MacZigMetalView", .superclass = generated.View }, struct {
    context: ?*anyopaque = null,
    draw: *const fn (?*anyopaque, MetalView.Frame) void = noDraw,
    resized: *const fn (?*anyopaque, cg.Size) void = noResize,
    device: ?metal.Device = null,
    queue: ?metal.CommandQueue = null,
    layer: ?metal.MetalLayer = null,
    ticker: ?objc.Object = null,
    pixels: cg.Size = .zero,
    started: f64 = 0,
    last: f64 = 0,
    frames: u64 = 0,

    const Self = @This();

    fn noDraw(_: ?*anyopaque, _: MetalView.Frame) void {}
    fn noResize(_: ?*anyopaque, _: cg.Size) void {}

    // -- NSView overrides, checked against the SDK -------------------------

    pub fn @"setFrameSize:"(self: *Self, size: cg.Size) void {
        const instance = Instance.fromState(self);
        instance.object.msgSendSuper(generated.View.class(), void, "setFrameSize:", .{size});
        self.fitDrawable(instance);
    }

    pub fn viewDidChangeBackingProperties(self: *Self) void {
        self.fitDrawable(Instance.fromState(self));
    }

    pub fn viewDidMoveToWindow(self: *Self) void {
        const view = Instance.fromState(self).into(generated.View);
        if (view.window() != null) self.start(Instance.fromState(self)) else self.stop();
    }

    pub fn isOpaque(_: *Self) bool {
        return true;
    }

    // -- the loop -----------------------------------------------------------

    /// Called by the display link, or the timer standing in for it.
    pub fn @"step:"(self: *Self, _: objc.Object) void {
        const pool = objc.AutoreleasePool.init();
        defer pool.deinit();

        const view = Instance.fromState(self).into(generated.View);
        const window = view.window() orelse return;
        if (!window.isVisible() or window.isMiniaturized()) return;
        if (self.pixels.width < 1 or self.pixels.height < 1) return;

        const drawable = self.layer.?.nextDrawable() orelse return;
        const now = CACurrentMediaTime();
        const frame: MetalView.Frame = .{
            .drawable = drawable,
            .texture = drawable.texture(),
            .device = self.device.?,
            .queue = self.queue.?,
            .size = self.pixels,
            .time = now - self.started,
            .delta = if (self.frames == 0) 0 else now - self.last,
            .index = self.frames,
        };
        self.last = now;
        self.frames += 1;
        self.draw(self.context, frame);
    }

    fn start(self: *Self, instance: Instance) void {
        if (self.ticker != null) return;
        self.started = CACurrentMediaTime();
        self.last = self.started;
        const main_loop = objc.getClass("NSRunLoop").?.msgSend(objc.Object, "mainRunLoop", .{});
        const modes: objc.Object = .{ .value = NSRunLoopCommonModes.? };

        if (instance.object.respondsTo("displayLinkWithTarget:selector:")) {
            // macOS 14: timed to whichever display the view is on.
            const link = instance.object.msgSend(objc.Object, "displayLinkWithTarget:selector:", .{ instance.object, objc.Sel.cached("step:") });
            link.msgSend(void, "addToRunLoop:forMode:", .{ main_loop, modes });
            self.ticker = link.retain();
        } else {
            const timer = objc.getClass("NSTimer").?.msgSend(objc.Object, "timerWithTimeInterval:target:selector:userInfo:repeats:", .{
                @as(f64, 1.0 / 60.0), instance.object, objc.Sel.cached("step:"), @as(?objc.Object, null), true,
            });
            main_loop.msgSend(void, "addTimer:forMode:", .{ timer, modes });
            self.ticker = timer.retain();
        }
    }

    /// Both a display link and a timer keep their target alive; stopping
    /// is what lets the view go.
    fn stop(self: *Self) void {
        const ticker = self.ticker orelse return;
        ticker.msgSend(void, "invalidate", .{});
        ticker.release();
        self.ticker = null;
    }

    /// Sizes the drawable to the view in pixels, and tells the renderer.
    fn fitDrawable(self: *Self, instance: Instance) void {
        const layer = self.layer orelse return;
        const view = instance.into(generated.View);
        const points = view.bounds().size;
        const pixels = view.convertSizeToBacking(points);
        if (pixels.width == self.pixels.width and pixels.height == self.pixels.height) return;
        layer.setContentsScale(if (points.width > 0) pixels.width / points.width else 1);
        layer.setDrawableSize(pixels);
        self.pixels = pixels;
        self.resized(self.context, pixels);
    }

    pub fn deinit(self: *Self) void {
        self.stop();
        if (self.layer) |l| l.release();
        if (self.queue) |q| q.release();
        if (self.device) |d| d.release();
    }
});
