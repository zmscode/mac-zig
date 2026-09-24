//! What `zig build generate` wraps from Metal, and the corner of
//! QuartzCore that shows Metal on screen. The result is
//! `src/metal/generated.zig`.
//!
//! Most of Metal is protocols, not classes: a device, a command queue, a
//! texture are each "some object conforming to `MTLDevice`". Each listed
//! protocol gets a wrapper struct just like a class does, and
//! `id<MTLDevice>` anywhere becomes `Device`.

pub const framework = "Metal";
pub const imports = [_][]const u8{ "Metal/Metal.h", "QuartzCore/QuartzCore.h" };
pub const prefixes = [_][]const u8{ "MTL", "CA" };

pub const classes = [_][]const u8{
    // Describing work.
    "MTLRenderPassDescriptor",
    "MTLRenderPassAttachmentDescriptor",
    "MTLRenderPassColorAttachmentDescriptor",
    "MTLRenderPassColorAttachmentDescriptorArray",
    "MTLRenderPassDepthAttachmentDescriptor",
    "MTLRenderPipelineDescriptor",
    "MTLRenderPipelineColorAttachmentDescriptor",
    "MTLRenderPipelineColorAttachmentDescriptorArray",
    "MTLComputePipelineDescriptor",
    "MTLVertexDescriptor",
    "MTLVertexAttributeDescriptor",
    "MTLVertexAttributeDescriptorArray",
    "MTLVertexBufferLayoutDescriptor",
    "MTLVertexBufferLayoutDescriptorArray",
    "MTLDepthStencilDescriptor",
    "MTLStencilDescriptor",
    "MTLSamplerDescriptor",
    "MTLTextureDescriptor",
    "MTLCompileOptions",
    // Showing it.
    "CALayer",
    "CAMetalLayer",
    "CADisplayLink",
};

pub const protocols = [_][]const u8{
    "MTLDevice",
    "MTLCommandQueue",
    "MTLCommandBuffer",
    "MTLCommandEncoder",
    "MTLRenderCommandEncoder",
    "MTLComputeCommandEncoder",
    "MTLBlitCommandEncoder",
    "MTLResource",
    "MTLBuffer",
    "MTLTexture",
    "MTLLibrary",
    "MTLFunction",
    "MTLRenderPipelineState",
    "MTLComputePipelineState",
    "MTLDepthStencilState",
    "MTLSamplerState",
    "MTLDrawable",
    "CAMetalDrawable",
};

pub const structs = [_][]const u8{
    "MTLClearColor",
    "MTLViewport",
    "MTLScissorRect",
    "MTLOrigin",
    "MTLSize",
    "MTLRegion",
};

pub const enums = [_][]const u8{
    "MTLPixelFormat",
    "MTLLoadAction",
    "MTLStoreAction",
    "MTLStoreActionOptions",
    "MTLPrimitiveType",
    "MTLIndexType",
    "MTLVertexFormat",
    "MTLVertexStepFunction",
    "MTLResourceOptions",
    "MTLStorageMode",
    "MTLCPUCacheMode",
    "MTLHazardTrackingMode",
    "MTLPurgeableState",
    "MTLTextureType",
    "MTLTextureUsage",
    "MTLTextureCompressionType",
    "MTLTextureSwizzle",
    "MTLCompareFunction",
    "MTLStencilOperation",
    "MTLCullMode",
    "MTLWinding",
    "MTLTriangleFillMode",
    "MTLDepthClipMode",
    "MTLBlendFactor",
    "MTLBlendOperation",
    "MTLColorWriteMask",
    "MTLPrimitiveTopologyClass",
    "MTLSamplerMinMagFilter",
    "MTLSamplerMipFilter",
    "MTLSamplerAddressMode",
    "MTLSamplerBorderColor",
    "MTLCommandBufferStatus",
    "MTLCommandBufferErrorOption",
    "MTLDispatchType",
    "MTLFunctionType",
    "MTLLanguageVersion",
    "MTLLibraryType",
    "MTLLibraryOptimizationLevel",
    "MTLCompileSymbolVisibility",
    "MTLMathMode",
    "MTLMathFloatingPointFunctions",
    "MTLGPUFamily",
    "MTLDeviceLocation",
    "MTLReadWriteTextureTier",
    "MTLArgumentBuffersTier",
    "MTLSparsePageSize",
    "MTLSparseTextureRegionAlignmentMode",
    "MTLCounterSamplingPoint",
    "MTLMultisampleDepthResolveFilter",
    "MTLMultisampleStencilResolveFilter",
    "MTLVisibilityResultMode",
    "MTLRenderStages",
    "MTLBarrierScope",
    "MTLResourceUsage",
    "MTLBlitOption",
    "MTLShaderValidation",
    "MTLPipelineOption",
    "MTLIOCompressionMethod",
};
