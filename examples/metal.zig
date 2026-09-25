//! Metal from Zig: a shader compiled at run time, a pipeline, and a
//! spinning triangle drawn at the display's refresh rate.
//!
//!     zig build run-metal
//!     zig build run-metal -- --snapshot metal.png   # one frame, offscreen, to a PNG
//!     zig build run-metal -- --quit-after 2         # quit on a timer, report the frame rate

const std = @import("std");
const mac = @import("mac");
const objc = mac.objc;
const appkit = mac.appkit;
const metal = mac.metal;
const cg = mac.cg;

const print = std.debug.print;

const shader =
    \\#include <metal_stdlib>
    \\using namespace metal;
    \\
    \\struct Uniforms { float angle; float aspect; };
    \\struct Varyings { float4 position [[position]]; float4 color; };
    \\
    \\vertex Varyings vertex_main(uint id [[vertex_id]], constant Uniforms &u [[buffer(0)]]) {
    \\    const float2 corners[3] = { float2(0, 0.8), float2(-0.7, -0.5), float2(0.7, -0.5) };
    \\    const float3 colors[3] = { float3(1, 0.3, 0.35), float3(0.2, 0.8, 0.45), float3(0.3, 0.55, 1) };
    \\    float c = cos(u.angle), s = sin(u.angle);
    \\    float2 p = float2(c * corners[id].x - s * corners[id].y, s * corners[id].x + c * corners[id].y);
    \\    p.x /= u.aspect;
    \\    return { float4(p, 0, 1), float4(colors[id], 1) };
    \\}
    \\
    \\fragment float4 fragment_main(Varyings in [[stage_in]]) {
    \\    return in.color;
    \\}
;

/// Matches `Uniforms` in the shader.
const Uniforms = extern struct {
    angle: f32,
    aspect: f32,
};

const pixel_format: metal.PixelFormat = .bgra8_unorm;
const background = metal.clearColor(0.08, 0.09, 0.12, 1);

/// The pipeline, and drawing the triangle with it. Shared by the window and
/// the offscreen snapshot.
const Renderer = struct {
    pipeline: metal.RenderPipelineState,
    aspect: f32 = 1,
    frames: u64 = 0,

    fn init(device: metal.Device) !Renderer {
        var details: mac.foundation.ErrorObject = undefined;
        const library = metal.newLibrary(device, shader, &details) catch |err| {
            defer details.deinit();
            print("shader: {f}\n", .{details});
            return err;
        };
        defer library.release();
        const vertex_fn = metal.function(library, "vertex_main").?;
        defer vertex_fn.release();
        const fragment_fn = metal.function(library, "fragment_main").?;
        defer fragment_fn.release();

        const descriptor = metal.RenderPipelineDescriptor.new();
        defer descriptor.release();
        descriptor.setVertexFunction(vertex_fn);
        descriptor.setFragmentFunction(fragment_fn);
        descriptor.colorAttachments().objectAtIndexedSubscript(0).setPixelFormat(pixel_format);
        return .{ .pipeline = try metal.newRenderPipelineState(device, descriptor, null) };
    }

    fn deinit(self: *Renderer) void {
        self.pipeline.release();
    }

    fn encode(self: *Renderer, encoder: metal.RenderCommandEncoder, time: f64) void {
        const uniforms: Uniforms = .{ .angle = @floatCast(time * 0.9), .aspect = self.aspect };
        encoder.setRenderPipelineState(self.pipeline);
        encoder.setVertexBytesLengthAtIndex(&uniforms, @sizeOf(Uniforms), 0);
        encoder.drawPrimitivesVertexStartVertexCount(.triangle, 0, 3);
        encoder.endEncoding();
    }

    // -- appkit.MetalView's handlers ---------------------------------------

    pub fn draw(self: *Renderer, frame: appkit.MetalView.Frame) void {
        const commands = frame.queue.commandBuffer().?;
        self.encode(commands.renderCommandEncoderWithDescriptor(frame.renderPass(background)).?, frame.time);
        frame.present(commands);
        self.frames += 1;
    }

    pub fn resized(self: *Renderer, pixels: cg.Size) void {
        self.aspect = @floatCast(pixels.width / pixels.height);
    }
};

const App = struct {
    renderer: *Renderer,
    quit_after: ?f64 = null,
    view: ?appkit.MetalView = null,
    window: ?appkit.Window = null,
    started: std.Io.Timestamp = undefined,

    pub fn launched(self: *App) void {
        const rect: cg.Rect = .init(0, 0, 640, 480);
        const view = appkit.MetalView.init(.{ .frame = rect, .pixel_format = pixel_format }, self.renderer, Renderer) catch {
            print("no Metal device\n", .{});
            appkit.app.stop();
            return;
        };
        const window = appkit.Window.alloc().initWithContentRectStyleMaskBackingDefer(
            rect,
            .{ .titled = true, .closable = true, .miniaturizable = true, .resizable = true },
            .buffered,
            false,
        );
        window.setReleasedWhenClosed(false);
        window.setTitle(.literal("mac-zig · Metal"));
        window.setContentView(view.asView());
        window.center();
        window.makeKeyAndOrderFront(null);
        self.view = view;
        self.window = window;

        if (self.quit_after) |seconds| mac.dispatch.Queue.main().after(seconds, self, struct {
            fn quit(_: *App) void {
                appkit.app.requestQuit();
            }
        }.quit);
    }

    pub fn willQuit(self: *App) void {
        if (self.view) |view| print("drew {d} frames\n", .{view.frameCount()});
    }

    fn deinit(self: *App) void {
        if (self.view) |view| view.deinit();
        if (self.window) |window| window.release();
    }
};

/// One frame into an offscreen texture, read back, written as a PNG.
fn snapshot(renderer: *Renderer, device: metal.Device, path: []const u8) !void {
    const width = 640;
    const height = 480;
    renderer.aspect = @as(f32, width) / height;

    const descriptor = metal.TextureDescriptor.texture2DDescriptorWithPixelFormatWidthHeightMipmapped(pixel_format, width, height, false);
    descriptor.setUsage(.{ .render_target = true });
    descriptor.setStorageMode(.managed);
    const target = device.newTextureWithDescriptor(descriptor).?;
    defer target.release();

    const pass = metal.RenderPassDescriptor.renderPassDescriptor();
    const color = pass.colorAttachments().objectAtIndexedSubscript(0);
    color.setTexture(target);
    color.setLoadAction(.clear);
    color.setClearColor(background);
    color.setStoreAction(.store);

    const queue = device.newCommandQueue().?;
    defer queue.release();
    const commands = queue.commandBuffer().?;
    renderer.encode(commands.renderCommandEncoderWithDescriptor(pass).?, 0.35);
    const blit = commands.blitCommandEncoder().?;
    blit.synchronizeResource(target.into(metal.Resource));
    blit.endEncoding();
    commands.commit();
    commands.waitUntilCompleted();

    const pixels = try std.heap.page_allocator.alloc(u8, width * height * 4);
    defer std.heap.page_allocator.free(pixels);
    target.getBytesBytesPerRowFromRegionMipmapLevel(pixels.ptr, width * 4, .{
        .origin = .{ .x = 0, .y = 0, .z = 0 },
        .size = .{ .width = width, .height = height, .depth = 1 },
    }, 0);

    const provider = try cg.DataProvider.initCopy(pixels);
    defer provider.deinit();
    const space = try cg.ColorSpace.named(.srgb);
    defer space.deinit();
    const image = try cg.Image.init(.{
        .width = width,
        .height = height,
        .bytes_per_row = width * 4,
        .space = space,
        .bitmap_info = .bgra8888, // the texture's own byte order
        .provider = provider,
    });
    defer image.deinit();
    if (!mac.features.imageio) return std.debug.print("built without -Dimageio: not writing {s}\n", .{path});
    try cg.imageio.writeImage(image, path, .png, .{});
    print("wrote {s} ({d}x{d}) on {f}\n", .{ path, width, height, device.name() });
}

pub fn main(init: std.process.Init) !void {
    if (!mac.features.metal or !mac.features.appkit) {
        print("built without -Dmetal or -Dappkit\n", .{});
        return;
    }

    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const device = metal.createSystemDefaultDevice() orelse {
        print("no Metal device\n", .{});
        return;
    };
    defer device.release();

    var renderer = try Renderer.init(device);
    defer renderer.deinit();

    var app: App = .{ .renderer = &renderer };
    defer app.deinit();

    const args = try init.minimal.args.toSlice(init.arena.allocator());
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--snapshot") and i + 1 < args.len) {
            return snapshot(&renderer, device, args[i + 1]);
        } else if (std.mem.eql(u8, args[i], "--quit-after") and i + 1 < args.len) {
            i += 1;
            app.quit_after = try std.fmt.parseFloat(f64, args[i]);
        }
    }

    appkit.app.run(.{}, &app, App);
}
