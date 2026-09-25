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
