//! [Metal](https://developer.apple.com/documentation/metal), from wrappers
//! generated out of the SDK's headers, plus the part of QuartzCore that
//! puts Metal on screen -- reached as `mac.metal`, under `-Dmetal`.
//!
//! ```zig
//! const metal = mac.metal;
//!
//! const device = metal.createSystemDefaultDevice() orelse return error.NoGpu;
//! defer device.release();
//! const queue = device.newCommandQueue().?;
//! defer queue.release();
//!
//! const library = try metal.newLibrary(device, shader_source, null);
//! ```
//!
//! Most of Metal is protocols rather than classes -- a device is "an object
//! conforming to `MTLDevice`" -- and each is a wrapper here like any class:
//! `Device`, `CommandQueue`, `Texture`, `Buffer`, `RenderCommandEncoder`.
//! Names lose their `MTL` or `CA`, so `CAMetalLayer` is `MetalLayer`.
//!
//! ## Ownership
//!
//! Metal follows the naming rule: a method starting `new` hands you an
//! object to `release` -- `newCommandQueue`, `newBufferWithLength...`,
//! `newTextureWithDescriptor`. Everything else, including the command
//! buffer and encoders, is autoreleased: make a pool per frame.
//!
//! ## On screen
//!
//! `appkit.MetalView` is a view backed by a `MetalLayer`, with a render
//! loop at the display's refresh rate. See `examples/metal.zig`.

const std = @import("std");
const objc = @import("../objc/objc.zig");
const foundation = @import("../foundation/foundation.zig");
const errors = @import("../errors.zig");
const error_object = @import("../foundation/error_object.zig");
const generated = @import("generated.zig");

const Error = errors.Error;

/// True when the package was built with `-Dmetal` (the default).
pub const enabled = true;

/// Every generated class, protocol, enum and struct, by its name without
/// `MTL` or `CA` -- `metal.all.RenderPassColorAttachmentDescriptor` -- and
/// every constant and C function, in lower camel case:
/// `metal.all.currentMediaTime()`, `metal.all.gravityTopLeft()`. The ones
/// most programs use are also right here.
pub const all = generated;

// Objects.
pub const Device = generated.Device;
pub const CommandQueue = generated.CommandQueue;
pub const CommandBuffer = generated.CommandBuffer;
pub const CommandEncoder = generated.CommandEncoder;
pub const RenderCommandEncoder = generated.RenderCommandEncoder;
pub const ComputeCommandEncoder = generated.ComputeCommandEncoder;
pub const BlitCommandEncoder = generated.BlitCommandEncoder;
pub const Resource = generated.Resource;
pub const Buffer = generated.Buffer;
pub const Texture = generated.Texture;
pub const Library = generated.Library;
pub const Function = generated.Function;
pub const RenderPipelineState = generated.RenderPipelineState;
pub const ComputePipelineState = generated.ComputePipelineState;
pub const DepthStencilState = generated.DepthStencilState;
pub const SamplerState = generated.SamplerState;
pub const Drawable = generated.Drawable;

// Descriptors.
pub const RenderPassDescriptor = generated.RenderPassDescriptor;
pub const RenderPipelineDescriptor = generated.RenderPipelineDescriptor;
pub const ComputePipelineDescriptor = generated.ComputePipelineDescriptor;
pub const VertexDescriptor = generated.VertexDescriptor;
pub const DepthStencilDescriptor = generated.DepthStencilDescriptor;
pub const SamplerDescriptor = generated.SamplerDescriptor;
pub const TextureDescriptor = generated.TextureDescriptor;
pub const CompileOptions = generated.CompileOptions;

// QuartzCore.
pub const Layer = generated.Layer;
pub const MetalLayer = generated.MetalLayer;
pub const MetalDrawable = generated.MetalDrawable;
pub const DisplayLink = generated.DisplayLink;

// Values.
pub const PixelFormat = generated.PixelFormat;
pub const PrimitiveType = generated.PrimitiveType;
pub const LoadAction = generated.LoadAction;
pub const StoreAction = generated.StoreAction;
pub const ResourceOptions = generated.ResourceOptions;
pub const StorageMode = generated.StorageMode;
pub const TextureUsage = generated.TextureUsage;
pub const ClearColor = generated.ClearColor;
pub const Viewport = generated.Viewport;
pub const ScissorRect = generated.ScissorRect;
pub const Origin = generated.Origin;
pub const Size = generated.Size;
pub const Region = generated.Region;

/// The GPU the system would pick: the built-in one on a laptop. Null on a
/// machine with no Metal support. Yours to `release`.
pub const createSystemDefaultDevice = generated.createSystemDefaultDevice;

/// Every GPU, eGPUs and all. Yours to `deinit`.
pub const copyAllDevices = generated.copyAllDevices;

/// Compiles Metal Shading Language source. A compile error comes back as
/// `error.Failed`, with the compiler's messages in `details` when given.
/// Yours to `release`.
pub fn newLibrary(device: Device, source: []const u8, details: ?*foundation.ErrorObject) Error!Library {
    const text = try foundation.String.init(source);
    defer text.deinit();
    var slot: error_object.Slot = .{};
    const library = device.newLibraryWithSourceOptionsError(text, null, &slot.id);
    try slot.finish(library != null, details);
    return library.?;
}

/// A render pipeline from its descriptor. Yours to `release`.
pub fn newRenderPipelineState(
    device: Device,
    descriptor: RenderPipelineDescriptor,
    details: ?*foundation.ErrorObject,
) Error!RenderPipelineState {
    var slot: error_object.Slot = .{};
    const state = device.newRenderPipelineStateWithDescriptorError(descriptor, &slot.id);
    try slot.finish(state != null, details);
    return state.?;
}

/// A compute pipeline for `kernel`. Yours to `release`.
pub fn newComputePipelineState(device: Device, kernel: Function, details: ?*foundation.ErrorObject) Error!ComputePipelineState {
    var slot: error_object.Slot = .{};
    const state = device.newComputePipelineStateWithFunctionError(kernel, &slot.id);
    try slot.finish(state != null, details);
    return state.?;
}

/// A function from `library` by name, or null. Yours to `release`.
pub fn function(library: Library, comptime name: [:0]const u8) ?Function {
    return library.newFunctionWithName(.literal(name));
}

pub fn clearColor(red: f64, green: f64, blue: f64, alpha: f64) ClearColor {
    return .{ .red = red, .green = green, .blue = blue, .alpha = alpha };
}

test {
    _ = @import("tests.zig");
}
