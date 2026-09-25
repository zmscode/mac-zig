const std = @import("std");
const objc = @import("../objc/objc.zig");
const foundation = @import("../foundation/foundation.zig");
const metal = @import("metal.zig");
const generated = @import("generated.zig");

test "every generated method compiles" {
    @setEvalBranchQuota(1_000_000);
    inline for (@typeInfo(generated).@"struct".decl_names) |name| {
        const T = @field(generated, name);
        if (@TypeOf(T) == type and @typeInfo(T) == .@"struct" and
            (@hasDecl(T, "class_name") or @hasDecl(T, "protocol_name")))
        {
            inline for (@typeInfo(T).@"struct".decl_names) |decl| {
                const member = @field(T, decl);
                const info = @typeInfo(@TypeOf(member));
                if (info == .@"fn" and !info.@"fn".is_generic) std.mem.doNotOptimizeAway(&member);
            }
            inline for (@typeInfo(T.signatures).@"struct".decl_names) |decl| {
                std.debug.assert(@typeInfo(@field(T.signatures, decl)) == .@"fn");
            }
        }
    }
}

const shader =
    \\#include <metal_stdlib>
    \\using namespace metal;
    \\
    \\// The lower-left half of the target: a right triangle on the diagonal.
    \\vertex float4 vertex_main(uint id [[vertex_id]]) {
    \\    const float2 corners[3] = { float2(-1, -1), float2(1, -1), float2(-1, 1) };
    \\    return float4(corners[id], 0, 1);
    \\}
    \\
    \\fragment float4 fragment_main() {
    \\    return float4(1, 0, 0, 1);
    \\}
;

test "a triangle, rendered offscreen and read back" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const device = metal.createSystemDefaultDevice() orelse return error.SkipZigTest;
    defer device.release();

    const library = try metal.newLibrary(device, shader, null);
    defer library.release();
    const vertex_fn = metal.function(library, "vertex_main").?;
    defer vertex_fn.release();
    const fragment_fn = metal.function(library, "fragment_main").?;
    defer fragment_fn.release();

    const size = 8;
    const pipeline_descriptor = metal.RenderPipelineDescriptor.new();
    defer pipeline_descriptor.release();
    pipeline_descriptor.setVertexFunction(vertex_fn);
    pipeline_descriptor.setFragmentFunction(fragment_fn);
    pipeline_descriptor.colorAttachments().objectAtIndexedSubscript(0).setPixelFormat(.rgba8_unorm);
    const pipeline = try metal.newRenderPipelineState(device, pipeline_descriptor, null);
    defer pipeline.release();

    // Managed storage, synchronised back after drawing: readable from the
    // CPU on Apple silicon and on Intel GPUs alike.
    const texture_descriptor = metal.TextureDescriptor.texture2DDescriptorWithPixelFormatWidthHeightMipmapped(.rgba8_unorm, size, size, false);
    texture_descriptor.setUsage(.{ .render_target = true });
    texture_descriptor.setStorageMode(.managed);
    const target = device.newTextureWithDescriptor(texture_descriptor).?;
    defer target.release();

    const pass = metal.RenderPassDescriptor.renderPassDescriptor();
    const attachment = pass.colorAttachments().objectAtIndexedSubscript(0);
    attachment.setTexture(target);
    attachment.setLoadAction(.clear);
    attachment.setClearColor(metal.clearColor(0, 0, 1, 1));
    attachment.setStoreAction(.store);

    const queue = device.newCommandQueue().?;
    defer queue.release();
    const commands = queue.commandBuffer().?;

    const encoder = commands.renderCommandEncoderWithDescriptor(pass).?;
    encoder.setRenderPipelineState(pipeline);
    // C arrays, as slices' pointers: a one-viewport array covering the
    // target, and a texture slot deliberately left empty.
    const viewports = [_]metal.Viewport{.{ .origin_x = 0, .origin_y = 0, .width = size, .height = size, .znear = 0, .zfar = 1 }};
    encoder.setViewportsCount(&viewports, viewports.len);
    const textures = [_]objc.Nullable(metal.Texture){.none};
    encoder.setFragmentTexturesWithRange(&textures, .{ .location = 0, .length = textures.len });
    encoder.drawPrimitivesVertexStartVertexCount(.triangle, 0, 3);
    encoder.endEncoding(); // MTLCommandEncoder's, inherited

    const blit = commands.blitCommandEncoder().?;
    blit.synchronizeResource(target.into(metal.Resource));
    blit.endEncoding();

    commands.commit();
    commands.waitUntilCompleted();
    try std.testing.expectEqual(generated.CommandBufferStatus.completed, commands.status());

    var pixels: [size * size][4]u8 = undefined;
    target.getBytesBytesPerRowFromRegionMipmapLevel(&pixels, size * 4, .{
        .origin = .{ .x = 0, .y = 0, .z = 0 },
        .size = .{ .width = size, .height = size, .depth = 1 },
    }, 0);

    // Row 0 is the top. Bottom left is inside the triangle, top right is not.
    try std.testing.expectEqual([4]u8{ 255, 0, 0, 255 }, pixels[(size - 1) * size + 0]);
    try std.testing.expectEqual([4]u8{ 0, 0, 255, 255 }, pixels[0 * size + (size - 1)]);
}

test "a shader that does not compile is an error with the compiler's message" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const device = metal.createSystemDefaultDevice() orelse return error.SkipZigTest;
    defer device.release();

    var details: foundation.ErrorObject = undefined;
    try std.testing.expectError(error.Failed, metal.newLibrary(device, "this is not metal", &details));
    defer details.deinit();
    const message = try details.localizedDescription().toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(message);
    try std.testing.expect(message.len > 0);
}

// -- IOSurface: one buffer, three views of it ------------------------------

const iosurface = @import("../iosurface/iosurface.zig");

test "an IOSurface shared between cg, Metal and a layer, without copies" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const device = metal.createSystemDefaultDevice() orelse return error.SkipZigTest;
    defer device.release();

    const size = 16;
    const surface = try iosurface.Surface.init(.{ .width = size, .height = size, .name = "mac-zig interop" });
    defer surface.deinit();

    // 1. The CPU draws: the left half green, through CoreGraphics.
    {
        const locked = try surface.lock(.{});
        defer locked.unlock();
        const ctx = try locked.initContext();
        defer ctx.deinit();
        ctx.setFillColor(.rgb(0, 1, 0));
        ctx.fillRect(.init(0, 0, size / 2, size));
    }

    // 2. The GPU sees it: a texture over the same memory.
    const descriptor = metal.TextureDescriptor.texture2DDescriptorWithPixelFormatWidthHeightMipmapped(.bgra8_unorm, size, size, false);
    descriptor.setUsage(.{ .shader_read = true, .render_target = true });
    descriptor.setStorageMode(.managed);
    const texture = device.newTextureWithDescriptorIosurfacePlane(descriptor, surface, 0).?;
    defer texture.release();
    try std.testing.expectEqual(surface.id(), texture.iosurface().?.id());

    var pixel: [4]u8 = undefined;
    const region: metal.Region = .{ .origin = .{ .x = 2, .y = 8, .z = 0 }, .size = .{ .width = 1, .height = 1, .depth = 1 } };
    texture.getBytesBytesPerRowFromRegionMipmapLevel(&pixel, 4, region, 0);
    try std.testing.expectEqual([4]u8{ 0, 255, 0, 255 }, pixel); // B, G, R, A

    // 3. The GPU draws: clears the whole texture to red.
    const queue = device.newCommandQueue().?;
    defer queue.release();
    const commands = queue.commandBuffer().?;
    const pass = metal.RenderPassDescriptor.renderPassDescriptor();
    const color = pass.colorAttachments().objectAtIndexedSubscript(0);
    color.setTexture(texture);
    color.setLoadAction(.clear);
    color.setClearColor(metal.clearColor(1, 0, 0, 1));
    color.setStoreAction(.store);
    commands.renderCommandEncoderWithDescriptor(pass).?.endEncoding();
    commands.commit();
    commands.waitUntilCompleted();

    // 4. The CPU sees the GPU's work, through the surface.
    {
        const locked = try surface.lock(.{ .read_only = true });
        defer locked.unlock();
        try std.testing.expectEqualSlices(u8, &.{ 0, 0, 255, 255 }, locked.row(8)[2 * 4 ..][0..4]);
    }

    // 5. And a layer can show it: an IOSurface is its own Objective-C object.
    const layer = metal.Layer.new();
    defer layer.release();
    layer.setContents(objc.Object.fromCf(surface));
    try std.testing.expect(layer.contents().?.value == @as(*anyopaque, @ptrCast(surface.handle)));
}

// -- blocks the SDK calls back ---------------------------------------------

const dispatch = @import("../dispatch/dispatch.zig");

test "a completion handler: a typed block, copied by Metal and called from its thread" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const device = metal.createSystemDefaultDevice() orelse return error.SkipZigTest;
    defer device.release();
    const queue = device.newCommandQueue().?;
    defer queue.release();

    const Done = objc.Block(struct {
        done: *dispatch.Semaphore,
        status: *std.atomic.Value(u64),
    }, fn (metal.CommandBuffer) void);

    var semaphore: dispatch.Semaphore = .init(0);
    defer semaphore.deinit();
    var status: std.atomic.Value(u64) = .init(0);

    var handler = Done.init(.{ .done = &semaphore, .status = &status }, struct {
        fn body(captures: *const Done.Captures, commands: metal.CommandBuffer) void {
            captures.status.store(@backingInt(commands.status()), .release);
            captures.done.signal();
        }
    }.body);

    const commands = queue.commandBuffer().?;
    // `addCompletedHandler` takes a BlockRef(fn (CommandBuffer) void); a
    // block of any other signature would not compile.
    commands.addCompletedHandler(handler.ref());
    commands.commit();

    try std.testing.expect(semaphore.wait(5));
    try std.testing.expectEqual(@backingInt(generated.CommandBufferStatus.completed), status.load(.acquire));
}

test "every generated constant and function compiles" {
    @setEvalBranchQuota(1_000_000);
    inline for (@typeInfo(generated).@"struct".decl_names) |name| {
        const member = @field(generated, name);
        const info = @typeInfo(@TypeOf(member));
        if (info == .@"fn" and !info.@"fn".is_generic) std.mem.doNotOptimizeAway(&member);
    }
}

test "QuartzCore's constants and functions, called" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();
    try std.testing.expect(metal.all.currentMediaTime() > 0);
    try std.testing.expect(metal.all.gravityTopLeft().eql(.literal("topLeft")));
    const scale = metal.all.transform3DMakeScale(2, 3, 4);
    try std.testing.expectEqual(@as(f64, 3), scale.m22);
}
