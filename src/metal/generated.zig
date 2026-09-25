//! Metal wrappers generated from the macOS SDK by `zig build generate`,
//! from the manifest in `tools/objc_gen/metal.zig`. Do not edit: add to the
//! manifest and regenerate, or write a hand-made wrapper beside this file.

const objc = @import("../objc/objc.zig");
const foundation = @import("../foundation/foundation.zig");
const cg = @import("../cg/cg.zig");
// Snake case, which no generated method is: `-[MTLTexture iosurface]`
// would otherwise hide it.
const io_surface = @import("../iosurface/iosurface.zig");

/// Whether `Descendant` is `Ancestor`, or inherits from it.
fn inherits(comptime Descendant: type, comptime Ancestor: type) bool {
    if (Ancestor == objc.Object) return true;
    comptime var current: type = Descendant;
    inline while (true) {
        if (current == Ancestor) return true;
        if (current.Super == objc.Object) return false;
        current = current.Super;
    }
}

fn lookUp(comptime name: [:0]const u8) objc.Class {
    return objc.getClass(name) orelse @panic(name ++ " is not loaded: link " ++ framework);
}

const framework = "Metal";

/// Every constant and C function is linked weakly: one that a newer SDK
/// declares and the running macOS lacks leaves the program able to start,
/// and panics only if it is used.
fn missing(comptime name: []const u8) noreturn {
    @panic(name ++ " is not in this version of macOS");
}

/// `MTLClearColor`.
pub const ClearColor = extern struct {
    red: f64,
    green: f64,
    blue: f64,
    alpha: f64,
};

/// `MTLViewport`.
pub const Viewport = extern struct {
    origin_x: f64,
    origin_y: f64,
    width: f64,
    height: f64,
    znear: f64,
    zfar: f64,
};

/// `MTLScissorRect`.
pub const ScissorRect = extern struct {
    x: objc.UInteger,
    y: objc.UInteger,
    width: objc.UInteger,
    height: objc.UInteger,
};

/// `MTLOrigin`.
pub const Origin = extern struct {
    x: objc.UInteger,
    y: objc.UInteger,
    z: objc.UInteger,
};

/// `MTLSize`.
pub const Size = extern struct {
    width: objc.UInteger,
    height: objc.UInteger,
    depth: objc.UInteger,
};

/// `MTLRegion`.
pub const Region = extern struct {
    origin: Origin,
    size: Size,
};

/// `MTLSizeAndAlign`.
pub const SizeAndAlign = extern struct {
    size: objc.UInteger,
    @"align": objc.UInteger,
};

/// `MTLResourceID`.
pub const ResourceID = extern struct {
    _impl: u64,
};

/// `MTLTextureSwizzleChannels`.
pub const TextureSwizzleChannels = extern struct {
    red: TextureSwizzle,
    green: TextureSwizzle,
    blue: TextureSwizzle,
    alpha: TextureSwizzle,
};

/// `MTLAccelerationStructureSizes`.
pub const AccelerationStructureSizes = extern struct {
    acceleration_structure_size: objc.UInteger,
    build_scratch_buffer_size: objc.UInteger,
    refit_scratch_buffer_size: objc.UInteger,
};

/// `CATransform3D`.
pub const Transform3D = extern struct {
    m11: cg.Float,
    m12: cg.Float,
    m13: cg.Float,
    m14: cg.Float,
    m21: cg.Float,
    m22: cg.Float,
    m23: cg.Float,
    m24: cg.Float,
    m31: cg.Float,
    m32: cg.Float,
    m33: cg.Float,
    m34: cg.Float,
    m41: cg.Float,
    m42: cg.Float,
    m43: cg.Float,
    m44: cg.Float,
};

/// `CAFrameRateRange`.
pub const FrameRateRange = extern struct {
    minimum: f32,
    maximum: f32,
    preferred: f32,
};

/// `MTLPixelFormat`.
pub const PixelFormat = enum(objc.UInteger) {
    invalid = 0,
    a8_unorm = 1,
    r8_unorm = 10,
    r8_unorm_srgb = 11,
    r8_snorm = 12,
    r8_uint = 13,
    r8_sint = 14,
    r16_unorm = 20,
    r16_snorm = 22,
    r16_uint = 23,
    r16_sint = 24,
    r16_float = 25,
    rg8_unorm = 30,
    rg8_unorm_srgb = 31,
    rg8_snorm = 32,
    rg8_uint = 33,
    rg8_sint = 34,
    b5_g6_r5_unorm = 40,
    a1_bgr5_unorm = 41,
    abgr4_unorm = 42,
    bgr5_a1_unorm = 43,
    rgb8_unorm = 45,
    rgb8_snorm = 46,
    rgb8_uint = 47,
    rgb8_sint = 48,
    r32_uint = 53,
    r32_sint = 54,
    r32_float = 55,
    rg16_unorm = 60,
    rg16_snorm = 62,
    rg16_uint = 63,
    rg16_sint = 64,
    rg16_float = 65,
    rgba8_unorm = 70,
    rgba8_unorm_srgb = 71,
    rgba8_snorm = 72,
    rgba8_uint = 73,
    rgba8_sint = 74,
    bgra8_unorm = 80,
    bgra8_unorm_srgb = 81,
    rgb10_a2_unorm = 90,
    rgb10_a2_uint = 91,
    rg11_b10_float = 92,
    rgb9_e5_float = 93,
    bgr10_a2_unorm = 94,
    bgr10_xr = 554,
    bgr10_xr_srgb = 555,
    rgb16_unorm = 95,
    rgb16_snorm = 96,
    rgb16_uint = 97,
    rgb16_sint = 98,
    rgb16_float = 99,
    rg32_uint = 103,
    rg32_sint = 104,
    rg32_float = 105,
    rgba16_unorm = 110,
    rgba16_snorm = 112,
    rgba16_uint = 113,
    rgba16_sint = 114,
    rgba16_float = 115,
    bgra10_xr = 552,
    bgra10_xr_srgb = 553,
    rgb32_uint = 120,
    rgb32_sint = 121,
    rgb32_float = 122,
    rgba32_uint = 123,
    rgba32_sint = 124,
    rgba32_float = 125,
    bc1_rgba = 130,
    bc1_rgba_srgb = 131,
    bc2_rgba = 132,
    bc2_rgba_srgb = 133,
    bc3_rgba = 134,
    bc3_rgba_srgb = 135,
    bc4_r_unorm = 140,
    bc4_r_snorm = 141,
    bc5_rg_unorm = 142,
    bc5_rg_snorm = 143,
    bc6_h_rgb_float = 150,
    bc6_h_rgb_ufloat = 151,
    bc7_rgba_unorm = 152,
    bc7_rgba_unorm_srgb = 153,
    pvrtc_rgb_2_bpp = 160,
    pvrtc_rgb_2_bpp_srgb = 161,
    pvrtc_rgb_4_bpp = 162,
    pvrtc_rgb_4_bpp_srgb = 163,
    pvrtc_rgba_2_bpp = 164,
    pvrtc_rgba_2_bpp_srgb = 165,
    pvrtc_rgba_4_bpp = 166,
    pvrtc_rgba_4_bpp_srgb = 167,
    eac_r11_unorm = 170,
    eac_r11_snorm = 172,
    eac_rg11_unorm = 174,
    eac_rg11_snorm = 176,
    eac_rgba8 = 178,
    eac_rgba8_srgb = 179,
    etc2_rgb8 = 180,
    etc2_rgb8_srgb = 181,
    etc2_rgb8_a1 = 182,
    etc2_rgb8_a1_srgb = 183,
    astc_4x4_srgb = 186,
    astc_5x4_srgb = 187,
    astc_5x5_srgb = 188,
    astc_6x5_srgb = 189,
    astc_6x6_srgb = 190,
    astc_8x5_srgb = 192,
    astc_8x6_srgb = 193,
    astc_8x8_srgb = 194,
    astc_10x5_srgb = 195,
    astc_10x6_srgb = 196,
    astc_10x8_srgb = 197,
    astc_10x10_srgb = 198,
    astc_12x10_srgb = 199,
    astc_12x12_srgb = 200,
    astc_4x4_ldr = 204,
    astc_5x4_ldr = 205,
    astc_5x5_ldr = 206,
    astc_6x5_ldr = 207,
    astc_6x6_ldr = 208,
    astc_8x5_ldr = 210,
    astc_8x6_ldr = 211,
    astc_8x8_ldr = 212,
    astc_10x5_ldr = 213,
    astc_10x6_ldr = 214,
    astc_10x8_ldr = 215,
    astc_10x10_ldr = 216,
    astc_12x10_ldr = 217,
    astc_12x12_ldr = 218,
    astc_4x4_hdr = 222,
    astc_5x4_hdr = 223,
    astc_5x5_hdr = 224,
    astc_6x5_hdr = 225,
    astc_6x6_hdr = 226,
    astc_8x5_hdr = 228,
    astc_8x6_hdr = 229,
    astc_8x8_hdr = 230,
    astc_10x5_hdr = 231,
    astc_10x6_hdr = 232,
    astc_10x8_hdr = 233,
    astc_10x10_hdr = 234,
    astc_12x10_hdr = 235,
    astc_12x12_hdr = 236,
    gbgr422 = 240,
    bgrg422 = 241,
    depth16_unorm = 250,
    depth32_float = 252,
    stencil8 = 253,
    depth24_unorm_stencil8 = 255,
    depth32_float_stencil8 = 260,
    x32_stencil8 = 261,
    x24_stencil8 = 262,
    unspecialized = 263,
    _,
};

/// `MTLLoadAction`.
pub const LoadAction = enum(objc.UInteger) {
    dont_care = 0,
    load = 1,
    clear = 2,
    _,
};

/// `MTLStoreAction`.
pub const StoreAction = enum(objc.UInteger) {
    dont_care = 0,
    store = 1,
    multisample_resolve = 2,
    store_and_multisample_resolve = 3,
    unknown = 4,
    custom_sample_depth_store = 5,
    _,
};

/// `MTLStoreActionOptions`.
pub const StoreActionOptions = packed struct(u64) {
    custom_sample_positions: bool = false,
    _1: u63 = 0,
    pub const none: StoreActionOptions = @fromBackingInt(0x0);
};

/// `MTLPrimitiveType`.
pub const PrimitiveType = enum(objc.UInteger) {
    point = 0,
    line = 1,
    line_strip = 2,
    triangle = 3,
    triangle_strip = 4,
    _,
};

/// `MTLIndexType`.
pub const IndexType = enum(objc.UInteger) {
    @"16" = 0,
    @"32" = 1,
    _,
};

/// `MTLVertexFormat`.
pub const VertexFormat = enum(objc.UInteger) {
    invalid = 0,
    u_char2 = 1,
    u_char3 = 2,
    u_char4 = 3,
    char2 = 4,
    char3 = 5,
    char4 = 6,
    u_char2_normalized = 7,
    u_char3_normalized = 8,
    u_char4_normalized = 9,
    char2_normalized = 10,
    char3_normalized = 11,
    char4_normalized = 12,
    u_short2 = 13,
    u_short3 = 14,
    u_short4 = 15,
    short2 = 16,
    short3 = 17,
    short4 = 18,
    u_short2_normalized = 19,
    u_short3_normalized = 20,
    u_short4_normalized = 21,
    short2_normalized = 22,
    short3_normalized = 23,
    short4_normalized = 24,
    half2 = 25,
    half3 = 26,
    half4 = 27,
    float = 28,
    float2 = 29,
    float3 = 30,
    float4 = 31,
    int = 32,
    int2 = 33,
    int3 = 34,
    int4 = 35,
    u_int = 36,
    u_int2 = 37,
    u_int3 = 38,
    u_int4 = 39,
    int1010102_normalized = 40,
    u_int1010102_normalized = 41,
    u_char4_normalized_bgra = 42,
    u_char = 45,
    char = 46,
    u_char_normalized = 47,
    char_normalized = 48,
    u_short = 49,
    short = 50,
    u_short_normalized = 51,
    short_normalized = 52,
    half = 53,
    float_rg11_b10 = 54,
    float_rgb9_e5 = 55,
    _,
};

/// `MTLVertexStepFunction`.
pub const VertexStepFunction = enum(objc.UInteger) {
    constant = 0,
    per_vertex = 1,
    per_instance = 2,
    per_patch = 3,
    per_patch_control_point = 4,
    _,
};

/// `MTLResourceOptions`.
pub const ResourceOptions = packed struct(u64) {
    cpu_cache_mode_write_combined: bool = false,
    _1: u3 = 0,
    storage_mode_managed: bool = false,
    storage_mode_private: bool = false,
    _6: u2 = 0,
    hazard_tracking_mode_untracked: bool = false,
    hazard_tracking_mode_tracked: bool = false,
    _10: u54 = 0,
    pub const cpu_cache_mode_default_cache: ResourceOptions = @fromBackingInt(0x0);
    pub const storage_mode_shared: ResourceOptions = @fromBackingInt(0x0);
    pub const storage_mode_memoryless: ResourceOptions = @fromBackingInt(0x30);
    pub const hazard_tracking_mode_default: ResourceOptions = @fromBackingInt(0x0);
    pub const option_cpu_cache_mode_default: ResourceOptions = @fromBackingInt(0x0);
    pub const option_cpu_cache_mode_write_combined: ResourceOptions = @fromBackingInt(0x1);
};

/// `MTLStorageMode`.
pub const StorageMode = enum(objc.UInteger) {
    shared = 0,
    managed = 1,
    private = 2,
    memoryless = 3,
    _,
};

/// `MTLCPUCacheMode`.
pub const CPUCacheMode = enum(objc.UInteger) {
    default_cache = 0,
    write_combined = 1,
    _,
};

/// `MTLHazardTrackingMode`.
pub const HazardTrackingMode = enum(objc.UInteger) {
    default = 0,
    untracked = 1,
    tracked = 2,
    _,
};

/// `MTLPurgeableState`.
pub const PurgeableState = enum(objc.UInteger) {
    keep_current = 1,
    non_volatile = 2,
    @"volatile" = 3,
    empty = 4,
    _,
};

/// `MTLTextureType`.
pub const TextureType = enum(objc.UInteger) {
    @"1_d" = 0,
    @"1_d_array" = 1,
    @"2_d" = 2,
    @"2_d_array" = 3,
    @"2_d_multisample" = 4,
    cube = 5,
    cube_array = 6,
    @"3_d" = 7,
    @"2_d_multisample_array" = 8,
    texture_buffer = 9,
    _,
};

/// `MTLTextureUsage`.
pub const TextureUsage = packed struct(u64) {
    shader_read: bool = false,
    shader_write: bool = false,
    render_target: bool = false,
    _3: u1 = 0,
    pixel_format_view: bool = false,
    shader_atomic: bool = false,
    _6: u58 = 0,
    pub const unknown: TextureUsage = @fromBackingInt(0x0);
};

/// `MTLTextureCompressionType`.
pub const TextureCompressionType = enum(objc.Integer) {
    lossless = 0,
    lossy = 1,
    _,
};

/// `MTLTextureSwizzle`.
pub const TextureSwizzle = enum(u8) {
    zero = 0,
    one = 1,
    red = 2,
    green = 3,
    blue = 4,
    alpha = 5,
    _,
};

/// `MTLCompareFunction`.
pub const CompareFunction = enum(objc.UInteger) {
    never = 0,
    less = 1,
    equal = 2,
    less_equal = 3,
    greater = 4,
    not_equal = 5,
    greater_equal = 6,
    always = 7,
    _,
};

/// `MTLStencilOperation`.
pub const StencilOperation = enum(objc.UInteger) {
    keep = 0,
    zero = 1,
    replace = 2,
    increment_clamp = 3,
    decrement_clamp = 4,
    invert = 5,
    increment_wrap = 6,
    decrement_wrap = 7,
    _,
};

/// `MTLCullMode`.
pub const CullMode = enum(objc.UInteger) {
    none = 0,
    front = 1,
    back = 2,
    _,
};

/// `MTLWinding`.
pub const Winding = enum(objc.UInteger) {
    clockwise = 0,
    counter_clockwise = 1,
    _,
};

/// `MTLTriangleFillMode`.
pub const TriangleFillMode = enum(objc.UInteger) {
    fill = 0,
    lines = 1,
    _,
};

/// `MTLDepthClipMode`.
pub const DepthClipMode = enum(objc.UInteger) {
    clip = 0,
    clamp = 1,
    _,
};

/// `MTLBlendFactor`.
pub const BlendFactor = enum(objc.UInteger) {
    zero = 0,
    one = 1,
    source_color = 2,
    one_minus_source_color = 3,
    source_alpha = 4,
    one_minus_source_alpha = 5,
    destination_color = 6,
    one_minus_destination_color = 7,
    destination_alpha = 8,
    one_minus_destination_alpha = 9,
    source_alpha_saturated = 10,
    blend_color = 11,
    one_minus_blend_color = 12,
    blend_alpha = 13,
    one_minus_blend_alpha = 14,
    source1_color = 15,
    one_minus_source1_color = 16,
    source1_alpha = 17,
    one_minus_source1_alpha = 18,
    unspecialized = 19,
    _,
};

/// `MTLBlendOperation`.
pub const BlendOperation = enum(objc.UInteger) {
    add = 0,
    subtract = 1,
    reverse_subtract = 2,
    min = 3,
    max = 4,
    unspecialized = 5,
    _,
};

/// `MTLColorWriteMask`.
pub const ColorWriteMask = packed struct(u64) {
    alpha: bool = false,
    blue: bool = false,
    green: bool = false,
    red: bool = false,
    unspecialized: bool = false,
    _5: u59 = 0,
    pub const none: ColorWriteMask = @fromBackingInt(0x0);
    pub const all: ColorWriteMask = @fromBackingInt(0xf);
};

/// `MTLPrimitiveTopologyClass`.
pub const PrimitiveTopologyClass = enum(objc.UInteger) {
    unspecified = 0,
    point = 1,
    line = 2,
    triangle = 3,
    _,
};

/// `MTLSamplerMinMagFilter`.
pub const SamplerMinMagFilter = enum(objc.UInteger) {
    nearest = 0,
    linear = 1,
    _,
};

/// `MTLSamplerMipFilter`.
pub const SamplerMipFilter = enum(objc.UInteger) {
    not_mipmapped = 0,
    nearest = 1,
    linear = 2,
    _,
};

/// `MTLSamplerAddressMode`.
pub const SamplerAddressMode = enum(objc.UInteger) {
    clamp_to_edge = 0,
    mirror_clamp_to_edge = 1,
    repeat = 2,
    mirror_repeat = 3,
    clamp_to_zero = 4,
    clamp_to_border_color = 5,
    _,
};

/// `MTLSamplerBorderColor`.
pub const SamplerBorderColor = enum(objc.UInteger) {
    transparent_black = 0,
    opaque_black = 1,
    opaque_white = 2,
    _,
};

/// `MTLCommandBufferStatus`.
pub const CommandBufferStatus = enum(objc.UInteger) {
    not_enqueued = 0,
    enqueued = 1,
    committed = 2,
    scheduled = 3,
    completed = 4,
    @"error" = 5,
    _,
};

/// `MTLCommandBufferErrorOption`.
pub const CommandBufferErrorOption = packed struct(u64) {
    encoder_execution_status: bool = false,
    _1: u63 = 0,
    pub const none: CommandBufferErrorOption = @fromBackingInt(0x0);
};

/// `MTLDispatchType`.
pub const DispatchType = enum(objc.UInteger) {
    serial = 0,
    concurrent = 1,
    _,
};

/// `MTLFunctionType`.
pub const FunctionType = enum(objc.UInteger) {
    vertex = 1,
    fragment = 2,
    kernel = 3,
    visible = 5,
    intersection = 6,
    mesh = 7,
    object = 8,
    _,
};

/// `MTLLanguageVersion`.
pub const LanguageVersion = enum(objc.UInteger) {
    @"1_0" = 65536,
    @"1_1" = 65537,
    @"1_2" = 65538,
    @"2_0" = 131072,
    @"2_1" = 131073,
    @"2_2" = 131074,
    @"2_3" = 131075,
    @"2_4" = 131076,
    @"3_0" = 196608,
    @"3_1" = 196609,
    @"3_2" = 196610,
    @"4_0" = 262144,
    @"4_1" = 262145,
    _,
};

/// `MTLLibraryType`.
pub const LibraryType = enum(objc.Integer) {
    executable = 0,
    dynamic = 1,
    _,
};

/// `MTLLibraryOptimizationLevel`.
pub const LibraryOptimizationLevel = enum(objc.Integer) {
    default = 0,
    size = 1,
    _,
};

/// `MTLCompileSymbolVisibility`.
pub const CompileSymbolVisibility = enum(objc.Integer) {
    default = 0,
    hidden = 1,
    _,
};

/// `MTLMathMode`.
pub const MathMode = enum(objc.Integer) {
    safe = 0,
    relaxed = 1,
    fast = 2,
    _,
};

/// `MTLMathFloatingPointFunctions`.
pub const MathFloatingPointFunctions = enum(objc.Integer) {
    fast = 0,
    precise = 1,
    _,
};

/// `MTLGPUFamily`.
pub const GPUFamily = enum(objc.Integer) {
    apple1 = 1001,
    apple2 = 1002,
    apple3 = 1003,
    apple4 = 1004,
    apple5 = 1005,
    apple6 = 1006,
    apple7 = 1007,
    apple8 = 1008,
    apple9 = 1009,
    apple10 = 1010,
    apple11 = 1011,
    mac1 = 2001,
    mac2 = 2002,
    common1 = 3001,
    common2 = 3002,
    common3 = 3003,
    mac_catalyst1 = 4001,
    mac_catalyst2 = 4002,
    metal3 = 5001,
    metal4 = 5002,
    _,
};

/// `MTLDeviceLocation`.
pub const DeviceLocation = enum(objc.UInteger) {
    built_in = 0,
    slot = 1,
    external = 2,
    unspecified = 18446744073709551615,
    _,
};

/// `MTLReadWriteTextureTier`.
pub const ReadWriteTextureTier = enum(objc.UInteger) {
    none = 0,
    @"1" = 1,
    @"2" = 2,
    _,
};

/// `MTLArgumentBuffersTier`.
pub const ArgumentBuffersTier = enum(objc.UInteger) {
    @"1" = 0,
    @"2" = 1,
    _,
};

/// `MTLSparsePageSize`.
pub const SparsePageSize = enum(objc.Integer) {
    @"16" = 101,
    @"64" = 102,
    @"256" = 103,
    _,
};

/// `MTLSparseTextureRegionAlignmentMode`.
pub const SparseTextureRegionAlignmentMode = enum(objc.UInteger) {
    outward = 0,
    inward = 1,
    _,
};

/// `MTLCounterSamplingPoint`.
pub const CounterSamplingPoint = enum(objc.UInteger) {
    stage_boundary = 0,
    draw_boundary = 1,
    dispatch_boundary = 2,
    tile_dispatch_boundary = 3,
    blit_boundary = 4,
    _,
};

/// `MTLMultisampleDepthResolveFilter`.
pub const MultisampleDepthResolveFilter = enum(objc.UInteger) {
    sample0 = 0,
    min = 1,
    max = 2,
    _,
};

/// `MTLMultisampleStencilResolveFilter`.
pub const MultisampleStencilResolveFilter = enum(objc.UInteger) {
    sample0 = 0,
    depth_resolved_sample = 1,
    _,
};

/// `MTLVisibilityResultMode`.
pub const VisibilityResultMode = enum(objc.UInteger) {
    disabled = 0,
    boolean = 1,
    counting = 2,
    _,
};

/// `MTLRenderStages`.
pub const RenderStages = packed struct(u64) {
    vertex: bool = false,
    fragment: bool = false,
    tile: bool = false,
    object: bool = false,
    mesh: bool = false,
    _5: u59 = 0,
};

/// `MTLBarrierScope`.
pub const BarrierScope = packed struct(u64) {
    buffers: bool = false,
    textures: bool = false,
    render_targets: bool = false,
    _3: u61 = 0,
};

/// `MTLResourceUsage`.
pub const ResourceUsage = packed struct(u64) {
    read: bool = false,
    write: bool = false,
    sample: bool = false,
    _3: u61 = 0,
};

/// `MTLBlitOption`.
pub const BlitOption = packed struct(u64) {
    depth_from_depth_stencil: bool = false,
    stencil_from_depth_stencil: bool = false,
    row_linear_pvrtc: bool = false,
    _3: u61 = 0,
    pub const none: BlitOption = @fromBackingInt(0x0);
};

/// `MTLShaderValidation`.
pub const ShaderValidation = enum(objc.Integer) {
    default = 0,
    enabled = 1,
    disabled = 2,
    _,
};

/// `MTLPipelineOption`.
pub const PipelineOption = packed struct(u64) {
    argument_info: bool = false,
    buffer_type_info: bool = false,
    fail_on_binary_archive_miss: bool = false,
    _3: u61 = 0,
    pub const none: PipelineOption = @fromBackingInt(0x0);
    pub const binding_info: PipelineOption = @fromBackingInt(0x1);
};

/// `MTLIOCompressionMethod`.
pub const IOCompressionMethod = enum(objc.Integer) {
    zlib = 0,
    lzfse = 1,
    lz4 = 2,
    lzma = 3,
    lz_bitmap = 4,
    _,
};

/// `MTLForwardProgressUsage`.
pub const ForwardProgressUsage = enum(objc.Integer) {
    automatic = 0,
    weak = 1,
    simd_group_parallel = 2,
    _,
};

/// `MTLVisibilityResultType`.
pub const VisibilityResultType = enum(objc.Integer) {
    reset = 0,
    accumulate = 1,
    _,
};

/// `MTLTessellationPartitionMode`.
pub const TessellationPartitionMode = enum(objc.UInteger) {
    pow2 = 0,
    integer = 1,
    fractional_odd = 2,
    fractional_even = 3,
    _,
};

/// `MTLTessellationFactorStepFunction`.
pub const TessellationFactorStepFunction = enum(objc.UInteger) {
    constant = 0,
    per_patch = 1,
    per_instance = 2,
    per_patch_and_per_instance = 3,
    _,
};

/// `MTLTessellationFactorFormat`.
pub const TessellationFactorFormat = enum(objc.UInteger) {
    half = 0,
    _,
};

/// `MTLTessellationControlPointIndexType`.
pub const TessellationControlPointIndexType = enum(objc.UInteger) {
    none = 0,
    u_int16 = 1,
    u_int32 = 2,
    _,
};

/// `MTLSamplerReductionMode`.
pub const SamplerReductionMode = enum(objc.UInteger) {
    weighted_average = 0,
    minimum = 1,
    maximum = 2,
    _,
};

/// `MTLFloatingPointConversionRoundingMode`.
pub const FloatingPointConversionRoundingMode = enum(objc.Integer) {
    to_nearest_even = 0,
    toward_zero = 1,
    _,
};

/// `MTLContentionRelief`.
pub const ContentionRelief = enum(objc.Integer) {
    automatic = 0,
    none = 1,
    _,
};

/// `MTLTextureSparseTier`.
pub const TextureSparseTier = enum(objc.Integer) {
    none = 0,
    @"1" = 1,
    @"2" = 2,
    _,
};

/// `MTLBufferSparseTier`.
pub const BufferSparseTier = enum(objc.Integer) {
    none = 0,
    @"1" = 1,
    _,
};

/// `MTLTensorPlaneType`.
pub const TensorPlaneType = enum(objc.Integer) {
    data = 0,
    scales = 1,
    _,
};

/// `MTLStages`.
pub const Stages = packed struct(u64) {
    vertex: bool = false,
    fragment: bool = false,
    tile: bool = false,
    object: bool = false,
    mesh: bool = false,
    _5: u21 = 0,
    resource_state: bool = false,
    dispatch: bool = false,
    blit: bool = false,
    acceleration_structure: bool = false,
    machine_learning: bool = false,
    _31: u33 = 0,
    pub const all: Stages = @fromBackingInt(0x7fffffffffffffff);
};

/// `MTLPatchType`.
pub const PatchType = enum(objc.UInteger) {
    none = 0,
    triangle = 1,
    quad = 2,
    _,
};

/// `MTLFunctionOptions`.
pub const FunctionOptions = packed struct(u64) {
    compile_to_binary: bool = false,
    store_function_in_metal_pipelines_script: bool = false,
    fail_on_binary_archive_miss: bool = false,
    pipeline_independent: bool = false,
    _4: u60 = 0,
    pub const none: FunctionOptions = @fromBackingInt(0x0);
    pub const store_function_in_metal_script: FunctionOptions = @fromBackingInt(0x2);
};

/// `MTLFeatureSet`.
pub const FeatureSet = enum(objc.UInteger) {
    set_i_os_gpu_family1_v1 = 0,
    set_i_os_gpu_family2_v1 = 1,
    set_i_os_gpu_family1_v2 = 2,
    set_i_os_gpu_family2_v2 = 3,
    set_i_os_gpu_family3_v1 = 4,
    set_i_os_gpu_family1_v3 = 5,
    set_i_os_gpu_family2_v3 = 6,
    set_i_os_gpu_family3_v2 = 7,
    set_i_os_gpu_family1_v4 = 8,
    set_i_os_gpu_family2_v4 = 9,
    set_i_os_gpu_family3_v3 = 10,
    set_i_os_gpu_family4_v1 = 11,
    set_i_os_gpu_family1_v5 = 12,
    set_i_os_gpu_family2_v5 = 13,
    set_i_os_gpu_family3_v4 = 14,
    set_i_os_gpu_family4_v2 = 15,
    set_i_os_gpu_family5_v1 = 16,
    set_mac_os_gpu_family1_v1 = 10000,
    set_mac_os_gpu_family1_v2 = 10001,
    set_mac_os_read_write_texture_tier2 = 10002,
    set_mac_os_gpu_family1_v3 = 10003,
    set_mac_os_gpu_family1_v4 = 10004,
    set_mac_os_gpu_family2_v1 = 10005,
    set_tv_os_gpu_family1_v1 = 30000,
    set_tv_os_gpu_family1_v2 = 30001,
    set_tv_os_gpu_family1_v3 = 30002,
    set_tv_os_gpu_family2_v1 = 30003,
    set_tv_os_gpu_family1_v4 = 30004,
    set_tv_os_gpu_family2_v2 = 30005,
    _,
    pub const set_osx_gpu_family1_v1: FeatureSet = .set_mac_os_gpu_family1_v1;
    pub const set_osx_gpu_family1_v2: FeatureSet = .set_mac_os_gpu_family1_v2;
    pub const set_osx_read_write_texture_tier2: FeatureSet = .set_mac_os_read_write_texture_tier2;
    pub const set_tvos_gpu_family1_v1: FeatureSet = .set_tv_os_gpu_family1_v1;
};

/// `MTL4CounterHeapType`.
pub const MTL4CounterHeapType = enum(objc.Integer) {
    invalid = 0,
    timestamp = 1,
    _,
};

/// `CAEdgeAntialiasingMask`.
pub const EdgeAntialiasingMask = packed struct(u32) {
    left_edge: bool = false,
    right_edge: bool = false,
    bottom_edge: bool = false,
    top_edge: bool = false,
    _4: u28 = 0,
};

/// `CACornerMask`.
pub const CornerMask = packed struct(u64) {
    min_x_min_y_corner: bool = false,
    max_x_min_y_corner: bool = false,
    min_x_max_y_corner: bool = false,
    max_x_max_y_corner: bool = false,
    _4: u60 = 0,
};

/// `CAAutoresizingMask`.
pub const AutoresizingMask = packed struct(u32) {
    min_x_margin: bool = false,
    width_sizable: bool = false,
    max_x_margin: bool = false,
    min_y_margin: bool = false,
    height_sizable: bool = false,
    max_y_margin: bool = false,
    _6: u26 = 0,
    pub const not_sizable: AutoresizingMask = @fromBackingInt(0x0);
};

/// `MTLRenderPassDescriptor`, a subclass of `NSObject`.
pub const RenderPassDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLRenderPassDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLRenderPassDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLRenderPassDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `+[MTLRenderPassDescriptor renderPassDescriptor]`
    pub fn renderPassDescriptor() RenderPassDescriptor {
        return class().msgSend(RenderPassDescriptor, "renderPassDescriptor", .{});
    }

    /// `-[MTLRenderPassDescriptor setSamplePositions:count:]`
    pub fn setSamplePositionsCount(self: Self, positions: ?objc.Object, count: objc.UInteger) void {
        return self.object.msgSend(void, "setSamplePositions:count:", .{ positions, count });
    }

    /// `-[MTLRenderPassDescriptor getSamplePositions:count:]`
    pub fn getSamplePositionsCount(self: Self, positions: ?objc.Object, count: objc.UInteger) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "getSamplePositions:count:", .{ positions, count });
    }

    /// `-[MTLRenderPassDescriptor colorAttachments]`
    pub fn colorAttachments(self: Self) RenderPassColorAttachmentDescriptorArray {
        return self.object.msgSend(RenderPassColorAttachmentDescriptorArray, "colorAttachments", .{});
    }

    /// `-[MTLRenderPassDescriptor depthAttachment]`
    pub fn depthAttachment(self: Self) RenderPassDepthAttachmentDescriptor {
        return self.object.msgSend(RenderPassDepthAttachmentDescriptor, "depthAttachment", .{});
    }

    /// `-[MTLRenderPassDescriptor setDepthAttachment:]`
    pub fn setDepthAttachment(self: Self, depth_attachment: ?RenderPassDepthAttachmentDescriptor) void {
        return self.object.msgSend(void, "setDepthAttachment:", .{depth_attachment});
    }

    /// `-[MTLRenderPassDescriptor stencilAttachment]`
    pub fn stencilAttachment(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "stencilAttachment", .{});
    }

    /// `-[MTLRenderPassDescriptor setStencilAttachment:]`
    pub fn setStencilAttachment(self: Self, stencil_attachment: ?objc.Object) void {
        return self.object.msgSend(void, "setStencilAttachment:", .{stencil_attachment});
    }

    /// `-[MTLRenderPassDescriptor visibilityResultBuffer]`
    pub fn visibilityResultBuffer(self: Self) ?Buffer {
        return self.object.msgSend(?Buffer, "visibilityResultBuffer", .{});
    }

    /// `-[MTLRenderPassDescriptor setVisibilityResultBuffer:]`
    pub fn setVisibilityResultBuffer(self: Self, visibility_result_buffer: ?Buffer) void {
        return self.object.msgSend(void, "setVisibilityResultBuffer:", .{visibility_result_buffer});
    }

    /// `-[MTLRenderPassDescriptor renderTargetArrayLength]`
    pub fn renderTargetArrayLength(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "renderTargetArrayLength", .{});
    }

    /// `-[MTLRenderPassDescriptor setRenderTargetArrayLength:]`
    pub fn setRenderTargetArrayLength(self: Self, render_target_array_length: objc.UInteger) void {
        return self.object.msgSend(void, "setRenderTargetArrayLength:", .{render_target_array_length});
    }

    /// `-[MTLRenderPassDescriptor imageblockSampleLength]`
    pub fn imageblockSampleLength(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "imageblockSampleLength", .{});
    }

    /// `-[MTLRenderPassDescriptor setImageblockSampleLength:]`
    pub fn setImageblockSampleLength(self: Self, imageblock_sample_length: objc.UInteger) void {
        return self.object.msgSend(void, "setImageblockSampleLength:", .{imageblock_sample_length});
    }

    /// `-[MTLRenderPassDescriptor threadgroupMemoryLength]`
    pub fn threadgroupMemoryLength(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "threadgroupMemoryLength", .{});
    }

    /// `-[MTLRenderPassDescriptor setThreadgroupMemoryLength:]`
    pub fn setThreadgroupMemoryLength(self: Self, threadgroup_memory_length: objc.UInteger) void {
        return self.object.msgSend(void, "setThreadgroupMemoryLength:", .{threadgroup_memory_length});
    }

    /// `-[MTLRenderPassDescriptor tileWidth]`
    pub fn tileWidth(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "tileWidth", .{});
    }

    /// `-[MTLRenderPassDescriptor setTileWidth:]`
    pub fn setTileWidth(self: Self, tile_width: objc.UInteger) void {
        return self.object.msgSend(void, "setTileWidth:", .{tile_width});
    }

    /// `-[MTLRenderPassDescriptor tileHeight]`
    pub fn tileHeight(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "tileHeight", .{});
    }

    /// `-[MTLRenderPassDescriptor setTileHeight:]`
    pub fn setTileHeight(self: Self, tile_height: objc.UInteger) void {
        return self.object.msgSend(void, "setTileHeight:", .{tile_height});
    }

    /// `-[MTLRenderPassDescriptor defaultRasterSampleCount]`
    pub fn defaultRasterSampleCount(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "defaultRasterSampleCount", .{});
    }

    /// `-[MTLRenderPassDescriptor setDefaultRasterSampleCount:]`
    pub fn setDefaultRasterSampleCount(self: Self, default_raster_sample_count: objc.UInteger) void {
        return self.object.msgSend(void, "setDefaultRasterSampleCount:", .{default_raster_sample_count});
    }

    /// `-[MTLRenderPassDescriptor renderTargetWidth]`
    pub fn renderTargetWidth(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "renderTargetWidth", .{});
    }

    /// `-[MTLRenderPassDescriptor setRenderTargetWidth:]`
    pub fn setRenderTargetWidth(self: Self, render_target_width: objc.UInteger) void {
        return self.object.msgSend(void, "setRenderTargetWidth:", .{render_target_width});
    }

    /// `-[MTLRenderPassDescriptor renderTargetHeight]`
    pub fn renderTargetHeight(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "renderTargetHeight", .{});
    }

    /// `-[MTLRenderPassDescriptor setRenderTargetHeight:]`
    pub fn setRenderTargetHeight(self: Self, render_target_height: objc.UInteger) void {
        return self.object.msgSend(void, "setRenderTargetHeight:", .{render_target_height});
    }

    /// `-[MTLRenderPassDescriptor rasterizationRateMap]`
    pub fn rasterizationRateMap(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "rasterizationRateMap", .{});
    }

    /// `-[MTLRenderPassDescriptor setRasterizationRateMap:]`
    pub fn setRasterizationRateMap(self: Self, rasterization_rate_map: ?objc.Object) void {
        return self.object.msgSend(void, "setRasterizationRateMap:", .{rasterization_rate_map});
    }

    /// `-[MTLRenderPassDescriptor sampleBufferAttachments]`
    pub fn sampleBufferAttachments(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "sampleBufferAttachments", .{});
    }

    /// `-[MTLRenderPassDescriptor visibilityResultType]`
    pub fn visibilityResultType(self: Self) VisibilityResultType {
        return self.object.msgSend(VisibilityResultType, "visibilityResultType", .{});
    }

    /// `-[MTLRenderPassDescriptor setVisibilityResultType:]`
    pub fn setVisibilityResultType(self: Self, visibility_result_type: VisibilityResultType) void {
        return self.object.msgSend(void, "setVisibilityResultType:", .{visibility_result_type});
    }

    /// `-[MTLRenderPassDescriptor supportColorAttachmentMapping]`
    pub fn supportColorAttachmentMapping(self: Self) bool {
        return self.object.msgSend(bool, "supportColorAttachmentMapping", .{});
    }

    /// `-[MTLRenderPassDescriptor setSupportColorAttachmentMapping:]`
    pub fn setSupportColorAttachmentMapping(self: Self, support_color_attachment_mapping: bool) void {
        return self.object.msgSend(void, "setSupportColorAttachmentMapping:", .{support_color_attachment_mapping});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"+renderPassDescriptor" = fn () RenderPassDescriptor;
        pub const @"-setSamplePositions:count:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-getSamplePositions:count:" = fn (?objc.Object, objc.UInteger) objc.UInteger;
        pub const @"-colorAttachments" = fn () RenderPassColorAttachmentDescriptorArray;
        pub const @"-depthAttachment" = fn () RenderPassDepthAttachmentDescriptor;
        pub const @"-setDepthAttachment:" = fn (?RenderPassDepthAttachmentDescriptor) void;
        pub const @"-stencilAttachment" = fn () objc.Object;
        pub const @"-setStencilAttachment:" = fn (?objc.Object) void;
        pub const @"-visibilityResultBuffer" = fn () ?Buffer;
        pub const @"-setVisibilityResultBuffer:" = fn (?Buffer) void;
        pub const @"-renderTargetArrayLength" = fn () objc.UInteger;
        pub const @"-setRenderTargetArrayLength:" = fn (objc.UInteger) void;
        pub const @"-imageblockSampleLength" = fn () objc.UInteger;
        pub const @"-setImageblockSampleLength:" = fn (objc.UInteger) void;
        pub const @"-threadgroupMemoryLength" = fn () objc.UInteger;
        pub const @"-setThreadgroupMemoryLength:" = fn (objc.UInteger) void;
        pub const @"-tileWidth" = fn () objc.UInteger;
        pub const @"-setTileWidth:" = fn (objc.UInteger) void;
        pub const @"-tileHeight" = fn () objc.UInteger;
        pub const @"-setTileHeight:" = fn (objc.UInteger) void;
        pub const @"-defaultRasterSampleCount" = fn () objc.UInteger;
        pub const @"-setDefaultRasterSampleCount:" = fn (objc.UInteger) void;
        pub const @"-renderTargetWidth" = fn () objc.UInteger;
        pub const @"-setRenderTargetWidth:" = fn (objc.UInteger) void;
        pub const @"-renderTargetHeight" = fn () objc.UInteger;
        pub const @"-setRenderTargetHeight:" = fn (objc.UInteger) void;
        pub const @"-rasterizationRateMap" = fn () ?objc.Object;
        pub const @"-setRasterizationRateMap:" = fn (?objc.Object) void;
        pub const @"-sampleBufferAttachments" = fn () objc.Object;
        pub const @"-visibilityResultType" = fn () VisibilityResultType;
        pub const @"-setVisibilityResultType:" = fn (VisibilityResultType) void;
        pub const @"-supportColorAttachmentMapping" = fn () bool;
        pub const @"-setSupportColorAttachmentMapping:" = fn (bool) void;
    };
};

/// `MTLRenderPassAttachmentDescriptor`, a subclass of `NSObject`.
pub const RenderPassAttachmentDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLRenderPassAttachmentDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLRenderPassAttachmentDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLRenderPassAttachmentDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLRenderPassAttachmentDescriptor texture]`
    pub fn texture(self: Self) ?Texture {
        return self.object.msgSend(?Texture, "texture", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setTexture:]`
    pub fn setTexture(self: Self, texture_: ?Texture) void {
        return self.object.msgSend(void, "setTexture:", .{texture_});
    }

    /// `-[MTLRenderPassAttachmentDescriptor level]`
    pub fn level(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "level", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setLevel:]`
    pub fn setLevel(self: Self, level_: objc.UInteger) void {
        return self.object.msgSend(void, "setLevel:", .{level_});
    }

    /// `-[MTLRenderPassAttachmentDescriptor slice]`
    pub fn slice(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "slice", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setSlice:]`
    pub fn setSlice(self: Self, slice_: objc.UInteger) void {
        return self.object.msgSend(void, "setSlice:", .{slice_});
    }

    /// `-[MTLRenderPassAttachmentDescriptor depthPlane]`
    pub fn depthPlane(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "depthPlane", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setDepthPlane:]`
    pub fn setDepthPlane(self: Self, depth_plane: objc.UInteger) void {
        return self.object.msgSend(void, "setDepthPlane:", .{depth_plane});
    }

    /// `-[MTLRenderPassAttachmentDescriptor resolveTexture]`
    pub fn resolveTexture(self: Self) ?Texture {
        return self.object.msgSend(?Texture, "resolveTexture", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setResolveTexture:]`
    pub fn setResolveTexture(self: Self, resolve_texture: ?Texture) void {
        return self.object.msgSend(void, "setResolveTexture:", .{resolve_texture});
    }

    /// `-[MTLRenderPassAttachmentDescriptor resolveLevel]`
    pub fn resolveLevel(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "resolveLevel", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setResolveLevel:]`
    pub fn setResolveLevel(self: Self, resolve_level: objc.UInteger) void {
        return self.object.msgSend(void, "setResolveLevel:", .{resolve_level});
    }

    /// `-[MTLRenderPassAttachmentDescriptor resolveSlice]`
    pub fn resolveSlice(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "resolveSlice", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setResolveSlice:]`
    pub fn setResolveSlice(self: Self, resolve_slice: objc.UInteger) void {
        return self.object.msgSend(void, "setResolveSlice:", .{resolve_slice});
    }

    /// `-[MTLRenderPassAttachmentDescriptor resolveDepthPlane]`
    pub fn resolveDepthPlane(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "resolveDepthPlane", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setResolveDepthPlane:]`
    pub fn setResolveDepthPlane(self: Self, resolve_depth_plane: objc.UInteger) void {
        return self.object.msgSend(void, "setResolveDepthPlane:", .{resolve_depth_plane});
    }

    /// `-[MTLRenderPassAttachmentDescriptor loadAction]`
    pub fn loadAction(self: Self) LoadAction {
        return self.object.msgSend(LoadAction, "loadAction", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setLoadAction:]`
    pub fn setLoadAction(self: Self, load_action: LoadAction) void {
        return self.object.msgSend(void, "setLoadAction:", .{load_action});
    }

    /// `-[MTLRenderPassAttachmentDescriptor storeAction]`
    pub fn storeAction(self: Self) StoreAction {
        return self.object.msgSend(StoreAction, "storeAction", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setStoreAction:]`
    pub fn setStoreAction(self: Self, store_action: StoreAction) void {
        return self.object.msgSend(void, "setStoreAction:", .{store_action});
    }

    /// `-[MTLRenderPassAttachmentDescriptor storeActionOptions]`
    pub fn storeActionOptions(self: Self) StoreActionOptions {
        return self.object.msgSend(StoreActionOptions, "storeActionOptions", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setStoreActionOptions:]`
    pub fn setStoreActionOptions(self: Self, store_action_options: StoreActionOptions) void {
        return self.object.msgSend(void, "setStoreActionOptions:", .{store_action_options});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-texture" = fn () ?Texture;
        pub const @"-setTexture:" = fn (?Texture) void;
        pub const @"-level" = fn () objc.UInteger;
        pub const @"-setLevel:" = fn (objc.UInteger) void;
        pub const @"-slice" = fn () objc.UInteger;
        pub const @"-setSlice:" = fn (objc.UInteger) void;
        pub const @"-depthPlane" = fn () objc.UInteger;
        pub const @"-setDepthPlane:" = fn (objc.UInteger) void;
        pub const @"-resolveTexture" = fn () ?Texture;
        pub const @"-setResolveTexture:" = fn (?Texture) void;
        pub const @"-resolveLevel" = fn () objc.UInteger;
        pub const @"-setResolveLevel:" = fn (objc.UInteger) void;
        pub const @"-resolveSlice" = fn () objc.UInteger;
        pub const @"-setResolveSlice:" = fn (objc.UInteger) void;
        pub const @"-resolveDepthPlane" = fn () objc.UInteger;
        pub const @"-setResolveDepthPlane:" = fn (objc.UInteger) void;
        pub const @"-loadAction" = fn () LoadAction;
        pub const @"-setLoadAction:" = fn (LoadAction) void;
        pub const @"-storeAction" = fn () StoreAction;
        pub const @"-setStoreAction:" = fn (StoreAction) void;
        pub const @"-storeActionOptions" = fn () StoreActionOptions;
        pub const @"-setStoreActionOptions:" = fn (StoreActionOptions) void;
    };
};

/// `MTLRenderPassColorAttachmentDescriptor`, a subclass of `MTLRenderPassAttachmentDescriptor`.
pub const RenderPassColorAttachmentDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = RenderPassAttachmentDescriptor;
    pub const class_name = "MTLRenderPassColorAttachmentDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLRenderPassColorAttachmentDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLRenderPassColorAttachmentDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLRenderPassColorAttachmentDescriptor clearColor]`
    pub fn clearColor(self: Self) ClearColor {
        return self.object.msgSend(ClearColor, "clearColor", .{});
    }

    /// `-[MTLRenderPassColorAttachmentDescriptor setClearColor:]`
    pub fn setClearColor(self: Self, clear_color: ClearColor) void {
        return self.object.msgSend(void, "setClearColor:", .{clear_color});
    }

    /// `-[MTLRenderPassAttachmentDescriptor texture]`
    pub fn texture(self: Self) ?Texture {
        return self.object.msgSend(?Texture, "texture", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setTexture:]`
    pub fn setTexture(self: Self, texture_: ?Texture) void {
        return self.object.msgSend(void, "setTexture:", .{texture_});
    }

    /// `-[MTLRenderPassAttachmentDescriptor level]`
    pub fn level(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "level", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setLevel:]`
    pub fn setLevel(self: Self, level_: objc.UInteger) void {
        return self.object.msgSend(void, "setLevel:", .{level_});
    }

    /// `-[MTLRenderPassAttachmentDescriptor slice]`
    pub fn slice(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "slice", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setSlice:]`
    pub fn setSlice(self: Self, slice_: objc.UInteger) void {
        return self.object.msgSend(void, "setSlice:", .{slice_});
    }

    /// `-[MTLRenderPassAttachmentDescriptor depthPlane]`
    pub fn depthPlane(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "depthPlane", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setDepthPlane:]`
    pub fn setDepthPlane(self: Self, depth_plane: objc.UInteger) void {
        return self.object.msgSend(void, "setDepthPlane:", .{depth_plane});
    }

    /// `-[MTLRenderPassAttachmentDescriptor resolveTexture]`
    pub fn resolveTexture(self: Self) ?Texture {
        return self.object.msgSend(?Texture, "resolveTexture", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setResolveTexture:]`
    pub fn setResolveTexture(self: Self, resolve_texture: ?Texture) void {
        return self.object.msgSend(void, "setResolveTexture:", .{resolve_texture});
    }

    /// `-[MTLRenderPassAttachmentDescriptor resolveLevel]`
    pub fn resolveLevel(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "resolveLevel", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setResolveLevel:]`
    pub fn setResolveLevel(self: Self, resolve_level: objc.UInteger) void {
        return self.object.msgSend(void, "setResolveLevel:", .{resolve_level});
    }

    /// `-[MTLRenderPassAttachmentDescriptor resolveSlice]`
    pub fn resolveSlice(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "resolveSlice", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setResolveSlice:]`
    pub fn setResolveSlice(self: Self, resolve_slice: objc.UInteger) void {
        return self.object.msgSend(void, "setResolveSlice:", .{resolve_slice});
    }

    /// `-[MTLRenderPassAttachmentDescriptor resolveDepthPlane]`
    pub fn resolveDepthPlane(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "resolveDepthPlane", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setResolveDepthPlane:]`
    pub fn setResolveDepthPlane(self: Self, resolve_depth_plane: objc.UInteger) void {
        return self.object.msgSend(void, "setResolveDepthPlane:", .{resolve_depth_plane});
    }

    /// `-[MTLRenderPassAttachmentDescriptor loadAction]`
    pub fn loadAction(self: Self) LoadAction {
        return self.object.msgSend(LoadAction, "loadAction", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setLoadAction:]`
    pub fn setLoadAction(self: Self, load_action: LoadAction) void {
        return self.object.msgSend(void, "setLoadAction:", .{load_action});
    }

    /// `-[MTLRenderPassAttachmentDescriptor storeAction]`
    pub fn storeAction(self: Self) StoreAction {
        return self.object.msgSend(StoreAction, "storeAction", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setStoreAction:]`
    pub fn setStoreAction(self: Self, store_action: StoreAction) void {
        return self.object.msgSend(void, "setStoreAction:", .{store_action});
    }

    /// `-[MTLRenderPassAttachmentDescriptor storeActionOptions]`
    pub fn storeActionOptions(self: Self) StoreActionOptions {
        return self.object.msgSend(StoreActionOptions, "storeActionOptions", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setStoreActionOptions:]`
    pub fn setStoreActionOptions(self: Self, store_action_options: StoreActionOptions) void {
        return self.object.msgSend(void, "setStoreActionOptions:", .{store_action_options});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-clearColor" = fn () ClearColor;
        pub const @"-setClearColor:" = fn (ClearColor) void;
    };
};

/// `MTLRenderPassColorAttachmentDescriptorArray`, a subclass of `NSObject`.
pub const RenderPassColorAttachmentDescriptorArray = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLRenderPassColorAttachmentDescriptorArray";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLRenderPassColorAttachmentDescriptorArray alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLRenderPassColorAttachmentDescriptorArray`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLRenderPassColorAttachmentDescriptorArray objectAtIndexedSubscript:]`
    pub fn objectAtIndexedSubscript(self: Self, attachment_index: objc.UInteger) RenderPassColorAttachmentDescriptor {
        return self.object.msgSend(RenderPassColorAttachmentDescriptor, "objectAtIndexedSubscript:", .{attachment_index});
    }

    /// `-[MTLRenderPassColorAttachmentDescriptorArray setObject:atIndexedSubscript:]`
    pub fn setObjectAtIndexedSubscript(self: Self, attachment: ?RenderPassColorAttachmentDescriptor, attachment_index: objc.UInteger) void {
        return self.object.msgSend(void, "setObject:atIndexedSubscript:", .{ attachment, attachment_index });
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-objectAtIndexedSubscript:" = fn (objc.UInteger) RenderPassColorAttachmentDescriptor;
        pub const @"-setObject:atIndexedSubscript:" = fn (?RenderPassColorAttachmentDescriptor, objc.UInteger) void;
    };
};

/// `MTLRenderPassDepthAttachmentDescriptor`, a subclass of `MTLRenderPassAttachmentDescriptor`.
pub const RenderPassDepthAttachmentDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = RenderPassAttachmentDescriptor;
    pub const class_name = "MTLRenderPassDepthAttachmentDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLRenderPassDepthAttachmentDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLRenderPassDepthAttachmentDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLRenderPassDepthAttachmentDescriptor clearDepth]`
    pub fn clearDepth(self: Self) f64 {
        return self.object.msgSend(f64, "clearDepth", .{});
    }

    /// `-[MTLRenderPassDepthAttachmentDescriptor setClearDepth:]`
    pub fn setClearDepth(self: Self, clear_depth: f64) void {
        return self.object.msgSend(void, "setClearDepth:", .{clear_depth});
    }

    /// `-[MTLRenderPassDepthAttachmentDescriptor depthResolveFilter]`
    pub fn depthResolveFilter(self: Self) MultisampleDepthResolveFilter {
        return self.object.msgSend(MultisampleDepthResolveFilter, "depthResolveFilter", .{});
    }

    /// `-[MTLRenderPassDepthAttachmentDescriptor setDepthResolveFilter:]`
    pub fn setDepthResolveFilter(self: Self, depth_resolve_filter: MultisampleDepthResolveFilter) void {
        return self.object.msgSend(void, "setDepthResolveFilter:", .{depth_resolve_filter});
    }

    /// `-[MTLRenderPassAttachmentDescriptor texture]`
    pub fn texture(self: Self) ?Texture {
        return self.object.msgSend(?Texture, "texture", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setTexture:]`
    pub fn setTexture(self: Self, texture_: ?Texture) void {
        return self.object.msgSend(void, "setTexture:", .{texture_});
    }

    /// `-[MTLRenderPassAttachmentDescriptor level]`
    pub fn level(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "level", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setLevel:]`
    pub fn setLevel(self: Self, level_: objc.UInteger) void {
        return self.object.msgSend(void, "setLevel:", .{level_});
    }

    /// `-[MTLRenderPassAttachmentDescriptor slice]`
    pub fn slice(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "slice", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setSlice:]`
    pub fn setSlice(self: Self, slice_: objc.UInteger) void {
        return self.object.msgSend(void, "setSlice:", .{slice_});
    }

    /// `-[MTLRenderPassAttachmentDescriptor depthPlane]`
    pub fn depthPlane(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "depthPlane", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setDepthPlane:]`
    pub fn setDepthPlane(self: Self, depth_plane: objc.UInteger) void {
        return self.object.msgSend(void, "setDepthPlane:", .{depth_plane});
    }

    /// `-[MTLRenderPassAttachmentDescriptor resolveTexture]`
    pub fn resolveTexture(self: Self) ?Texture {
        return self.object.msgSend(?Texture, "resolveTexture", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setResolveTexture:]`
    pub fn setResolveTexture(self: Self, resolve_texture: ?Texture) void {
        return self.object.msgSend(void, "setResolveTexture:", .{resolve_texture});
    }

    /// `-[MTLRenderPassAttachmentDescriptor resolveLevel]`
    pub fn resolveLevel(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "resolveLevel", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setResolveLevel:]`
    pub fn setResolveLevel(self: Self, resolve_level: objc.UInteger) void {
        return self.object.msgSend(void, "setResolveLevel:", .{resolve_level});
    }

    /// `-[MTLRenderPassAttachmentDescriptor resolveSlice]`
    pub fn resolveSlice(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "resolveSlice", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setResolveSlice:]`
    pub fn setResolveSlice(self: Self, resolve_slice: objc.UInteger) void {
        return self.object.msgSend(void, "setResolveSlice:", .{resolve_slice});
    }

    /// `-[MTLRenderPassAttachmentDescriptor resolveDepthPlane]`
    pub fn resolveDepthPlane(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "resolveDepthPlane", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setResolveDepthPlane:]`
    pub fn setResolveDepthPlane(self: Self, resolve_depth_plane: objc.UInteger) void {
        return self.object.msgSend(void, "setResolveDepthPlane:", .{resolve_depth_plane});
    }

    /// `-[MTLRenderPassAttachmentDescriptor loadAction]`
    pub fn loadAction(self: Self) LoadAction {
        return self.object.msgSend(LoadAction, "loadAction", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setLoadAction:]`
    pub fn setLoadAction(self: Self, load_action: LoadAction) void {
        return self.object.msgSend(void, "setLoadAction:", .{load_action});
    }

    /// `-[MTLRenderPassAttachmentDescriptor storeAction]`
    pub fn storeAction(self: Self) StoreAction {
        return self.object.msgSend(StoreAction, "storeAction", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setStoreAction:]`
    pub fn setStoreAction(self: Self, store_action: StoreAction) void {
        return self.object.msgSend(void, "setStoreAction:", .{store_action});
    }

    /// `-[MTLRenderPassAttachmentDescriptor storeActionOptions]`
    pub fn storeActionOptions(self: Self) StoreActionOptions {
        return self.object.msgSend(StoreActionOptions, "storeActionOptions", .{});
    }

    /// `-[MTLRenderPassAttachmentDescriptor setStoreActionOptions:]`
    pub fn setStoreActionOptions(self: Self, store_action_options: StoreActionOptions) void {
        return self.object.msgSend(void, "setStoreActionOptions:", .{store_action_options});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-clearDepth" = fn () f64;
        pub const @"-setClearDepth:" = fn (f64) void;
        pub const @"-depthResolveFilter" = fn () MultisampleDepthResolveFilter;
        pub const @"-setDepthResolveFilter:" = fn (MultisampleDepthResolveFilter) void;
    };
};

/// `MTLRenderPipelineDescriptor`, a subclass of `NSObject`.
pub const RenderPipelineDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLRenderPipelineDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLRenderPipelineDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLRenderPipelineDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLRenderPipelineDescriptor reset]`
    pub fn reset(self: Self) void {
        return self.object.msgSend(void, "reset", .{});
    }

    /// `-[MTLRenderPipelineDescriptor label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// `-[MTLRenderPipelineDescriptor vertexFunction]`
    pub fn vertexFunction(self: Self) ?Function {
        return self.object.msgSend(?Function, "vertexFunction", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setVertexFunction:]`
    pub fn setVertexFunction(self: Self, vertex_function: ?Function) void {
        return self.object.msgSend(void, "setVertexFunction:", .{vertex_function});
    }

    /// `-[MTLRenderPipelineDescriptor fragmentFunction]`
    pub fn fragmentFunction(self: Self) ?Function {
        return self.object.msgSend(?Function, "fragmentFunction", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setFragmentFunction:]`
    pub fn setFragmentFunction(self: Self, fragment_function: ?Function) void {
        return self.object.msgSend(void, "setFragmentFunction:", .{fragment_function});
    }

    /// `-[MTLRenderPipelineDescriptor vertexDescriptor]`
    pub fn vertexDescriptor(self: Self) ?VertexDescriptor {
        return self.object.msgSend(?VertexDescriptor, "vertexDescriptor", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setVertexDescriptor:]`
    pub fn setVertexDescriptor(self: Self, vertex_descriptor: ?VertexDescriptor) void {
        return self.object.msgSend(void, "setVertexDescriptor:", .{vertex_descriptor});
    }

    /// `-[MTLRenderPipelineDescriptor sampleCount]`
    pub fn sampleCount(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "sampleCount", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setSampleCount:]`
    pub fn setSampleCount(self: Self, sample_count: objc.UInteger) void {
        return self.object.msgSend(void, "setSampleCount:", .{sample_count});
    }

    /// `-[MTLRenderPipelineDescriptor rasterSampleCount]`
    pub fn rasterSampleCount(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "rasterSampleCount", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setRasterSampleCount:]`
    pub fn setRasterSampleCount(self: Self, raster_sample_count: objc.UInteger) void {
        return self.object.msgSend(void, "setRasterSampleCount:", .{raster_sample_count});
    }

    /// `-[MTLRenderPipelineDescriptor isAlphaToCoverageEnabled]`
    pub fn isAlphaToCoverageEnabled(self: Self) bool {
        return self.object.msgSend(bool, "isAlphaToCoverageEnabled", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setAlphaToCoverageEnabled:]`
    pub fn setAlphaToCoverageEnabled(self: Self, alpha_to_coverage_enabled: bool) void {
        return self.object.msgSend(void, "setAlphaToCoverageEnabled:", .{alpha_to_coverage_enabled});
    }

    /// `-[MTLRenderPipelineDescriptor isAlphaToOneEnabled]`
    pub fn isAlphaToOneEnabled(self: Self) bool {
        return self.object.msgSend(bool, "isAlphaToOneEnabled", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setAlphaToOneEnabled:]`
    pub fn setAlphaToOneEnabled(self: Self, alpha_to_one_enabled: bool) void {
        return self.object.msgSend(void, "setAlphaToOneEnabled:", .{alpha_to_one_enabled});
    }

    /// `-[MTLRenderPipelineDescriptor isRasterizationEnabled]`
    pub fn isRasterizationEnabled(self: Self) bool {
        return self.object.msgSend(bool, "isRasterizationEnabled", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setRasterizationEnabled:]`
    pub fn setRasterizationEnabled(self: Self, rasterization_enabled: bool) void {
        return self.object.msgSend(void, "setRasterizationEnabled:", .{rasterization_enabled});
    }

    /// `-[MTLRenderPipelineDescriptor maxVertexAmplificationCount]`
    pub fn maxVertexAmplificationCount(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxVertexAmplificationCount", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setMaxVertexAmplificationCount:]`
    pub fn setMaxVertexAmplificationCount(self: Self, max_vertex_amplification_count: objc.UInteger) void {
        return self.object.msgSend(void, "setMaxVertexAmplificationCount:", .{max_vertex_amplification_count});
    }

    /// `-[MTLRenderPipelineDescriptor colorAttachments]`
    pub fn colorAttachments(self: Self) RenderPipelineColorAttachmentDescriptorArray {
        return self.object.msgSend(RenderPipelineColorAttachmentDescriptorArray, "colorAttachments", .{});
    }

    /// `-[MTLRenderPipelineDescriptor depthAttachmentPixelFormat]`
    pub fn depthAttachmentPixelFormat(self: Self) PixelFormat {
        return self.object.msgSend(PixelFormat, "depthAttachmentPixelFormat", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setDepthAttachmentPixelFormat:]`
    pub fn setDepthAttachmentPixelFormat(self: Self, depth_attachment_pixel_format: PixelFormat) void {
        return self.object.msgSend(void, "setDepthAttachmentPixelFormat:", .{depth_attachment_pixel_format});
    }

    /// `-[MTLRenderPipelineDescriptor stencilAttachmentPixelFormat]`
    pub fn stencilAttachmentPixelFormat(self: Self) PixelFormat {
        return self.object.msgSend(PixelFormat, "stencilAttachmentPixelFormat", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setStencilAttachmentPixelFormat:]`
    pub fn setStencilAttachmentPixelFormat(self: Self, stencil_attachment_pixel_format: PixelFormat) void {
        return self.object.msgSend(void, "setStencilAttachmentPixelFormat:", .{stencil_attachment_pixel_format});
    }

    /// `-[MTLRenderPipelineDescriptor inputPrimitiveTopology]`
    pub fn inputPrimitiveTopology(self: Self) PrimitiveTopologyClass {
        return self.object.msgSend(PrimitiveTopologyClass, "inputPrimitiveTopology", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setInputPrimitiveTopology:]`
    pub fn setInputPrimitiveTopology(self: Self, input_primitive_topology: PrimitiveTopologyClass) void {
        return self.object.msgSend(void, "setInputPrimitiveTopology:", .{input_primitive_topology});
    }

    /// `-[MTLRenderPipelineDescriptor tessellationPartitionMode]`
    pub fn tessellationPartitionMode(self: Self) TessellationPartitionMode {
        return self.object.msgSend(TessellationPartitionMode, "tessellationPartitionMode", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setTessellationPartitionMode:]`
    pub fn setTessellationPartitionMode(self: Self, tessellation_partition_mode: TessellationPartitionMode) void {
        return self.object.msgSend(void, "setTessellationPartitionMode:", .{tessellation_partition_mode});
    }

    /// `-[MTLRenderPipelineDescriptor maxTessellationFactor]`
    pub fn maxTessellationFactor(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxTessellationFactor", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setMaxTessellationFactor:]`
    pub fn setMaxTessellationFactor(self: Self, max_tessellation_factor: objc.UInteger) void {
        return self.object.msgSend(void, "setMaxTessellationFactor:", .{max_tessellation_factor});
    }

    /// `-[MTLRenderPipelineDescriptor isTessellationFactorScaleEnabled]`
    pub fn isTessellationFactorScaleEnabled(self: Self) bool {
        return self.object.msgSend(bool, "isTessellationFactorScaleEnabled", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setTessellationFactorScaleEnabled:]`
    pub fn setTessellationFactorScaleEnabled(self: Self, tessellation_factor_scale_enabled: bool) void {
        return self.object.msgSend(void, "setTessellationFactorScaleEnabled:", .{tessellation_factor_scale_enabled});
    }

    /// `-[MTLRenderPipelineDescriptor tessellationFactorFormat]`
    pub fn tessellationFactorFormat(self: Self) TessellationFactorFormat {
        return self.object.msgSend(TessellationFactorFormat, "tessellationFactorFormat", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setTessellationFactorFormat:]`
    pub fn setTessellationFactorFormat(self: Self, tessellation_factor_format: TessellationFactorFormat) void {
        return self.object.msgSend(void, "setTessellationFactorFormat:", .{tessellation_factor_format});
    }

    /// `-[MTLRenderPipelineDescriptor tessellationControlPointIndexType]`
    pub fn tessellationControlPointIndexType(self: Self) TessellationControlPointIndexType {
        return self.object.msgSend(TessellationControlPointIndexType, "tessellationControlPointIndexType", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setTessellationControlPointIndexType:]`
    pub fn setTessellationControlPointIndexType(self: Self, tessellation_control_point_index_type: TessellationControlPointIndexType) void {
        return self.object.msgSend(void, "setTessellationControlPointIndexType:", .{tessellation_control_point_index_type});
    }

    /// `-[MTLRenderPipelineDescriptor tessellationFactorStepFunction]`
    pub fn tessellationFactorStepFunction(self: Self) TessellationFactorStepFunction {
        return self.object.msgSend(TessellationFactorStepFunction, "tessellationFactorStepFunction", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setTessellationFactorStepFunction:]`
    pub fn setTessellationFactorStepFunction(self: Self, tessellation_factor_step_function: TessellationFactorStepFunction) void {
        return self.object.msgSend(void, "setTessellationFactorStepFunction:", .{tessellation_factor_step_function});
    }

    /// `-[MTLRenderPipelineDescriptor tessellationOutputWindingOrder]`
    pub fn tessellationOutputWindingOrder(self: Self) Winding {
        return self.object.msgSend(Winding, "tessellationOutputWindingOrder", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setTessellationOutputWindingOrder:]`
    pub fn setTessellationOutputWindingOrder(self: Self, tessellation_output_winding_order: Winding) void {
        return self.object.msgSend(void, "setTessellationOutputWindingOrder:", .{tessellation_output_winding_order});
    }

    /// `-[MTLRenderPipelineDescriptor vertexBuffers]`
    pub fn vertexBuffers(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "vertexBuffers", .{});
    }

    /// `-[MTLRenderPipelineDescriptor fragmentBuffers]`
    pub fn fragmentBuffers(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "fragmentBuffers", .{});
    }

    /// `-[MTLRenderPipelineDescriptor supportIndirectCommandBuffers]`
    pub fn supportIndirectCommandBuffers(self: Self) bool {
        return self.object.msgSend(bool, "supportIndirectCommandBuffers", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setSupportIndirectCommandBuffers:]`
    pub fn setSupportIndirectCommandBuffers(self: Self, support_indirect_command_buffers: bool) void {
        return self.object.msgSend(void, "setSupportIndirectCommandBuffers:", .{support_indirect_command_buffers});
    }

    /// `-[MTLRenderPipelineDescriptor binaryArchives]`
    pub fn binaryArchives(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "binaryArchives", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setBinaryArchives:]`
    pub fn setBinaryArchives(self: Self, binary_archives: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setBinaryArchives:", .{binary_archives});
    }

    /// `-[MTLRenderPipelineDescriptor vertexPreloadedLibraries]`
    pub fn vertexPreloadedLibraries(self: Self) foundation.Array(objc.Object) {
        return self.object.msgSend(foundation.Array(objc.Object), "vertexPreloadedLibraries", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setVertexPreloadedLibraries:]`
    pub fn setVertexPreloadedLibraries(self: Self, vertex_preloaded_libraries: foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setVertexPreloadedLibraries:", .{vertex_preloaded_libraries});
    }

    /// `-[MTLRenderPipelineDescriptor fragmentPreloadedLibraries]`
    pub fn fragmentPreloadedLibraries(self: Self) foundation.Array(objc.Object) {
        return self.object.msgSend(foundation.Array(objc.Object), "fragmentPreloadedLibraries", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setFragmentPreloadedLibraries:]`
    pub fn setFragmentPreloadedLibraries(self: Self, fragment_preloaded_libraries: foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setFragmentPreloadedLibraries:", .{fragment_preloaded_libraries});
    }

    /// `-[MTLRenderPipelineDescriptor vertexLinkedFunctions]`
    pub fn vertexLinkedFunctions(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "vertexLinkedFunctions", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setVertexLinkedFunctions:]`
    pub fn setVertexLinkedFunctions(self: Self, vertex_linked_functions: ?objc.Object) void {
        return self.object.msgSend(void, "setVertexLinkedFunctions:", .{vertex_linked_functions});
    }

    /// `-[MTLRenderPipelineDescriptor fragmentLinkedFunctions]`
    pub fn fragmentLinkedFunctions(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "fragmentLinkedFunctions", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setFragmentLinkedFunctions:]`
    pub fn setFragmentLinkedFunctions(self: Self, fragment_linked_functions: ?objc.Object) void {
        return self.object.msgSend(void, "setFragmentLinkedFunctions:", .{fragment_linked_functions});
    }

    /// `-[MTLRenderPipelineDescriptor supportAddingVertexBinaryFunctions]`
    pub fn supportAddingVertexBinaryFunctions(self: Self) bool {
        return self.object.msgSend(bool, "supportAddingVertexBinaryFunctions", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setSupportAddingVertexBinaryFunctions:]`
    pub fn setSupportAddingVertexBinaryFunctions(self: Self, support_adding_vertex_binary_functions: bool) void {
        return self.object.msgSend(void, "setSupportAddingVertexBinaryFunctions:", .{support_adding_vertex_binary_functions});
    }

    /// `-[MTLRenderPipelineDescriptor supportAddingFragmentBinaryFunctions]`
    pub fn supportAddingFragmentBinaryFunctions(self: Self) bool {
        return self.object.msgSend(bool, "supportAddingFragmentBinaryFunctions", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setSupportAddingFragmentBinaryFunctions:]`
    pub fn setSupportAddingFragmentBinaryFunctions(self: Self, support_adding_fragment_binary_functions: bool) void {
        return self.object.msgSend(void, "setSupportAddingFragmentBinaryFunctions:", .{support_adding_fragment_binary_functions});
    }

    /// `-[MTLRenderPipelineDescriptor maxVertexCallStackDepth]`
    pub fn maxVertexCallStackDepth(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxVertexCallStackDepth", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setMaxVertexCallStackDepth:]`
    pub fn setMaxVertexCallStackDepth(self: Self, max_vertex_call_stack_depth: objc.UInteger) void {
        return self.object.msgSend(void, "setMaxVertexCallStackDepth:", .{max_vertex_call_stack_depth});
    }

    /// `-[MTLRenderPipelineDescriptor maxFragmentCallStackDepth]`
    pub fn maxFragmentCallStackDepth(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxFragmentCallStackDepth", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setMaxFragmentCallStackDepth:]`
    pub fn setMaxFragmentCallStackDepth(self: Self, max_fragment_call_stack_depth: objc.UInteger) void {
        return self.object.msgSend(void, "setMaxFragmentCallStackDepth:", .{max_fragment_call_stack_depth});
    }

    /// `-[MTLRenderPipelineDescriptor shaderValidation]`
    pub fn shaderValidation(self: Self) ShaderValidation {
        return self.object.msgSend(ShaderValidation, "shaderValidation", .{});
    }

    /// `-[MTLRenderPipelineDescriptor setShaderValidation:]`
    pub fn setShaderValidation(self: Self, shader_validation: ShaderValidation) void {
        return self.object.msgSend(void, "setShaderValidation:", .{shader_validation});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-reset" = fn () void;
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-setLabel:" = fn (?foundation.String) void;
        pub const @"-vertexFunction" = fn () ?Function;
        pub const @"-setVertexFunction:" = fn (?Function) void;
        pub const @"-fragmentFunction" = fn () ?Function;
        pub const @"-setFragmentFunction:" = fn (?Function) void;
        pub const @"-vertexDescriptor" = fn () ?VertexDescriptor;
        pub const @"-setVertexDescriptor:" = fn (?VertexDescriptor) void;
        pub const @"-sampleCount" = fn () objc.UInteger;
        pub const @"-setSampleCount:" = fn (objc.UInteger) void;
        pub const @"-rasterSampleCount" = fn () objc.UInteger;
        pub const @"-setRasterSampleCount:" = fn (objc.UInteger) void;
        pub const @"-isAlphaToCoverageEnabled" = fn () bool;
        pub const @"-setAlphaToCoverageEnabled:" = fn (bool) void;
        pub const @"-isAlphaToOneEnabled" = fn () bool;
        pub const @"-setAlphaToOneEnabled:" = fn (bool) void;
        pub const @"-isRasterizationEnabled" = fn () bool;
        pub const @"-setRasterizationEnabled:" = fn (bool) void;
        pub const @"-maxVertexAmplificationCount" = fn () objc.UInteger;
        pub const @"-setMaxVertexAmplificationCount:" = fn (objc.UInteger) void;
        pub const @"-colorAttachments" = fn () RenderPipelineColorAttachmentDescriptorArray;
        pub const @"-depthAttachmentPixelFormat" = fn () PixelFormat;
        pub const @"-setDepthAttachmentPixelFormat:" = fn (PixelFormat) void;
        pub const @"-stencilAttachmentPixelFormat" = fn () PixelFormat;
        pub const @"-setStencilAttachmentPixelFormat:" = fn (PixelFormat) void;
        pub const @"-inputPrimitiveTopology" = fn () PrimitiveTopologyClass;
        pub const @"-setInputPrimitiveTopology:" = fn (PrimitiveTopologyClass) void;
        pub const @"-tessellationPartitionMode" = fn () TessellationPartitionMode;
        pub const @"-setTessellationPartitionMode:" = fn (TessellationPartitionMode) void;
        pub const @"-maxTessellationFactor" = fn () objc.UInteger;
        pub const @"-setMaxTessellationFactor:" = fn (objc.UInteger) void;
        pub const @"-isTessellationFactorScaleEnabled" = fn () bool;
        pub const @"-setTessellationFactorScaleEnabled:" = fn (bool) void;
        pub const @"-tessellationFactorFormat" = fn () TessellationFactorFormat;
        pub const @"-setTessellationFactorFormat:" = fn (TessellationFactorFormat) void;
        pub const @"-tessellationControlPointIndexType" = fn () TessellationControlPointIndexType;
        pub const @"-setTessellationControlPointIndexType:" = fn (TessellationControlPointIndexType) void;
        pub const @"-tessellationFactorStepFunction" = fn () TessellationFactorStepFunction;
        pub const @"-setTessellationFactorStepFunction:" = fn (TessellationFactorStepFunction) void;
        pub const @"-tessellationOutputWindingOrder" = fn () Winding;
        pub const @"-setTessellationOutputWindingOrder:" = fn (Winding) void;
        pub const @"-vertexBuffers" = fn () objc.Object;
        pub const @"-fragmentBuffers" = fn () objc.Object;
        pub const @"-supportIndirectCommandBuffers" = fn () bool;
        pub const @"-setSupportIndirectCommandBuffers:" = fn (bool) void;
        pub const @"-binaryArchives" = fn () ?foundation.Array(objc.Object);
        pub const @"-setBinaryArchives:" = fn (?foundation.Array(objc.Object)) void;
        pub const @"-vertexPreloadedLibraries" = fn () foundation.Array(objc.Object);
        pub const @"-setVertexPreloadedLibraries:" = fn (foundation.Array(objc.Object)) void;
        pub const @"-fragmentPreloadedLibraries" = fn () foundation.Array(objc.Object);
        pub const @"-setFragmentPreloadedLibraries:" = fn (foundation.Array(objc.Object)) void;
        pub const @"-vertexLinkedFunctions" = fn () objc.Object;
        pub const @"-setVertexLinkedFunctions:" = fn (?objc.Object) void;
        pub const @"-fragmentLinkedFunctions" = fn () objc.Object;
        pub const @"-setFragmentLinkedFunctions:" = fn (?objc.Object) void;
        pub const @"-supportAddingVertexBinaryFunctions" = fn () bool;
        pub const @"-setSupportAddingVertexBinaryFunctions:" = fn (bool) void;
        pub const @"-supportAddingFragmentBinaryFunctions" = fn () bool;
        pub const @"-setSupportAddingFragmentBinaryFunctions:" = fn (bool) void;
        pub const @"-maxVertexCallStackDepth" = fn () objc.UInteger;
        pub const @"-setMaxVertexCallStackDepth:" = fn (objc.UInteger) void;
        pub const @"-maxFragmentCallStackDepth" = fn () objc.UInteger;
        pub const @"-setMaxFragmentCallStackDepth:" = fn (objc.UInteger) void;
        pub const @"-shaderValidation" = fn () ShaderValidation;
        pub const @"-setShaderValidation:" = fn (ShaderValidation) void;
    };
};

/// `MTLRenderPipelineColorAttachmentDescriptor`, a subclass of `NSObject`.
pub const RenderPipelineColorAttachmentDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLRenderPipelineColorAttachmentDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLRenderPipelineColorAttachmentDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLRenderPipelineColorAttachmentDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor pixelFormat]`
    pub fn pixelFormat(self: Self) PixelFormat {
        return self.object.msgSend(PixelFormat, "pixelFormat", .{});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor setPixelFormat:]`
    pub fn setPixelFormat(self: Self, pixel_format: PixelFormat) void {
        return self.object.msgSend(void, "setPixelFormat:", .{pixel_format});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor isBlendingEnabled]`
    pub fn isBlendingEnabled(self: Self) bool {
        return self.object.msgSend(bool, "isBlendingEnabled", .{});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor setBlendingEnabled:]`
    pub fn setBlendingEnabled(self: Self, blending_enabled: bool) void {
        return self.object.msgSend(void, "setBlendingEnabled:", .{blending_enabled});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor sourceRGBBlendFactor]`
    pub fn sourceRGBBlendFactor(self: Self) BlendFactor {
        return self.object.msgSend(BlendFactor, "sourceRGBBlendFactor", .{});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor setSourceRGBBlendFactor:]`
    pub fn setSourceRGBBlendFactor(self: Self, source_rgb_blend_factor: BlendFactor) void {
        return self.object.msgSend(void, "setSourceRGBBlendFactor:", .{source_rgb_blend_factor});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor destinationRGBBlendFactor]`
    pub fn destinationRGBBlendFactor(self: Self) BlendFactor {
        return self.object.msgSend(BlendFactor, "destinationRGBBlendFactor", .{});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor setDestinationRGBBlendFactor:]`
    pub fn setDestinationRGBBlendFactor(self: Self, destination_rgb_blend_factor: BlendFactor) void {
        return self.object.msgSend(void, "setDestinationRGBBlendFactor:", .{destination_rgb_blend_factor});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor rgbBlendOperation]`
    pub fn rgbBlendOperation(self: Self) BlendOperation {
        return self.object.msgSend(BlendOperation, "rgbBlendOperation", .{});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor setRgbBlendOperation:]`
    pub fn setRgbBlendOperation(self: Self, rgb_blend_operation: BlendOperation) void {
        return self.object.msgSend(void, "setRgbBlendOperation:", .{rgb_blend_operation});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor sourceAlphaBlendFactor]`
    pub fn sourceAlphaBlendFactor(self: Self) BlendFactor {
        return self.object.msgSend(BlendFactor, "sourceAlphaBlendFactor", .{});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor setSourceAlphaBlendFactor:]`
    pub fn setSourceAlphaBlendFactor(self: Self, source_alpha_blend_factor: BlendFactor) void {
        return self.object.msgSend(void, "setSourceAlphaBlendFactor:", .{source_alpha_blend_factor});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor destinationAlphaBlendFactor]`
    pub fn destinationAlphaBlendFactor(self: Self) BlendFactor {
        return self.object.msgSend(BlendFactor, "destinationAlphaBlendFactor", .{});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor setDestinationAlphaBlendFactor:]`
    pub fn setDestinationAlphaBlendFactor(self: Self, destination_alpha_blend_factor: BlendFactor) void {
        return self.object.msgSend(void, "setDestinationAlphaBlendFactor:", .{destination_alpha_blend_factor});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor alphaBlendOperation]`
    pub fn alphaBlendOperation(self: Self) BlendOperation {
        return self.object.msgSend(BlendOperation, "alphaBlendOperation", .{});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor setAlphaBlendOperation:]`
    pub fn setAlphaBlendOperation(self: Self, alpha_blend_operation: BlendOperation) void {
        return self.object.msgSend(void, "setAlphaBlendOperation:", .{alpha_blend_operation});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor writeMask]`
    pub fn writeMask(self: Self) ColorWriteMask {
        return self.object.msgSend(ColorWriteMask, "writeMask", .{});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptor setWriteMask:]`
    pub fn setWriteMask(self: Self, write_mask: ColorWriteMask) void {
        return self.object.msgSend(void, "setWriteMask:", .{write_mask});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-pixelFormat" = fn () PixelFormat;
        pub const @"-setPixelFormat:" = fn (PixelFormat) void;
        pub const @"-isBlendingEnabled" = fn () bool;
        pub const @"-setBlendingEnabled:" = fn (bool) void;
        pub const @"-sourceRGBBlendFactor" = fn () BlendFactor;
        pub const @"-setSourceRGBBlendFactor:" = fn (BlendFactor) void;
        pub const @"-destinationRGBBlendFactor" = fn () BlendFactor;
        pub const @"-setDestinationRGBBlendFactor:" = fn (BlendFactor) void;
        pub const @"-rgbBlendOperation" = fn () BlendOperation;
        pub const @"-setRgbBlendOperation:" = fn (BlendOperation) void;
        pub const @"-sourceAlphaBlendFactor" = fn () BlendFactor;
        pub const @"-setSourceAlphaBlendFactor:" = fn (BlendFactor) void;
        pub const @"-destinationAlphaBlendFactor" = fn () BlendFactor;
        pub const @"-setDestinationAlphaBlendFactor:" = fn (BlendFactor) void;
        pub const @"-alphaBlendOperation" = fn () BlendOperation;
        pub const @"-setAlphaBlendOperation:" = fn (BlendOperation) void;
        pub const @"-writeMask" = fn () ColorWriteMask;
        pub const @"-setWriteMask:" = fn (ColorWriteMask) void;
    };
};

/// `MTLRenderPipelineColorAttachmentDescriptorArray`, a subclass of `NSObject`.
pub const RenderPipelineColorAttachmentDescriptorArray = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLRenderPipelineColorAttachmentDescriptorArray";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLRenderPipelineColorAttachmentDescriptorArray alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLRenderPipelineColorAttachmentDescriptorArray`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptorArray objectAtIndexedSubscript:]`
    pub fn objectAtIndexedSubscript(self: Self, attachment_index: objc.UInteger) RenderPipelineColorAttachmentDescriptor {
        return self.object.msgSend(RenderPipelineColorAttachmentDescriptor, "objectAtIndexedSubscript:", .{attachment_index});
    }

    /// `-[MTLRenderPipelineColorAttachmentDescriptorArray setObject:atIndexedSubscript:]`
    pub fn setObjectAtIndexedSubscript(self: Self, attachment: ?RenderPipelineColorAttachmentDescriptor, attachment_index: objc.UInteger) void {
        return self.object.msgSend(void, "setObject:atIndexedSubscript:", .{ attachment, attachment_index });
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-objectAtIndexedSubscript:" = fn (objc.UInteger) RenderPipelineColorAttachmentDescriptor;
        pub const @"-setObject:atIndexedSubscript:" = fn (?RenderPipelineColorAttachmentDescriptor, objc.UInteger) void;
    };
};

/// `MTLComputePipelineDescriptor`, a subclass of `NSObject`.
pub const ComputePipelineDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLComputePipelineDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLComputePipelineDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLComputePipelineDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLComputePipelineDescriptor reset]`
    pub fn reset(self: Self) void {
        return self.object.msgSend(void, "reset", .{});
    }

    /// `-[MTLComputePipelineDescriptor label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLComputePipelineDescriptor setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// `-[MTLComputePipelineDescriptor computeFunction]`
    pub fn computeFunction(self: Self) ?Function {
        return self.object.msgSend(?Function, "computeFunction", .{});
    }

    /// `-[MTLComputePipelineDescriptor setComputeFunction:]`
    pub fn setComputeFunction(self: Self, compute_function: ?Function) void {
        return self.object.msgSend(void, "setComputeFunction:", .{compute_function});
    }

    /// `-[MTLComputePipelineDescriptor threadGroupSizeIsMultipleOfThreadExecutionWidth]`
    pub fn threadGroupSizeIsMultipleOfThreadExecutionWidth(self: Self) bool {
        return self.object.msgSend(bool, "threadGroupSizeIsMultipleOfThreadExecutionWidth", .{});
    }

    /// `-[MTLComputePipelineDescriptor setThreadGroupSizeIsMultipleOfThreadExecutionWidth:]`
    pub fn setThreadGroupSizeIsMultipleOfThreadExecutionWidth(self: Self, thread_group_size_is_multiple_of_thread_execution_width: bool) void {
        return self.object.msgSend(void, "setThreadGroupSizeIsMultipleOfThreadExecutionWidth:", .{thread_group_size_is_multiple_of_thread_execution_width});
    }

    /// `-[MTLComputePipelineDescriptor maxTotalThreadsPerThreadgroup]`
    pub fn maxTotalThreadsPerThreadgroup(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxTotalThreadsPerThreadgroup", .{});
    }

    /// `-[MTLComputePipelineDescriptor setMaxTotalThreadsPerThreadgroup:]`
    pub fn setMaxTotalThreadsPerThreadgroup(self: Self, max_total_threads_per_threadgroup: objc.UInteger) void {
        return self.object.msgSend(void, "setMaxTotalThreadsPerThreadgroup:", .{max_total_threads_per_threadgroup});
    }

    /// `-[MTLComputePipelineDescriptor stageInputDescriptor]`
    pub fn stageInputDescriptor(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "stageInputDescriptor", .{});
    }

    /// `-[MTLComputePipelineDescriptor setStageInputDescriptor:]`
    pub fn setStageInputDescriptor(self: Self, stage_input_descriptor: ?objc.Object) void {
        return self.object.msgSend(void, "setStageInputDescriptor:", .{stage_input_descriptor});
    }

    /// `-[MTLComputePipelineDescriptor buffers]`
    pub fn buffers(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "buffers", .{});
    }

    /// `-[MTLComputePipelineDescriptor supportIndirectCommandBuffers]`
    pub fn supportIndirectCommandBuffers(self: Self) bool {
        return self.object.msgSend(bool, "supportIndirectCommandBuffers", .{});
    }

    /// `-[MTLComputePipelineDescriptor setSupportIndirectCommandBuffers:]`
    pub fn setSupportIndirectCommandBuffers(self: Self, support_indirect_command_buffers: bool) void {
        return self.object.msgSend(void, "setSupportIndirectCommandBuffers:", .{support_indirect_command_buffers});
    }

    /// `-[MTLComputePipelineDescriptor insertLibraries]`
    pub fn insertLibraries(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "insertLibraries", .{});
    }

    /// `-[MTLComputePipelineDescriptor setInsertLibraries:]`
    pub fn setInsertLibraries(self: Self, insert_libraries: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setInsertLibraries:", .{insert_libraries});
    }

    /// `-[MTLComputePipelineDescriptor preloadedLibraries]`
    pub fn preloadedLibraries(self: Self) foundation.Array(objc.Object) {
        return self.object.msgSend(foundation.Array(objc.Object), "preloadedLibraries", .{});
    }

    /// `-[MTLComputePipelineDescriptor setPreloadedLibraries:]`
    pub fn setPreloadedLibraries(self: Self, preloaded_libraries: foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setPreloadedLibraries:", .{preloaded_libraries});
    }

    /// `-[MTLComputePipelineDescriptor binaryArchives]`
    pub fn binaryArchives(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "binaryArchives", .{});
    }

    /// `-[MTLComputePipelineDescriptor setBinaryArchives:]`
    pub fn setBinaryArchives(self: Self, binary_archives: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setBinaryArchives:", .{binary_archives});
    }

    /// `-[MTLComputePipelineDescriptor linkedFunctions]`
    pub fn linkedFunctions(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "linkedFunctions", .{});
    }

    /// `-[MTLComputePipelineDescriptor setLinkedFunctions:]`
    pub fn setLinkedFunctions(self: Self, linked_functions: ?objc.Object) void {
        return self.object.msgSend(void, "setLinkedFunctions:", .{linked_functions});
    }

    /// `-[MTLComputePipelineDescriptor supportAddingBinaryFunctions]`
    pub fn supportAddingBinaryFunctions(self: Self) bool {
        return self.object.msgSend(bool, "supportAddingBinaryFunctions", .{});
    }

    /// `-[MTLComputePipelineDescriptor setSupportAddingBinaryFunctions:]`
    pub fn setSupportAddingBinaryFunctions(self: Self, support_adding_binary_functions: bool) void {
        return self.object.msgSend(void, "setSupportAddingBinaryFunctions:", .{support_adding_binary_functions});
    }

    /// `-[MTLComputePipelineDescriptor maxCallStackDepth]`
    pub fn maxCallStackDepth(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxCallStackDepth", .{});
    }

    /// `-[MTLComputePipelineDescriptor setMaxCallStackDepth:]`
    pub fn setMaxCallStackDepth(self: Self, max_call_stack_depth: objc.UInteger) void {
        return self.object.msgSend(void, "setMaxCallStackDepth:", .{max_call_stack_depth});
    }

    /// `-[MTLComputePipelineDescriptor shaderValidation]`
    pub fn shaderValidation(self: Self) ShaderValidation {
        return self.object.msgSend(ShaderValidation, "shaderValidation", .{});
    }

    /// `-[MTLComputePipelineDescriptor setShaderValidation:]`
    pub fn setShaderValidation(self: Self, shader_validation: ShaderValidation) void {
        return self.object.msgSend(void, "setShaderValidation:", .{shader_validation});
    }

    /// `-[MTLComputePipelineDescriptor requiredThreadsPerThreadgroup]`
    pub fn requiredThreadsPerThreadgroup(self: Self) Size {
        return self.object.msgSend(Size, "requiredThreadsPerThreadgroup", .{});
    }

    /// `-[MTLComputePipelineDescriptor setRequiredThreadsPerThreadgroup:]`
    pub fn setRequiredThreadsPerThreadgroup(self: Self, required_threads_per_threadgroup: Size) void {
        return self.object.msgSend(void, "setRequiredThreadsPerThreadgroup:", .{required_threads_per_threadgroup});
    }

    /// `-[MTLComputePipelineDescriptor forwardProgressUsage]`
    pub fn forwardProgressUsage(self: Self) ForwardProgressUsage {
        return self.object.msgSend(ForwardProgressUsage, "forwardProgressUsage", .{});
    }

    /// `-[MTLComputePipelineDescriptor setForwardProgressUsage:]`
    pub fn setForwardProgressUsage(self: Self, forward_progress_usage: ForwardProgressUsage) void {
        return self.object.msgSend(void, "setForwardProgressUsage:", .{forward_progress_usage});
    }

    /// `-[MTLComputePipelineDescriptor contentionRelief]`
    pub fn contentionRelief(self: Self) ContentionRelief {
        return self.object.msgSend(ContentionRelief, "contentionRelief", .{});
    }

    /// `-[MTLComputePipelineDescriptor setContentionRelief:]`
    pub fn setContentionRelief(self: Self, contention_relief: ContentionRelief) void {
        return self.object.msgSend(void, "setContentionRelief:", .{contention_relief});
    }

    /// `-[MTLComputePipelineDescriptor optimizeForPersistentKernel]`
    pub fn optimizeForPersistentKernel(self: Self) bool {
        return self.object.msgSend(bool, "optimizeForPersistentKernel", .{});
    }

    /// `-[MTLComputePipelineDescriptor setOptimizeForPersistentKernel:]`
    pub fn setOptimizeForPersistentKernel(self: Self, optimize_for_persistent_kernel: bool) void {
        return self.object.msgSend(void, "setOptimizeForPersistentKernel:", .{optimize_for_persistent_kernel});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-reset" = fn () void;
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-setLabel:" = fn (?foundation.String) void;
        pub const @"-computeFunction" = fn () ?Function;
        pub const @"-setComputeFunction:" = fn (?Function) void;
        pub const @"-threadGroupSizeIsMultipleOfThreadExecutionWidth" = fn () bool;
        pub const @"-setThreadGroupSizeIsMultipleOfThreadExecutionWidth:" = fn (bool) void;
        pub const @"-maxTotalThreadsPerThreadgroup" = fn () objc.UInteger;
        pub const @"-setMaxTotalThreadsPerThreadgroup:" = fn (objc.UInteger) void;
        pub const @"-stageInputDescriptor" = fn () ?objc.Object;
        pub const @"-setStageInputDescriptor:" = fn (?objc.Object) void;
        pub const @"-buffers" = fn () objc.Object;
        pub const @"-supportIndirectCommandBuffers" = fn () bool;
        pub const @"-setSupportIndirectCommandBuffers:" = fn (bool) void;
        pub const @"-insertLibraries" = fn () ?foundation.Array(objc.Object);
        pub const @"-setInsertLibraries:" = fn (?foundation.Array(objc.Object)) void;
        pub const @"-preloadedLibraries" = fn () foundation.Array(objc.Object);
        pub const @"-setPreloadedLibraries:" = fn (foundation.Array(objc.Object)) void;
        pub const @"-binaryArchives" = fn () ?foundation.Array(objc.Object);
        pub const @"-setBinaryArchives:" = fn (?foundation.Array(objc.Object)) void;
        pub const @"-linkedFunctions" = fn () ?objc.Object;
        pub const @"-setLinkedFunctions:" = fn (?objc.Object) void;
        pub const @"-supportAddingBinaryFunctions" = fn () bool;
        pub const @"-setSupportAddingBinaryFunctions:" = fn (bool) void;
        pub const @"-maxCallStackDepth" = fn () objc.UInteger;
        pub const @"-setMaxCallStackDepth:" = fn (objc.UInteger) void;
        pub const @"-shaderValidation" = fn () ShaderValidation;
        pub const @"-setShaderValidation:" = fn (ShaderValidation) void;
        pub const @"-requiredThreadsPerThreadgroup" = fn () Size;
        pub const @"-setRequiredThreadsPerThreadgroup:" = fn (Size) void;
        pub const @"-forwardProgressUsage" = fn () ForwardProgressUsage;
        pub const @"-setForwardProgressUsage:" = fn (ForwardProgressUsage) void;
        pub const @"-contentionRelief" = fn () ContentionRelief;
        pub const @"-setContentionRelief:" = fn (ContentionRelief) void;
        pub const @"-optimizeForPersistentKernel" = fn () bool;
        pub const @"-setOptimizeForPersistentKernel:" = fn (bool) void;
    };
};

/// `MTLVertexDescriptor`, a subclass of `NSObject`.
pub const VertexDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLVertexDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLVertexDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLVertexDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `+[MTLVertexDescriptor vertexDescriptor]`
    pub fn vertexDescriptor() VertexDescriptor {
        return class().msgSend(VertexDescriptor, "vertexDescriptor", .{});
    }

    /// `-[MTLVertexDescriptor reset]`
    pub fn reset(self: Self) void {
        return self.object.msgSend(void, "reset", .{});
    }

    /// `-[MTLVertexDescriptor layouts]`
    pub fn layouts(self: Self) VertexBufferLayoutDescriptorArray {
        return self.object.msgSend(VertexBufferLayoutDescriptorArray, "layouts", .{});
    }

    /// `-[MTLVertexDescriptor attributes]`
    pub fn attributes(self: Self) VertexAttributeDescriptorArray {
        return self.object.msgSend(VertexAttributeDescriptorArray, "attributes", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"+vertexDescriptor" = fn () VertexDescriptor;
        pub const @"-reset" = fn () void;
        pub const @"-layouts" = fn () VertexBufferLayoutDescriptorArray;
        pub const @"-attributes" = fn () VertexAttributeDescriptorArray;
    };
};

/// `MTLVertexAttributeDescriptor`, a subclass of `NSObject`.
pub const VertexAttributeDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLVertexAttributeDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLVertexAttributeDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLVertexAttributeDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLVertexAttributeDescriptor format]`
    pub fn format(self: Self) VertexFormat {
        return self.object.msgSend(VertexFormat, "format", .{});
    }

    /// `-[MTLVertexAttributeDescriptor setFormat:]`
    pub fn setFormat(self: Self, format_: VertexFormat) void {
        return self.object.msgSend(void, "setFormat:", .{format_});
    }

    /// `-[MTLVertexAttributeDescriptor offset]`
    pub fn offset(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "offset", .{});
    }

    /// `-[MTLVertexAttributeDescriptor setOffset:]`
    pub fn setOffset(self: Self, offset_: objc.UInteger) void {
        return self.object.msgSend(void, "setOffset:", .{offset_});
    }

    /// `-[MTLVertexAttributeDescriptor bufferIndex]`
    pub fn bufferIndex(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "bufferIndex", .{});
    }

    /// `-[MTLVertexAttributeDescriptor setBufferIndex:]`
    pub fn setBufferIndex(self: Self, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setBufferIndex:", .{buffer_index});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-format" = fn () VertexFormat;
        pub const @"-setFormat:" = fn (VertexFormat) void;
        pub const @"-offset" = fn () objc.UInteger;
        pub const @"-setOffset:" = fn (objc.UInteger) void;
        pub const @"-bufferIndex" = fn () objc.UInteger;
        pub const @"-setBufferIndex:" = fn (objc.UInteger) void;
    };
};

/// `MTLVertexAttributeDescriptorArray`, a subclass of `NSObject`.
pub const VertexAttributeDescriptorArray = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLVertexAttributeDescriptorArray";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLVertexAttributeDescriptorArray alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLVertexAttributeDescriptorArray`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLVertexAttributeDescriptorArray objectAtIndexedSubscript:]`
    pub fn objectAtIndexedSubscript(self: Self, index: objc.UInteger) VertexAttributeDescriptor {
        return self.object.msgSend(VertexAttributeDescriptor, "objectAtIndexedSubscript:", .{index});
    }

    /// `-[MTLVertexAttributeDescriptorArray setObject:atIndexedSubscript:]`
    pub fn setObjectAtIndexedSubscript(self: Self, attribute_desc: ?VertexAttributeDescriptor, index: objc.UInteger) void {
        return self.object.msgSend(void, "setObject:atIndexedSubscript:", .{ attribute_desc, index });
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-objectAtIndexedSubscript:" = fn (objc.UInteger) VertexAttributeDescriptor;
        pub const @"-setObject:atIndexedSubscript:" = fn (?VertexAttributeDescriptor, objc.UInteger) void;
    };
};

/// `MTLVertexBufferLayoutDescriptor`, a subclass of `NSObject`.
pub const VertexBufferLayoutDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLVertexBufferLayoutDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLVertexBufferLayoutDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLVertexBufferLayoutDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLVertexBufferLayoutDescriptor stride]`
    pub fn stride(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "stride", .{});
    }

    /// `-[MTLVertexBufferLayoutDescriptor setStride:]`
    pub fn setStride(self: Self, stride_: objc.UInteger) void {
        return self.object.msgSend(void, "setStride:", .{stride_});
    }

    /// `-[MTLVertexBufferLayoutDescriptor stepFunction]`
    pub fn stepFunction(self: Self) VertexStepFunction {
        return self.object.msgSend(VertexStepFunction, "stepFunction", .{});
    }

    /// `-[MTLVertexBufferLayoutDescriptor setStepFunction:]`
    pub fn setStepFunction(self: Self, step_function: VertexStepFunction) void {
        return self.object.msgSend(void, "setStepFunction:", .{step_function});
    }

    /// `-[MTLVertexBufferLayoutDescriptor stepRate]`
    pub fn stepRate(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "stepRate", .{});
    }

    /// `-[MTLVertexBufferLayoutDescriptor setStepRate:]`
    pub fn setStepRate(self: Self, step_rate: objc.UInteger) void {
        return self.object.msgSend(void, "setStepRate:", .{step_rate});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-stride" = fn () objc.UInteger;
        pub const @"-setStride:" = fn (objc.UInteger) void;
        pub const @"-stepFunction" = fn () VertexStepFunction;
        pub const @"-setStepFunction:" = fn (VertexStepFunction) void;
        pub const @"-stepRate" = fn () objc.UInteger;
        pub const @"-setStepRate:" = fn (objc.UInteger) void;
    };
};

/// `MTLVertexBufferLayoutDescriptorArray`, a subclass of `NSObject`.
pub const VertexBufferLayoutDescriptorArray = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLVertexBufferLayoutDescriptorArray";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLVertexBufferLayoutDescriptorArray alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLVertexBufferLayoutDescriptorArray`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLVertexBufferLayoutDescriptorArray objectAtIndexedSubscript:]`
    pub fn objectAtIndexedSubscript(self: Self, index: objc.UInteger) VertexBufferLayoutDescriptor {
        return self.object.msgSend(VertexBufferLayoutDescriptor, "objectAtIndexedSubscript:", .{index});
    }

    /// `-[MTLVertexBufferLayoutDescriptorArray setObject:atIndexedSubscript:]`
    pub fn setObjectAtIndexedSubscript(self: Self, buffer_desc: ?VertexBufferLayoutDescriptor, index: objc.UInteger) void {
        return self.object.msgSend(void, "setObject:atIndexedSubscript:", .{ buffer_desc, index });
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-objectAtIndexedSubscript:" = fn (objc.UInteger) VertexBufferLayoutDescriptor;
        pub const @"-setObject:atIndexedSubscript:" = fn (?VertexBufferLayoutDescriptor, objc.UInteger) void;
    };
};

/// `MTLDepthStencilDescriptor`, a subclass of `NSObject`.
pub const DepthStencilDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLDepthStencilDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLDepthStencilDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLDepthStencilDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLDepthStencilDescriptor depthCompareFunction]`
    pub fn depthCompareFunction(self: Self) CompareFunction {
        return self.object.msgSend(CompareFunction, "depthCompareFunction", .{});
    }

    /// `-[MTLDepthStencilDescriptor setDepthCompareFunction:]`
    pub fn setDepthCompareFunction(self: Self, depth_compare_function: CompareFunction) void {
        return self.object.msgSend(void, "setDepthCompareFunction:", .{depth_compare_function});
    }

    /// `-[MTLDepthStencilDescriptor isDepthWriteEnabled]`
    pub fn isDepthWriteEnabled(self: Self) bool {
        return self.object.msgSend(bool, "isDepthWriteEnabled", .{});
    }

    /// `-[MTLDepthStencilDescriptor setDepthWriteEnabled:]`
    pub fn setDepthWriteEnabled(self: Self, depth_write_enabled: bool) void {
        return self.object.msgSend(void, "setDepthWriteEnabled:", .{depth_write_enabled});
    }

    /// `-[MTLDepthStencilDescriptor frontFaceStencil]`
    pub fn frontFaceStencil(self: Self) StencilDescriptor {
        return self.object.msgSend(StencilDescriptor, "frontFaceStencil", .{});
    }

    /// `-[MTLDepthStencilDescriptor setFrontFaceStencil:]`
    pub fn setFrontFaceStencil(self: Self, front_face_stencil: ?StencilDescriptor) void {
        return self.object.msgSend(void, "setFrontFaceStencil:", .{front_face_stencil});
    }

    /// `-[MTLDepthStencilDescriptor backFaceStencil]`
    pub fn backFaceStencil(self: Self) StencilDescriptor {
        return self.object.msgSend(StencilDescriptor, "backFaceStencil", .{});
    }

    /// `-[MTLDepthStencilDescriptor setBackFaceStencil:]`
    pub fn setBackFaceStencil(self: Self, back_face_stencil: ?StencilDescriptor) void {
        return self.object.msgSend(void, "setBackFaceStencil:", .{back_face_stencil});
    }

    /// `-[MTLDepthStencilDescriptor label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLDepthStencilDescriptor setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-depthCompareFunction" = fn () CompareFunction;
        pub const @"-setDepthCompareFunction:" = fn (CompareFunction) void;
        pub const @"-isDepthWriteEnabled" = fn () bool;
        pub const @"-setDepthWriteEnabled:" = fn (bool) void;
        pub const @"-frontFaceStencil" = fn () StencilDescriptor;
        pub const @"-setFrontFaceStencil:" = fn (?StencilDescriptor) void;
        pub const @"-backFaceStencil" = fn () StencilDescriptor;
        pub const @"-setBackFaceStencil:" = fn (?StencilDescriptor) void;
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-setLabel:" = fn (?foundation.String) void;
    };
};

/// `MTLStencilDescriptor`, a subclass of `NSObject`.
pub const StencilDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLStencilDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLStencilDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLStencilDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLStencilDescriptor stencilCompareFunction]`
    pub fn stencilCompareFunction(self: Self) CompareFunction {
        return self.object.msgSend(CompareFunction, "stencilCompareFunction", .{});
    }

    /// `-[MTLStencilDescriptor setStencilCompareFunction:]`
    pub fn setStencilCompareFunction(self: Self, stencil_compare_function: CompareFunction) void {
        return self.object.msgSend(void, "setStencilCompareFunction:", .{stencil_compare_function});
    }

    /// `-[MTLStencilDescriptor stencilFailureOperation]`
    pub fn stencilFailureOperation(self: Self) StencilOperation {
        return self.object.msgSend(StencilOperation, "stencilFailureOperation", .{});
    }

    /// `-[MTLStencilDescriptor setStencilFailureOperation:]`
    pub fn setStencilFailureOperation(self: Self, stencil_failure_operation: StencilOperation) void {
        return self.object.msgSend(void, "setStencilFailureOperation:", .{stencil_failure_operation});
    }

    /// `-[MTLStencilDescriptor depthFailureOperation]`
    pub fn depthFailureOperation(self: Self) StencilOperation {
        return self.object.msgSend(StencilOperation, "depthFailureOperation", .{});
    }

    /// `-[MTLStencilDescriptor setDepthFailureOperation:]`
    pub fn setDepthFailureOperation(self: Self, depth_failure_operation: StencilOperation) void {
        return self.object.msgSend(void, "setDepthFailureOperation:", .{depth_failure_operation});
    }

    /// `-[MTLStencilDescriptor depthStencilPassOperation]`
    pub fn depthStencilPassOperation(self: Self) StencilOperation {
        return self.object.msgSend(StencilOperation, "depthStencilPassOperation", .{});
    }

    /// `-[MTLStencilDescriptor setDepthStencilPassOperation:]`
    pub fn setDepthStencilPassOperation(self: Self, depth_stencil_pass_operation: StencilOperation) void {
        return self.object.msgSend(void, "setDepthStencilPassOperation:", .{depth_stencil_pass_operation});
    }

    /// `-[MTLStencilDescriptor readMask]`
    pub fn readMask(self: Self) u32 {
        return self.object.msgSend(u32, "readMask", .{});
    }

    /// `-[MTLStencilDescriptor setReadMask:]`
    pub fn setReadMask(self: Self, read_mask: u32) void {
        return self.object.msgSend(void, "setReadMask:", .{read_mask});
    }

    /// `-[MTLStencilDescriptor writeMask]`
    pub fn writeMask(self: Self) u32 {
        return self.object.msgSend(u32, "writeMask", .{});
    }

    /// `-[MTLStencilDescriptor setWriteMask:]`
    pub fn setWriteMask(self: Self, write_mask: u32) void {
        return self.object.msgSend(void, "setWriteMask:", .{write_mask});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-stencilCompareFunction" = fn () CompareFunction;
        pub const @"-setStencilCompareFunction:" = fn (CompareFunction) void;
        pub const @"-stencilFailureOperation" = fn () StencilOperation;
        pub const @"-setStencilFailureOperation:" = fn (StencilOperation) void;
        pub const @"-depthFailureOperation" = fn () StencilOperation;
        pub const @"-setDepthFailureOperation:" = fn (StencilOperation) void;
        pub const @"-depthStencilPassOperation" = fn () StencilOperation;
        pub const @"-setDepthStencilPassOperation:" = fn (StencilOperation) void;
        pub const @"-readMask" = fn () u32;
        pub const @"-setReadMask:" = fn (u32) void;
        pub const @"-writeMask" = fn () u32;
        pub const @"-setWriteMask:" = fn (u32) void;
    };
};

/// `MTLSamplerDescriptor`, a subclass of `NSObject`.
pub const SamplerDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLSamplerDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLSamplerDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLSamplerDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLSamplerDescriptor minFilter]`
    pub fn minFilter(self: Self) SamplerMinMagFilter {
        return self.object.msgSend(SamplerMinMagFilter, "minFilter", .{});
    }

    /// `-[MTLSamplerDescriptor setMinFilter:]`
    pub fn setMinFilter(self: Self, min_filter: SamplerMinMagFilter) void {
        return self.object.msgSend(void, "setMinFilter:", .{min_filter});
    }

    /// `-[MTLSamplerDescriptor magFilter]`
    pub fn magFilter(self: Self) SamplerMinMagFilter {
        return self.object.msgSend(SamplerMinMagFilter, "magFilter", .{});
    }

    /// `-[MTLSamplerDescriptor setMagFilter:]`
    pub fn setMagFilter(self: Self, mag_filter: SamplerMinMagFilter) void {
        return self.object.msgSend(void, "setMagFilter:", .{mag_filter});
    }

    /// `-[MTLSamplerDescriptor mipFilter]`
    pub fn mipFilter(self: Self) SamplerMipFilter {
        return self.object.msgSend(SamplerMipFilter, "mipFilter", .{});
    }

    /// `-[MTLSamplerDescriptor setMipFilter:]`
    pub fn setMipFilter(self: Self, mip_filter: SamplerMipFilter) void {
        return self.object.msgSend(void, "setMipFilter:", .{mip_filter});
    }

    /// `-[MTLSamplerDescriptor maxAnisotropy]`
    pub fn maxAnisotropy(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxAnisotropy", .{});
    }

    /// `-[MTLSamplerDescriptor setMaxAnisotropy:]`
    pub fn setMaxAnisotropy(self: Self, max_anisotropy: objc.UInteger) void {
        return self.object.msgSend(void, "setMaxAnisotropy:", .{max_anisotropy});
    }

    /// `-[MTLSamplerDescriptor sAddressMode]`
    pub fn sAddressMode(self: Self) SamplerAddressMode {
        return self.object.msgSend(SamplerAddressMode, "sAddressMode", .{});
    }

    /// `-[MTLSamplerDescriptor setSAddressMode:]`
    pub fn setSAddressMode(self: Self, s_address_mode: SamplerAddressMode) void {
        return self.object.msgSend(void, "setSAddressMode:", .{s_address_mode});
    }

    /// `-[MTLSamplerDescriptor tAddressMode]`
    pub fn tAddressMode(self: Self) SamplerAddressMode {
        return self.object.msgSend(SamplerAddressMode, "tAddressMode", .{});
    }

    /// `-[MTLSamplerDescriptor setTAddressMode:]`
    pub fn setTAddressMode(self: Self, t_address_mode: SamplerAddressMode) void {
        return self.object.msgSend(void, "setTAddressMode:", .{t_address_mode});
    }

    /// `-[MTLSamplerDescriptor rAddressMode]`
    pub fn rAddressMode(self: Self) SamplerAddressMode {
        return self.object.msgSend(SamplerAddressMode, "rAddressMode", .{});
    }

    /// `-[MTLSamplerDescriptor setRAddressMode:]`
    pub fn setRAddressMode(self: Self, r_address_mode: SamplerAddressMode) void {
        return self.object.msgSend(void, "setRAddressMode:", .{r_address_mode});
    }

    /// `-[MTLSamplerDescriptor borderColor]`
    pub fn borderColor(self: Self) SamplerBorderColor {
        return self.object.msgSend(SamplerBorderColor, "borderColor", .{});
    }

    /// `-[MTLSamplerDescriptor setBorderColor:]`
    pub fn setBorderColor(self: Self, border_color: SamplerBorderColor) void {
        return self.object.msgSend(void, "setBorderColor:", .{border_color});
    }

    /// `-[MTLSamplerDescriptor reductionMode]`
    pub fn reductionMode(self: Self) SamplerReductionMode {
        return self.object.msgSend(SamplerReductionMode, "reductionMode", .{});
    }

    /// `-[MTLSamplerDescriptor setReductionMode:]`
    pub fn setReductionMode(self: Self, reduction_mode: SamplerReductionMode) void {
        return self.object.msgSend(void, "setReductionMode:", .{reduction_mode});
    }

    /// `-[MTLSamplerDescriptor normalizedCoordinates]`
    pub fn normalizedCoordinates(self: Self) bool {
        return self.object.msgSend(bool, "normalizedCoordinates", .{});
    }

    /// `-[MTLSamplerDescriptor setNormalizedCoordinates:]`
    pub fn setNormalizedCoordinates(self: Self, normalized_coordinates: bool) void {
        return self.object.msgSend(void, "setNormalizedCoordinates:", .{normalized_coordinates});
    }

    /// `-[MTLSamplerDescriptor lodMinClamp]`
    pub fn lodMinClamp(self: Self) f32 {
        return self.object.msgSend(f32, "lodMinClamp", .{});
    }

    /// `-[MTLSamplerDescriptor setLodMinClamp:]`
    pub fn setLodMinClamp(self: Self, lod_min_clamp: f32) void {
        return self.object.msgSend(void, "setLodMinClamp:", .{lod_min_clamp});
    }

    /// `-[MTLSamplerDescriptor lodMaxClamp]`
    pub fn lodMaxClamp(self: Self) f32 {
        return self.object.msgSend(f32, "lodMaxClamp", .{});
    }

    /// `-[MTLSamplerDescriptor setLodMaxClamp:]`
    pub fn setLodMaxClamp(self: Self, lod_max_clamp: f32) void {
        return self.object.msgSend(void, "setLodMaxClamp:", .{lod_max_clamp});
    }

    /// `-[MTLSamplerDescriptor lodAverage]`
    pub fn lodAverage(self: Self) bool {
        return self.object.msgSend(bool, "lodAverage", .{});
    }

    /// `-[MTLSamplerDescriptor setLodAverage:]`
    pub fn setLodAverage(self: Self, lod_average: bool) void {
        return self.object.msgSend(void, "setLodAverage:", .{lod_average});
    }

    /// `-[MTLSamplerDescriptor lodBias]`
    pub fn lodBias(self: Self) f32 {
        return self.object.msgSend(f32, "lodBias", .{});
    }

    /// `-[MTLSamplerDescriptor setLodBias:]`
    pub fn setLodBias(self: Self, lod_bias: f32) void {
        return self.object.msgSend(void, "setLodBias:", .{lod_bias});
    }

    /// `-[MTLSamplerDescriptor compareFunction]`
    pub fn compareFunction(self: Self) CompareFunction {
        return self.object.msgSend(CompareFunction, "compareFunction", .{});
    }

    /// `-[MTLSamplerDescriptor setCompareFunction:]`
    pub fn setCompareFunction(self: Self, compare_function: CompareFunction) void {
        return self.object.msgSend(void, "setCompareFunction:", .{compare_function});
    }

    /// `-[MTLSamplerDescriptor supportArgumentBuffers]`
    pub fn supportArgumentBuffers(self: Self) bool {
        return self.object.msgSend(bool, "supportArgumentBuffers", .{});
    }

    /// `-[MTLSamplerDescriptor setSupportArgumentBuffers:]`
    pub fn setSupportArgumentBuffers(self: Self, support_argument_buffers: bool) void {
        return self.object.msgSend(void, "setSupportArgumentBuffers:", .{support_argument_buffers});
    }

    /// `-[MTLSamplerDescriptor label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLSamplerDescriptor setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-minFilter" = fn () SamplerMinMagFilter;
        pub const @"-setMinFilter:" = fn (SamplerMinMagFilter) void;
        pub const @"-magFilter" = fn () SamplerMinMagFilter;
        pub const @"-setMagFilter:" = fn (SamplerMinMagFilter) void;
        pub const @"-mipFilter" = fn () SamplerMipFilter;
        pub const @"-setMipFilter:" = fn (SamplerMipFilter) void;
        pub const @"-maxAnisotropy" = fn () objc.UInteger;
        pub const @"-setMaxAnisotropy:" = fn (objc.UInteger) void;
        pub const @"-sAddressMode" = fn () SamplerAddressMode;
        pub const @"-setSAddressMode:" = fn (SamplerAddressMode) void;
        pub const @"-tAddressMode" = fn () SamplerAddressMode;
        pub const @"-setTAddressMode:" = fn (SamplerAddressMode) void;
        pub const @"-rAddressMode" = fn () SamplerAddressMode;
        pub const @"-setRAddressMode:" = fn (SamplerAddressMode) void;
        pub const @"-borderColor" = fn () SamplerBorderColor;
        pub const @"-setBorderColor:" = fn (SamplerBorderColor) void;
        pub const @"-reductionMode" = fn () SamplerReductionMode;
        pub const @"-setReductionMode:" = fn (SamplerReductionMode) void;
        pub const @"-normalizedCoordinates" = fn () bool;
        pub const @"-setNormalizedCoordinates:" = fn (bool) void;
        pub const @"-lodMinClamp" = fn () f32;
        pub const @"-setLodMinClamp:" = fn (f32) void;
        pub const @"-lodMaxClamp" = fn () f32;
        pub const @"-setLodMaxClamp:" = fn (f32) void;
        pub const @"-lodAverage" = fn () bool;
        pub const @"-setLodAverage:" = fn (bool) void;
        pub const @"-lodBias" = fn () f32;
        pub const @"-setLodBias:" = fn (f32) void;
        pub const @"-compareFunction" = fn () CompareFunction;
        pub const @"-setCompareFunction:" = fn (CompareFunction) void;
        pub const @"-supportArgumentBuffers" = fn () bool;
        pub const @"-setSupportArgumentBuffers:" = fn (bool) void;
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-setLabel:" = fn (?foundation.String) void;
    };
};

/// `MTLTextureDescriptor`, a subclass of `NSObject`.
pub const TextureDescriptor = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLTextureDescriptor";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLTextureDescriptor alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLTextureDescriptor`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `+[MTLTextureDescriptor texture2DDescriptorWithPixelFormat:width:height:mipmapped:]`
    pub fn texture2DDescriptorWithPixelFormatWidthHeightMipmapped(pixel_format: PixelFormat, width_: objc.UInteger, height_: objc.UInteger, mipmapped: bool) TextureDescriptor {
        return class().msgSend(TextureDescriptor, "texture2DDescriptorWithPixelFormat:width:height:mipmapped:", .{ pixel_format, width_, height_, mipmapped });
    }

    /// `+[MTLTextureDescriptor textureCubeDescriptorWithPixelFormat:size:mipmapped:]`
    pub fn textureCubeDescriptorWithPixelFormatSizeMipmapped(pixel_format: PixelFormat, size: objc.UInteger, mipmapped: bool) TextureDescriptor {
        return class().msgSend(TextureDescriptor, "textureCubeDescriptorWithPixelFormat:size:mipmapped:", .{ pixel_format, size, mipmapped });
    }

    /// `+[MTLTextureDescriptor textureBufferDescriptorWithPixelFormat:width:resourceOptions:usage:]`
    pub fn textureBufferDescriptorWithPixelFormatWidthResourceOptionsUsage(pixel_format: PixelFormat, width_: objc.UInteger, resource_options: ResourceOptions, usage_: TextureUsage) TextureDescriptor {
        return class().msgSend(TextureDescriptor, "textureBufferDescriptorWithPixelFormat:width:resourceOptions:usage:", .{ pixel_format, width_, resource_options, usage_ });
    }

    /// `-[MTLTextureDescriptor textureType]`
    pub fn textureType(self: Self) TextureType {
        return self.object.msgSend(TextureType, "textureType", .{});
    }

    /// `-[MTLTextureDescriptor setTextureType:]`
    pub fn setTextureType(self: Self, texture_type: TextureType) void {
        return self.object.msgSend(void, "setTextureType:", .{texture_type});
    }

    /// `-[MTLTextureDescriptor pixelFormat]`
    pub fn pixelFormat(self: Self) PixelFormat {
        return self.object.msgSend(PixelFormat, "pixelFormat", .{});
    }

    /// `-[MTLTextureDescriptor setPixelFormat:]`
    pub fn setPixelFormat(self: Self, pixel_format: PixelFormat) void {
        return self.object.msgSend(void, "setPixelFormat:", .{pixel_format});
    }

    /// `-[MTLTextureDescriptor width]`
    pub fn width(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "width", .{});
    }

    /// `-[MTLTextureDescriptor setWidth:]`
    pub fn setWidth(self: Self, width_: objc.UInteger) void {
        return self.object.msgSend(void, "setWidth:", .{width_});
    }

    /// `-[MTLTextureDescriptor height]`
    pub fn height(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "height", .{});
    }

    /// `-[MTLTextureDescriptor setHeight:]`
    pub fn setHeight(self: Self, height_: objc.UInteger) void {
        return self.object.msgSend(void, "setHeight:", .{height_});
    }

    /// `-[MTLTextureDescriptor depth]`
    pub fn depth(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "depth", .{});
    }

    /// `-[MTLTextureDescriptor setDepth:]`
    pub fn setDepth(self: Self, depth_: objc.UInteger) void {
        return self.object.msgSend(void, "setDepth:", .{depth_});
    }

    /// `-[MTLTextureDescriptor mipmapLevelCount]`
    pub fn mipmapLevelCount(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "mipmapLevelCount", .{});
    }

    /// `-[MTLTextureDescriptor setMipmapLevelCount:]`
    pub fn setMipmapLevelCount(self: Self, mipmap_level_count: objc.UInteger) void {
        return self.object.msgSend(void, "setMipmapLevelCount:", .{mipmap_level_count});
    }

    /// `-[MTLTextureDescriptor sampleCount]`
    pub fn sampleCount(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "sampleCount", .{});
    }

    /// `-[MTLTextureDescriptor setSampleCount:]`
    pub fn setSampleCount(self: Self, sample_count: objc.UInteger) void {
        return self.object.msgSend(void, "setSampleCount:", .{sample_count});
    }

    /// `-[MTLTextureDescriptor arrayLength]`
    pub fn arrayLength(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "arrayLength", .{});
    }

    /// `-[MTLTextureDescriptor setArrayLength:]`
    pub fn setArrayLength(self: Self, array_length: objc.UInteger) void {
        return self.object.msgSend(void, "setArrayLength:", .{array_length});
    }

    /// `-[MTLTextureDescriptor resourceOptions]`
    pub fn resourceOptions(self: Self) ResourceOptions {
        return self.object.msgSend(ResourceOptions, "resourceOptions", .{});
    }

    /// `-[MTLTextureDescriptor setResourceOptions:]`
    pub fn setResourceOptions(self: Self, resource_options: ResourceOptions) void {
        return self.object.msgSend(void, "setResourceOptions:", .{resource_options});
    }

    /// `-[MTLTextureDescriptor cpuCacheMode]`
    pub fn cpuCacheMode(self: Self) CPUCacheMode {
        return self.object.msgSend(CPUCacheMode, "cpuCacheMode", .{});
    }

    /// `-[MTLTextureDescriptor setCpuCacheMode:]`
    pub fn setCpuCacheMode(self: Self, cpu_cache_mode: CPUCacheMode) void {
        return self.object.msgSend(void, "setCpuCacheMode:", .{cpu_cache_mode});
    }

    /// `-[MTLTextureDescriptor storageMode]`
    pub fn storageMode(self: Self) StorageMode {
        return self.object.msgSend(StorageMode, "storageMode", .{});
    }

    /// `-[MTLTextureDescriptor setStorageMode:]`
    pub fn setStorageMode(self: Self, storage_mode: StorageMode) void {
        return self.object.msgSend(void, "setStorageMode:", .{storage_mode});
    }

    /// `-[MTLTextureDescriptor hazardTrackingMode]`
    pub fn hazardTrackingMode(self: Self) HazardTrackingMode {
        return self.object.msgSend(HazardTrackingMode, "hazardTrackingMode", .{});
    }

    /// `-[MTLTextureDescriptor setHazardTrackingMode:]`
    pub fn setHazardTrackingMode(self: Self, hazard_tracking_mode: HazardTrackingMode) void {
        return self.object.msgSend(void, "setHazardTrackingMode:", .{hazard_tracking_mode});
    }

    /// `-[MTLTextureDescriptor usage]`
    pub fn usage(self: Self) TextureUsage {
        return self.object.msgSend(TextureUsage, "usage", .{});
    }

    /// `-[MTLTextureDescriptor setUsage:]`
    pub fn setUsage(self: Self, usage_: TextureUsage) void {
        return self.object.msgSend(void, "setUsage:", .{usage_});
    }

    /// `-[MTLTextureDescriptor allowGPUOptimizedContents]`
    pub fn allowGPUOptimizedContents(self: Self) bool {
        return self.object.msgSend(bool, "allowGPUOptimizedContents", .{});
    }

    /// `-[MTLTextureDescriptor setAllowGPUOptimizedContents:]`
    pub fn setAllowGPUOptimizedContents(self: Self, allow_gpu_optimized_contents: bool) void {
        return self.object.msgSend(void, "setAllowGPUOptimizedContents:", .{allow_gpu_optimized_contents});
    }

    /// `-[MTLTextureDescriptor compressionType]`
    pub fn compressionType(self: Self) TextureCompressionType {
        return self.object.msgSend(TextureCompressionType, "compressionType", .{});
    }

    /// `-[MTLTextureDescriptor setCompressionType:]`
    pub fn setCompressionType(self: Self, compression_type: TextureCompressionType) void {
        return self.object.msgSend(void, "setCompressionType:", .{compression_type});
    }

    /// `-[MTLTextureDescriptor swizzle]`
    pub fn swizzle(self: Self) TextureSwizzleChannels {
        return self.object.msgSend(TextureSwizzleChannels, "swizzle", .{});
    }

    /// `-[MTLTextureDescriptor setSwizzle:]`
    pub fn setSwizzle(self: Self, swizzle_: TextureSwizzleChannels) void {
        return self.object.msgSend(void, "setSwizzle:", .{swizzle_});
    }

    /// `-[MTLTextureDescriptor placementSparsePageSize]`
    pub fn placementSparsePageSize(self: Self) SparsePageSize {
        return self.object.msgSend(SparsePageSize, "placementSparsePageSize", .{});
    }

    /// `-[MTLTextureDescriptor setPlacementSparsePageSize:]`
    pub fn setPlacementSparsePageSize(self: Self, placement_sparse_page_size: SparsePageSize) void {
        return self.object.msgSend(void, "setPlacementSparsePageSize:", .{placement_sparse_page_size});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"+texture2DDescriptorWithPixelFormat:width:height:mipmapped:" = fn (PixelFormat, objc.UInteger, objc.UInteger, bool) TextureDescriptor;
        pub const @"+textureCubeDescriptorWithPixelFormat:size:mipmapped:" = fn (PixelFormat, objc.UInteger, bool) TextureDescriptor;
        pub const @"+textureBufferDescriptorWithPixelFormat:width:resourceOptions:usage:" = fn (PixelFormat, objc.UInteger, ResourceOptions, TextureUsage) TextureDescriptor;
        pub const @"-textureType" = fn () TextureType;
        pub const @"-setTextureType:" = fn (TextureType) void;
        pub const @"-pixelFormat" = fn () PixelFormat;
        pub const @"-setPixelFormat:" = fn (PixelFormat) void;
        pub const @"-width" = fn () objc.UInteger;
        pub const @"-setWidth:" = fn (objc.UInteger) void;
        pub const @"-height" = fn () objc.UInteger;
        pub const @"-setHeight:" = fn (objc.UInteger) void;
        pub const @"-depth" = fn () objc.UInteger;
        pub const @"-setDepth:" = fn (objc.UInteger) void;
        pub const @"-mipmapLevelCount" = fn () objc.UInteger;
        pub const @"-setMipmapLevelCount:" = fn (objc.UInteger) void;
        pub const @"-sampleCount" = fn () objc.UInteger;
        pub const @"-setSampleCount:" = fn (objc.UInteger) void;
        pub const @"-arrayLength" = fn () objc.UInteger;
        pub const @"-setArrayLength:" = fn (objc.UInteger) void;
        pub const @"-resourceOptions" = fn () ResourceOptions;
        pub const @"-setResourceOptions:" = fn (ResourceOptions) void;
        pub const @"-cpuCacheMode" = fn () CPUCacheMode;
        pub const @"-setCpuCacheMode:" = fn (CPUCacheMode) void;
        pub const @"-storageMode" = fn () StorageMode;
        pub const @"-setStorageMode:" = fn (StorageMode) void;
        pub const @"-hazardTrackingMode" = fn () HazardTrackingMode;
        pub const @"-setHazardTrackingMode:" = fn (HazardTrackingMode) void;
        pub const @"-usage" = fn () TextureUsage;
        pub const @"-setUsage:" = fn (TextureUsage) void;
        pub const @"-allowGPUOptimizedContents" = fn () bool;
        pub const @"-setAllowGPUOptimizedContents:" = fn (bool) void;
        pub const @"-compressionType" = fn () TextureCompressionType;
        pub const @"-setCompressionType:" = fn (TextureCompressionType) void;
        pub const @"-swizzle" = fn () TextureSwizzleChannels;
        pub const @"-setSwizzle:" = fn (TextureSwizzleChannels) void;
        pub const @"-placementSparsePageSize" = fn () SparsePageSize;
        pub const @"-setPlacementSparsePageSize:" = fn (SparsePageSize) void;
    };
};

/// `MTLCompileOptions`, a subclass of `NSObject`.
pub const CompileOptions = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "MTLCompileOptions";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[MTLCompileOptions alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `MTLCompileOptions`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLCompileOptions preprocessorMacros]`
    pub fn preprocessorMacros(self: Self) ?foundation.Dictionary(foundation.String, objc.Object) {
        return self.object.msgSend(?foundation.Dictionary(foundation.String, objc.Object), "preprocessorMacros", .{});
    }

    /// `-[MTLCompileOptions setPreprocessorMacros:]`
    pub fn setPreprocessorMacros(self: Self, preprocessor_macros: ?foundation.Dictionary(foundation.String, objc.Object)) void {
        return self.object.msgSend(void, "setPreprocessorMacros:", .{preprocessor_macros});
    }

    /// `-[MTLCompileOptions fastMathEnabled]`
    pub fn fastMathEnabled(self: Self) bool {
        return self.object.msgSend(bool, "fastMathEnabled", .{});
    }

    /// `-[MTLCompileOptions setFastMathEnabled:]`
    pub fn setFastMathEnabled(self: Self, fast_math_enabled: bool) void {
        return self.object.msgSend(void, "setFastMathEnabled:", .{fast_math_enabled});
    }

    /// `-[MTLCompileOptions mathMode]`
    pub fn mathMode(self: Self) MathMode {
        return self.object.msgSend(MathMode, "mathMode", .{});
    }

    /// `-[MTLCompileOptions setMathMode:]`
    pub fn setMathMode(self: Self, math_mode: MathMode) void {
        return self.object.msgSend(void, "setMathMode:", .{math_mode});
    }

    /// `-[MTLCompileOptions mathFloatingPointFunctions]`
    pub fn mathFloatingPointFunctions(self: Self) MathFloatingPointFunctions {
        return self.object.msgSend(MathFloatingPointFunctions, "mathFloatingPointFunctions", .{});
    }

    /// `-[MTLCompileOptions setMathFloatingPointFunctions:]`
    pub fn setMathFloatingPointFunctions(self: Self, math_floating_point_functions: MathFloatingPointFunctions) void {
        return self.object.msgSend(void, "setMathFloatingPointFunctions:", .{math_floating_point_functions});
    }

    /// `-[MTLCompileOptions languageVersion]`
    pub fn languageVersion(self: Self) LanguageVersion {
        return self.object.msgSend(LanguageVersion, "languageVersion", .{});
    }

    /// `-[MTLCompileOptions setLanguageVersion:]`
    pub fn setLanguageVersion(self: Self, language_version: LanguageVersion) void {
        return self.object.msgSend(void, "setLanguageVersion:", .{language_version});
    }

    /// `-[MTLCompileOptions libraryType]`
    pub fn libraryType(self: Self) LibraryType {
        return self.object.msgSend(LibraryType, "libraryType", .{});
    }

    /// `-[MTLCompileOptions setLibraryType:]`
    pub fn setLibraryType(self: Self, library_type: LibraryType) void {
        return self.object.msgSend(void, "setLibraryType:", .{library_type});
    }

    /// `-[MTLCompileOptions installName]`
    pub fn installName(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "installName", .{});
    }

    /// `-[MTLCompileOptions setInstallName:]`
    pub fn setInstallName(self: Self, install_name: ?foundation.String) void {
        return self.object.msgSend(void, "setInstallName:", .{install_name});
    }

    /// `-[MTLCompileOptions libraries]`
    pub fn libraries(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "libraries", .{});
    }

    /// `-[MTLCompileOptions setLibraries:]`
    pub fn setLibraries(self: Self, libraries_: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setLibraries:", .{libraries_});
    }

    /// `-[MTLCompileOptions preserveInvariance]`
    pub fn preserveInvariance(self: Self) bool {
        return self.object.msgSend(bool, "preserveInvariance", .{});
    }

    /// `-[MTLCompileOptions setPreserveInvariance:]`
    pub fn setPreserveInvariance(self: Self, preserve_invariance: bool) void {
        return self.object.msgSend(void, "setPreserveInvariance:", .{preserve_invariance});
    }

    /// `-[MTLCompileOptions optimizationLevel]`
    pub fn optimizationLevel(self: Self) LibraryOptimizationLevel {
        return self.object.msgSend(LibraryOptimizationLevel, "optimizationLevel", .{});
    }

    /// `-[MTLCompileOptions setOptimizationLevel:]`
    pub fn setOptimizationLevel(self: Self, optimization_level: LibraryOptimizationLevel) void {
        return self.object.msgSend(void, "setOptimizationLevel:", .{optimization_level});
    }

    /// `-[MTLCompileOptions compileSymbolVisibility]`
    pub fn compileSymbolVisibility(self: Self) CompileSymbolVisibility {
        return self.object.msgSend(CompileSymbolVisibility, "compileSymbolVisibility", .{});
    }

    /// `-[MTLCompileOptions setCompileSymbolVisibility:]`
    pub fn setCompileSymbolVisibility(self: Self, compile_symbol_visibility: CompileSymbolVisibility) void {
        return self.object.msgSend(void, "setCompileSymbolVisibility:", .{compile_symbol_visibility});
    }

    /// `-[MTLCompileOptions allowReferencingUndefinedSymbols]`
    pub fn allowReferencingUndefinedSymbols(self: Self) bool {
        return self.object.msgSend(bool, "allowReferencingUndefinedSymbols", .{});
    }

    /// `-[MTLCompileOptions setAllowReferencingUndefinedSymbols:]`
    pub fn setAllowReferencingUndefinedSymbols(self: Self, allow_referencing_undefined_symbols: bool) void {
        return self.object.msgSend(void, "setAllowReferencingUndefinedSymbols:", .{allow_referencing_undefined_symbols});
    }

    /// `-[MTLCompileOptions maxTotalThreadsPerThreadgroup]`
    pub fn maxTotalThreadsPerThreadgroup(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxTotalThreadsPerThreadgroup", .{});
    }

    /// `-[MTLCompileOptions setMaxTotalThreadsPerThreadgroup:]`
    pub fn setMaxTotalThreadsPerThreadgroup(self: Self, max_total_threads_per_threadgroup: objc.UInteger) void {
        return self.object.msgSend(void, "setMaxTotalThreadsPerThreadgroup:", .{max_total_threads_per_threadgroup});
    }

    /// `-[MTLCompileOptions requiredThreadsPerThreadgroup]`
    pub fn requiredThreadsPerThreadgroup(self: Self) Size {
        return self.object.msgSend(Size, "requiredThreadsPerThreadgroup", .{});
    }

    /// `-[MTLCompileOptions setRequiredThreadsPerThreadgroup:]`
    pub fn setRequiredThreadsPerThreadgroup(self: Self, required_threads_per_threadgroup: Size) void {
        return self.object.msgSend(void, "setRequiredThreadsPerThreadgroup:", .{required_threads_per_threadgroup});
    }

    /// `-[MTLCompileOptions enableLogging]`
    pub fn enableLogging(self: Self) bool {
        return self.object.msgSend(bool, "enableLogging", .{});
    }

    /// `-[MTLCompileOptions setEnableLogging:]`
    pub fn setEnableLogging(self: Self, enable_logging: bool) void {
        return self.object.msgSend(void, "setEnableLogging:", .{enable_logging});
    }

    /// `-[MTLCompileOptions floatingPointConversionRoundingMode]`
    pub fn floatingPointConversionRoundingMode(self: Self) FloatingPointConversionRoundingMode {
        return self.object.msgSend(FloatingPointConversionRoundingMode, "floatingPointConversionRoundingMode", .{});
    }

    /// `-[MTLCompileOptions setFloatingPointConversionRoundingMode:]`
    pub fn setFloatingPointConversionRoundingMode(self: Self, floating_point_conversion_rounding_mode: FloatingPointConversionRoundingMode) void {
        return self.object.msgSend(void, "setFloatingPointConversionRoundingMode:", .{floating_point_conversion_rounding_mode});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-preprocessorMacros" = fn () ?foundation.Dictionary(foundation.String, objc.Object);
        pub const @"-setPreprocessorMacros:" = fn (?foundation.Dictionary(foundation.String, objc.Object)) void;
        pub const @"-fastMathEnabled" = fn () bool;
        pub const @"-setFastMathEnabled:" = fn (bool) void;
        pub const @"-mathMode" = fn () MathMode;
        pub const @"-setMathMode:" = fn (MathMode) void;
        pub const @"-mathFloatingPointFunctions" = fn () MathFloatingPointFunctions;
        pub const @"-setMathFloatingPointFunctions:" = fn (MathFloatingPointFunctions) void;
        pub const @"-languageVersion" = fn () LanguageVersion;
        pub const @"-setLanguageVersion:" = fn (LanguageVersion) void;
        pub const @"-libraryType" = fn () LibraryType;
        pub const @"-setLibraryType:" = fn (LibraryType) void;
        pub const @"-installName" = fn () ?foundation.String;
        pub const @"-setInstallName:" = fn (?foundation.String) void;
        pub const @"-libraries" = fn () ?foundation.Array(objc.Object);
        pub const @"-setLibraries:" = fn (?foundation.Array(objc.Object)) void;
        pub const @"-preserveInvariance" = fn () bool;
        pub const @"-setPreserveInvariance:" = fn (bool) void;
        pub const @"-optimizationLevel" = fn () LibraryOptimizationLevel;
        pub const @"-setOptimizationLevel:" = fn (LibraryOptimizationLevel) void;
        pub const @"-compileSymbolVisibility" = fn () CompileSymbolVisibility;
        pub const @"-setCompileSymbolVisibility:" = fn (CompileSymbolVisibility) void;
        pub const @"-allowReferencingUndefinedSymbols" = fn () bool;
        pub const @"-setAllowReferencingUndefinedSymbols:" = fn (bool) void;
        pub const @"-maxTotalThreadsPerThreadgroup" = fn () objc.UInteger;
        pub const @"-setMaxTotalThreadsPerThreadgroup:" = fn (objc.UInteger) void;
        pub const @"-requiredThreadsPerThreadgroup" = fn () Size;
        pub const @"-setRequiredThreadsPerThreadgroup:" = fn (Size) void;
        pub const @"-enableLogging" = fn () bool;
        pub const @"-setEnableLogging:" = fn (bool) void;
        pub const @"-floatingPointConversionRoundingMode" = fn () FloatingPointConversionRoundingMode;
        pub const @"-setFloatingPointConversionRoundingMode:" = fn (FloatingPointConversionRoundingMode) void;
    };
};

/// `CALayer`, a subclass of `NSObject`.
pub const Layer = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "CALayer";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[CALayer alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `CALayer`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `+[CALayer layer]`
    pub fn layer() Layer {
        return class().msgSend(Layer, "layer", .{});
    }

    /// `-[CALayer init]`
    pub fn init(self: Self) Layer {
        return self.object.msgSend(Layer, "init", .{});
    }

    /// `-[CALayer initWithLayer:]`
    pub fn initWithLayer(self: Self, layer_: objc.Object) Layer {
        return self.object.msgSend(Layer, "initWithLayer:", .{layer_});
    }

    /// `-[CALayer presentationLayer]`
    pub fn presentationLayer(self: Self) ?Layer {
        return self.object.msgSend(?Layer, "presentationLayer", .{});
    }

    /// `-[CALayer modelLayer]`
    pub fn modelLayer(self: Self) Layer {
        return self.object.msgSend(Layer, "modelLayer", .{});
    }

    /// `+[CALayer defaultValueForKey:]`
    pub fn defaultValueForKey(key: foundation.String) ?objc.Object {
        return class().msgSend(?objc.Object, "defaultValueForKey:", .{key});
    }

    /// `+[CALayer needsDisplayForKey:]`
    pub fn needsDisplayForKey(key: foundation.String) bool {
        return class().msgSend(bool, "needsDisplayForKey:", .{key});
    }

    /// `-[CALayer shouldArchiveValueForKey:]`
    pub fn shouldArchiveValueForKey(self: Self, key: foundation.String) bool {
        return self.object.msgSend(bool, "shouldArchiveValueForKey:", .{key});
    }

    /// `-[CALayer affineTransform]`
    pub fn affineTransform(self: Self) cg.AffineTransform {
        return self.object.msgSend(cg.AffineTransform, "affineTransform", .{});
    }

    /// `-[CALayer setAffineTransform:]`
    pub fn setAffineTransform(self: Self, m: cg.AffineTransform) void {
        return self.object.msgSend(void, "setAffineTransform:", .{m});
    }

    /// `-[CALayer contentsAreFlipped]`
    pub fn contentsAreFlipped(self: Self) bool {
        return self.object.msgSend(bool, "contentsAreFlipped", .{});
    }

    /// `-[CALayer removeFromSuperlayer]`
    pub fn removeFromSuperlayer(self: Self) void {
        return self.object.msgSend(void, "removeFromSuperlayer", .{});
    }

    /// `-[CALayer addSublayer:]`
    pub fn addSublayer(self: Self, layer_: Layer) void {
        return self.object.msgSend(void, "addSublayer:", .{layer_});
    }

    /// `-[CALayer insertSublayer:atIndex:]`
    pub fn insertSublayerAtIndex(self: Self, layer_: Layer, idx: c_uint) void {
        return self.object.msgSend(void, "insertSublayer:atIndex:", .{ layer_, idx });
    }

    /// `-[CALayer insertSublayer:below:]`
    pub fn insertSublayerBelow(self: Self, layer_: Layer, sibling: ?Layer) void {
        return self.object.msgSend(void, "insertSublayer:below:", .{ layer_, sibling });
    }

    /// `-[CALayer insertSublayer:above:]`
    pub fn insertSublayerAbove(self: Self, layer_: Layer, sibling: ?Layer) void {
        return self.object.msgSend(void, "insertSublayer:above:", .{ layer_, sibling });
    }

    /// `-[CALayer replaceSublayer:with:]`
    pub fn replaceSublayerWith(self: Self, old_layer: Layer, new_layer: Layer) void {
        return self.object.msgSend(void, "replaceSublayer:with:", .{ old_layer, new_layer });
    }

    /// `-[CALayer convertPoint:fromLayer:]`
    pub fn convertPointFromLayer(self: Self, p: cg.Point, l: ?Layer) cg.Point {
        return self.object.msgSend(cg.Point, "convertPoint:fromLayer:", .{ p, l });
    }

    /// `-[CALayer convertPoint:toLayer:]`
    pub fn convertPointToLayer(self: Self, p: cg.Point, l: ?Layer) cg.Point {
        return self.object.msgSend(cg.Point, "convertPoint:toLayer:", .{ p, l });
    }

    /// `-[CALayer convertRect:fromLayer:]`
    pub fn convertRectFromLayer(self: Self, r: cg.Rect, l: ?Layer) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRect:fromLayer:", .{ r, l });
    }

    /// `-[CALayer convertRect:toLayer:]`
    pub fn convertRectToLayer(self: Self, r: cg.Rect, l: ?Layer) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRect:toLayer:", .{ r, l });
    }

    /// `-[CALayer convertTime:fromLayer:]`
    pub fn convertTimeFromLayer(self: Self, t: f64, l: ?Layer) f64 {
        return self.object.msgSend(f64, "convertTime:fromLayer:", .{ t, l });
    }

    /// `-[CALayer convertTime:toLayer:]`
    pub fn convertTimeToLayer(self: Self, t: f64, l: ?Layer) f64 {
        return self.object.msgSend(f64, "convertTime:toLayer:", .{ t, l });
    }

    /// `-[CALayer hitTest:]`
    pub fn hitTest(self: Self, p: cg.Point) ?Layer {
        return self.object.msgSend(?Layer, "hitTest:", .{p});
    }

    /// `-[CALayer containsPoint:]`
    pub fn containsPoint(self: Self, p: cg.Point) bool {
        return self.object.msgSend(bool, "containsPoint:", .{p});
    }

    /// `-[CALayer display]`
    pub fn display(self: Self) void {
        return self.object.msgSend(void, "display", .{});
    }

    /// `-[CALayer setNeedsDisplay]`
    pub fn setNeedsDisplay(self: Self) void {
        return self.object.msgSend(void, "setNeedsDisplay", .{});
    }

    /// `-[CALayer setNeedsDisplayInRect:]`
    pub fn setNeedsDisplayInRect(self: Self, r: cg.Rect) void {
        return self.object.msgSend(void, "setNeedsDisplayInRect:", .{r});
    }

    /// `-[CALayer needsDisplay]`
    pub fn needsDisplay(self: Self) bool {
        return self.object.msgSend(bool, "needsDisplay", .{});
    }

    /// `-[CALayer displayIfNeeded]`
    pub fn displayIfNeeded(self: Self) void {
        return self.object.msgSend(void, "displayIfNeeded", .{});
    }

    /// `-[CALayer drawInContext:]`
    pub fn drawInContext(self: Self, ctx: cg.Context) void {
        return self.object.msgSend(void, "drawInContext:", .{ctx});
    }

    /// `-[CALayer renderInContext:]`
    pub fn renderInContext(self: Self, ctx: cg.Context) void {
        return self.object.msgSend(void, "renderInContext:", .{ctx});
    }

    /// `+[CALayer cornerCurveExpansionFactor:]`
    pub fn cornerCurveExpansionFactor(curve: foundation.String) cg.Float {
        return class().msgSend(cg.Float, "cornerCurveExpansionFactor:", .{curve});
    }

    /// `-[CALayer preferredFrameSize]`
    pub fn preferredFrameSize(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "preferredFrameSize", .{});
    }

    /// `-[CALayer setNeedsLayout]`
    pub fn setNeedsLayout(self: Self) void {
        return self.object.msgSend(void, "setNeedsLayout", .{});
    }

    /// `-[CALayer needsLayout]`
    pub fn needsLayout(self: Self) bool {
        return self.object.msgSend(bool, "needsLayout", .{});
    }

    /// `-[CALayer layoutIfNeeded]`
    pub fn layoutIfNeeded(self: Self) void {
        return self.object.msgSend(void, "layoutIfNeeded", .{});
    }

    /// `-[CALayer layoutSublayers]`
    pub fn layoutSublayers(self: Self) void {
        return self.object.msgSend(void, "layoutSublayers", .{});
    }

    /// `-[CALayer resizeSublayersWithOldSize:]`
    pub fn resizeSublayersWithOldSize(self: Self, size: cg.Size) void {
        return self.object.msgSend(void, "resizeSublayersWithOldSize:", .{size});
    }

    /// `-[CALayer resizeWithOldSuperlayerSize:]`
    pub fn resizeWithOldSuperlayerSize(self: Self, size: cg.Size) void {
        return self.object.msgSend(void, "resizeWithOldSuperlayerSize:", .{size});
    }

    /// `+[CALayer defaultActionForKey:]`
    pub fn defaultActionForKey(event: foundation.String) ?objc.Object {
        return class().msgSend(?objc.Object, "defaultActionForKey:", .{event});
    }

    /// `-[CALayer actionForKey:]`
    pub fn actionForKey(self: Self, event: foundation.String) ?objc.Object {
        return self.object.msgSend(?objc.Object, "actionForKey:", .{event});
    }

    /// `-[CALayer addAnimation:forKey:]`
    pub fn addAnimationForKey(self: Self, anim: objc.Object, key: ?foundation.String) void {
        return self.object.msgSend(void, "addAnimation:forKey:", .{ anim, key });
    }

    /// `-[CALayer removeAllAnimations]`
    pub fn removeAllAnimations(self: Self) void {
        return self.object.msgSend(void, "removeAllAnimations", .{});
    }

    /// `-[CALayer removeAnimationForKey:]`
    pub fn removeAnimationForKey(self: Self, key: foundation.String) void {
        return self.object.msgSend(void, "removeAnimationForKey:", .{key});
    }

    /// `-[CALayer animationKeys]`
    pub fn animationKeys(self: Self) ?foundation.Array(foundation.String) {
        return self.object.msgSend(?foundation.Array(foundation.String), "animationKeys", .{});
    }

    /// `-[CALayer animationForKey:]`
    pub fn animationForKey(self: Self, key: foundation.String) ?objc.Object {
        return self.object.msgSend(?objc.Object, "animationForKey:", .{key});
    }

    /// `-[CALayer bounds]`
    pub fn bounds(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "bounds", .{});
    }

    /// `-[CALayer setBounds:]`
    pub fn setBounds(self: Self, bounds_: cg.Rect) void {
        return self.object.msgSend(void, "setBounds:", .{bounds_});
    }

    /// `-[CALayer position]`
    pub fn position(self: Self) cg.Point {
        return self.object.msgSend(cg.Point, "position", .{});
    }

    /// `-[CALayer setPosition:]`
    pub fn setPosition(self: Self, position_: cg.Point) void {
        return self.object.msgSend(void, "setPosition:", .{position_});
    }

    /// `-[CALayer zPosition]`
    pub fn zPosition(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "zPosition", .{});
    }

    /// `-[CALayer setZPosition:]`
    pub fn setZPosition(self: Self, z_position: cg.Float) void {
        return self.object.msgSend(void, "setZPosition:", .{z_position});
    }

    /// `-[CALayer anchorPoint]`
    pub fn anchorPoint(self: Self) cg.Point {
        return self.object.msgSend(cg.Point, "anchorPoint", .{});
    }

    /// `-[CALayer setAnchorPoint:]`
    pub fn setAnchorPoint(self: Self, anchor_point: cg.Point) void {
        return self.object.msgSend(void, "setAnchorPoint:", .{anchor_point});
    }

    /// `-[CALayer anchorPointZ]`
    pub fn anchorPointZ(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "anchorPointZ", .{});
    }

    /// `-[CALayer setAnchorPointZ:]`
    pub fn setAnchorPointZ(self: Self, anchor_point_z: cg.Float) void {
        return self.object.msgSend(void, "setAnchorPointZ:", .{anchor_point_z});
    }

    /// `-[CALayer transform]`
    pub fn transform(self: Self) Transform3D {
        return self.object.msgSend(Transform3D, "transform", .{});
    }

    /// `-[CALayer setTransform:]`
    pub fn setTransform(self: Self, transform_: Transform3D) void {
        return self.object.msgSend(void, "setTransform:", .{transform_});
    }

    /// `-[CALayer frame]`
    pub fn frame(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "frame", .{});
    }

    /// `-[CALayer setFrame:]`
    pub fn setFrame(self: Self, frame_: cg.Rect) void {
        return self.object.msgSend(void, "setFrame:", .{frame_});
    }

    /// `-[CALayer isHidden]`
    pub fn isHidden(self: Self) bool {
        return self.object.msgSend(bool, "isHidden", .{});
    }

    /// `-[CALayer setHidden:]`
    pub fn setHidden(self: Self, hidden: bool) void {
        return self.object.msgSend(void, "setHidden:", .{hidden});
    }

    /// `-[CALayer isDoubleSided]`
    pub fn isDoubleSided(self: Self) bool {
        return self.object.msgSend(bool, "isDoubleSided", .{});
    }

    /// `-[CALayer setDoubleSided:]`
    pub fn setDoubleSided(self: Self, double_sided: bool) void {
        return self.object.msgSend(void, "setDoubleSided:", .{double_sided});
    }

    /// `-[CALayer isGeometryFlipped]`
    pub fn isGeometryFlipped(self: Self) bool {
        return self.object.msgSend(bool, "isGeometryFlipped", .{});
    }

    /// `-[CALayer setGeometryFlipped:]`
    pub fn setGeometryFlipped(self: Self, geometry_flipped: bool) void {
        return self.object.msgSend(void, "setGeometryFlipped:", .{geometry_flipped});
    }

    /// `-[CALayer superlayer]`
    pub fn superlayer(self: Self) ?Layer {
        return self.object.msgSend(?Layer, "superlayer", .{});
    }

    /// `-[CALayer sublayers]`
    pub fn sublayers(self: Self) ?foundation.Array(Layer) {
        return self.object.msgSend(?foundation.Array(Layer), "sublayers", .{});
    }

    /// `-[CALayer setSublayers:]`
    pub fn setSublayers(self: Self, sublayers_: ?foundation.Array(Layer)) void {
        return self.object.msgSend(void, "setSublayers:", .{sublayers_});
    }

    /// `-[CALayer sublayerTransform]`
    pub fn sublayerTransform(self: Self) Transform3D {
        return self.object.msgSend(Transform3D, "sublayerTransform", .{});
    }

    /// `-[CALayer setSublayerTransform:]`
    pub fn setSublayerTransform(self: Self, sublayer_transform: Transform3D) void {
        return self.object.msgSend(void, "setSublayerTransform:", .{sublayer_transform});
    }

    /// `-[CALayer mask]`
    pub fn mask(self: Self) ?Layer {
        return self.object.msgSend(?Layer, "mask", .{});
    }

    /// `-[CALayer setMask:]`
    pub fn setMask(self: Self, mask_: ?Layer) void {
        return self.object.msgSend(void, "setMask:", .{mask_});
    }

    /// `-[CALayer masksToBounds]`
    pub fn masksToBounds(self: Self) bool {
        return self.object.msgSend(bool, "masksToBounds", .{});
    }

    /// `-[CALayer setMasksToBounds:]`
    pub fn setMasksToBounds(self: Self, masks_to_bounds: bool) void {
        return self.object.msgSend(void, "setMasksToBounds:", .{masks_to_bounds});
    }

    /// `-[CALayer contents]`
    pub fn contents(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "contents", .{});
    }

    /// `-[CALayer setContents:]`
    pub fn setContents(self: Self, contents_: ?objc.Object) void {
        return self.object.msgSend(void, "setContents:", .{contents_});
    }

    /// `-[CALayer contentsRect]`
    pub fn contentsRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "contentsRect", .{});
    }

    /// `-[CALayer setContentsRect:]`
    pub fn setContentsRect(self: Self, contents_rect: cg.Rect) void {
        return self.object.msgSend(void, "setContentsRect:", .{contents_rect});
    }

    /// `-[CALayer contentsGravity]`
    pub fn contentsGravity(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "contentsGravity", .{});
    }

    /// `-[CALayer setContentsGravity:]`
    pub fn setContentsGravity(self: Self, contents_gravity: foundation.String) void {
        return self.object.msgSend(void, "setContentsGravity:", .{contents_gravity});
    }

    /// `-[CALayer contentsScale]`
    pub fn contentsScale(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "contentsScale", .{});
    }

    /// `-[CALayer setContentsScale:]`
    pub fn setContentsScale(self: Self, contents_scale: cg.Float) void {
        return self.object.msgSend(void, "setContentsScale:", .{contents_scale});
    }

    /// `-[CALayer contentsCenter]`
    pub fn contentsCenter(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "contentsCenter", .{});
    }

    /// `-[CALayer setContentsCenter:]`
    pub fn setContentsCenter(self: Self, contents_center: cg.Rect) void {
        return self.object.msgSend(void, "setContentsCenter:", .{contents_center});
    }

    /// `-[CALayer contentsFormat]`
    pub fn contentsFormat(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "contentsFormat", .{});
    }

    /// `-[CALayer setContentsFormat:]`
    pub fn setContentsFormat(self: Self, contents_format: foundation.String) void {
        return self.object.msgSend(void, "setContentsFormat:", .{contents_format});
    }

    /// `-[CALayer wantsExtendedDynamicRangeContent]`
    pub fn wantsExtendedDynamicRangeContent(self: Self) bool {
        return self.object.msgSend(bool, "wantsExtendedDynamicRangeContent", .{});
    }

    /// `-[CALayer setWantsExtendedDynamicRangeContent:]`
    pub fn setWantsExtendedDynamicRangeContent(self: Self, wants_extended_dynamic_range_content: bool) void {
        return self.object.msgSend(void, "setWantsExtendedDynamicRangeContent:", .{wants_extended_dynamic_range_content});
    }

    /// `-[CALayer toneMapMode]`
    pub fn toneMapMode(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "toneMapMode", .{});
    }

    /// `-[CALayer setToneMapMode:]`
    pub fn setToneMapMode(self: Self, tone_map_mode: foundation.String) void {
        return self.object.msgSend(void, "setToneMapMode:", .{tone_map_mode});
    }

    /// `-[CALayer preferredDynamicRange]`
    pub fn preferredDynamicRange(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "preferredDynamicRange", .{});
    }

    /// `-[CALayer setPreferredDynamicRange:]`
    pub fn setPreferredDynamicRange(self: Self, preferred_dynamic_range: foundation.String) void {
        return self.object.msgSend(void, "setPreferredDynamicRange:", .{preferred_dynamic_range});
    }

    /// `-[CALayer contentsHeadroom]`
    pub fn contentsHeadroom(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "contentsHeadroom", .{});
    }

    /// `-[CALayer setContentsHeadroom:]`
    pub fn setContentsHeadroom(self: Self, contents_headroom: cg.Float) void {
        return self.object.msgSend(void, "setContentsHeadroom:", .{contents_headroom});
    }

    /// `-[CALayer wantsDynamicContentScaling]`
    pub fn wantsDynamicContentScaling(self: Self) bool {
        return self.object.msgSend(bool, "wantsDynamicContentScaling", .{});
    }

    /// `-[CALayer setWantsDynamicContentScaling:]`
    pub fn setWantsDynamicContentScaling(self: Self, wants_dynamic_content_scaling: bool) void {
        return self.object.msgSend(void, "setWantsDynamicContentScaling:", .{wants_dynamic_content_scaling});
    }

    /// `-[CALayer minificationFilter]`
    pub fn minificationFilter(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "minificationFilter", .{});
    }

    /// `-[CALayer setMinificationFilter:]`
    pub fn setMinificationFilter(self: Self, minification_filter: foundation.String) void {
        return self.object.msgSend(void, "setMinificationFilter:", .{minification_filter});
    }

    /// `-[CALayer magnificationFilter]`
    pub fn magnificationFilter(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "magnificationFilter", .{});
    }

    /// `-[CALayer setMagnificationFilter:]`
    pub fn setMagnificationFilter(self: Self, magnification_filter: foundation.String) void {
        return self.object.msgSend(void, "setMagnificationFilter:", .{magnification_filter});
    }

    /// `-[CALayer minificationFilterBias]`
    pub fn minificationFilterBias(self: Self) f32 {
        return self.object.msgSend(f32, "minificationFilterBias", .{});
    }

    /// `-[CALayer setMinificationFilterBias:]`
    pub fn setMinificationFilterBias(self: Self, minification_filter_bias: f32) void {
        return self.object.msgSend(void, "setMinificationFilterBias:", .{minification_filter_bias});
    }

    /// `-[CALayer isOpaque]`
    pub fn isOpaque(self: Self) bool {
        return self.object.msgSend(bool, "isOpaque", .{});
    }

    /// `-[CALayer setOpaque:]`
    pub fn setOpaque(self: Self, @"opaque": bool) void {
        return self.object.msgSend(void, "setOpaque:", .{@"opaque"});
    }

    /// `-[CALayer needsDisplayOnBoundsChange]`
    pub fn needsDisplayOnBoundsChange(self: Self) bool {
        return self.object.msgSend(bool, "needsDisplayOnBoundsChange", .{});
    }

    /// `-[CALayer setNeedsDisplayOnBoundsChange:]`
    pub fn setNeedsDisplayOnBoundsChange(self: Self, needs_display_on_bounds_change: bool) void {
        return self.object.msgSend(void, "setNeedsDisplayOnBoundsChange:", .{needs_display_on_bounds_change});
    }

    /// `-[CALayer drawsAsynchronously]`
    pub fn drawsAsynchronously(self: Self) bool {
        return self.object.msgSend(bool, "drawsAsynchronously", .{});
    }

    /// `-[CALayer setDrawsAsynchronously:]`
    pub fn setDrawsAsynchronously(self: Self, draws_asynchronously: bool) void {
        return self.object.msgSend(void, "setDrawsAsynchronously:", .{draws_asynchronously});
    }

    /// `-[CALayer edgeAntialiasingMask]`
    pub fn edgeAntialiasingMask(self: Self) EdgeAntialiasingMask {
        return self.object.msgSend(EdgeAntialiasingMask, "edgeAntialiasingMask", .{});
    }

    /// `-[CALayer setEdgeAntialiasingMask:]`
    pub fn setEdgeAntialiasingMask(self: Self, edge_antialiasing_mask: EdgeAntialiasingMask) void {
        return self.object.msgSend(void, "setEdgeAntialiasingMask:", .{edge_antialiasing_mask});
    }

    /// `-[CALayer allowsEdgeAntialiasing]`
    pub fn allowsEdgeAntialiasing(self: Self) bool {
        return self.object.msgSend(bool, "allowsEdgeAntialiasing", .{});
    }

    /// `-[CALayer setAllowsEdgeAntialiasing:]`
    pub fn setAllowsEdgeAntialiasing(self: Self, allows_edge_antialiasing: bool) void {
        return self.object.msgSend(void, "setAllowsEdgeAntialiasing:", .{allows_edge_antialiasing});
    }

    /// `-[CALayer backgroundColor]`
    pub fn backgroundColor(self: Self) ?cg.Color {
        return self.object.msgSend(?cg.Color, "backgroundColor", .{});
    }

    /// `-[CALayer setBackgroundColor:]`
    pub fn setBackgroundColor(self: Self, background_color: ?cg.Color) void {
        return self.object.msgSend(void, "setBackgroundColor:", .{background_color});
    }

    /// `-[CALayer cornerRadius]`
    pub fn cornerRadius(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "cornerRadius", .{});
    }

    /// `-[CALayer setCornerRadius:]`
    pub fn setCornerRadius(self: Self, corner_radius: cg.Float) void {
        return self.object.msgSend(void, "setCornerRadius:", .{corner_radius});
    }

    /// `-[CALayer maskedCorners]`
    pub fn maskedCorners(self: Self) CornerMask {
        return self.object.msgSend(CornerMask, "maskedCorners", .{});
    }

    /// `-[CALayer setMaskedCorners:]`
    pub fn setMaskedCorners(self: Self, masked_corners: CornerMask) void {
        return self.object.msgSend(void, "setMaskedCorners:", .{masked_corners});
    }

    /// `-[CALayer cornerCurve]`
    pub fn cornerCurve(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "cornerCurve", .{});
    }

    /// `-[CALayer setCornerCurve:]`
    pub fn setCornerCurve(self: Self, corner_curve: foundation.String) void {
        return self.object.msgSend(void, "setCornerCurve:", .{corner_curve});
    }

    /// `-[CALayer borderWidth]`
    pub fn borderWidth(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "borderWidth", .{});
    }

    /// `-[CALayer setBorderWidth:]`
    pub fn setBorderWidth(self: Self, border_width: cg.Float) void {
        return self.object.msgSend(void, "setBorderWidth:", .{border_width});
    }

    /// `-[CALayer borderColor]`
    pub fn borderColor(self: Self) ?cg.Color {
        return self.object.msgSend(?cg.Color, "borderColor", .{});
    }

    /// `-[CALayer setBorderColor:]`
    pub fn setBorderColor(self: Self, border_color: ?cg.Color) void {
        return self.object.msgSend(void, "setBorderColor:", .{border_color});
    }

    /// `-[CALayer opacity]`
    pub fn opacity(self: Self) f32 {
        return self.object.msgSend(f32, "opacity", .{});
    }

    /// `-[CALayer setOpacity:]`
    pub fn setOpacity(self: Self, opacity_: f32) void {
        return self.object.msgSend(void, "setOpacity:", .{opacity_});
    }

    /// `-[CALayer allowsGroupOpacity]`
    pub fn allowsGroupOpacity(self: Self) bool {
        return self.object.msgSend(bool, "allowsGroupOpacity", .{});
    }

    /// `-[CALayer setAllowsGroupOpacity:]`
    pub fn setAllowsGroupOpacity(self: Self, allows_group_opacity: bool) void {
        return self.object.msgSend(void, "setAllowsGroupOpacity:", .{allows_group_opacity});
    }

    /// `-[CALayer compositingFilter]`
    pub fn compositingFilter(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "compositingFilter", .{});
    }

    /// `-[CALayer setCompositingFilter:]`
    pub fn setCompositingFilter(self: Self, compositing_filter: ?objc.Object) void {
        return self.object.msgSend(void, "setCompositingFilter:", .{compositing_filter});
    }

    /// `-[CALayer filters]`
    pub fn filters(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "filters", .{});
    }

    /// `-[CALayer setFilters:]`
    pub fn setFilters(self: Self, filters_: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setFilters:", .{filters_});
    }

    /// `-[CALayer backgroundFilters]`
    pub fn backgroundFilters(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "backgroundFilters", .{});
    }

    /// `-[CALayer setBackgroundFilters:]`
    pub fn setBackgroundFilters(self: Self, background_filters: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setBackgroundFilters:", .{background_filters});
    }

    /// `-[CALayer shouldRasterize]`
    pub fn shouldRasterize(self: Self) bool {
        return self.object.msgSend(bool, "shouldRasterize", .{});
    }

    /// `-[CALayer setShouldRasterize:]`
    pub fn setShouldRasterize(self: Self, should_rasterize: bool) void {
        return self.object.msgSend(void, "setShouldRasterize:", .{should_rasterize});
    }

    /// `-[CALayer rasterizationScale]`
    pub fn rasterizationScale(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "rasterizationScale", .{});
    }

    /// `-[CALayer setRasterizationScale:]`
    pub fn setRasterizationScale(self: Self, rasterization_scale: cg.Float) void {
        return self.object.msgSend(void, "setRasterizationScale:", .{rasterization_scale});
    }

    /// `-[CALayer shadowColor]`
    pub fn shadowColor(self: Self) ?cg.Color {
        return self.object.msgSend(?cg.Color, "shadowColor", .{});
    }

    /// `-[CALayer setShadowColor:]`
    pub fn setShadowColor(self: Self, shadow_color: ?cg.Color) void {
        return self.object.msgSend(void, "setShadowColor:", .{shadow_color});
    }

    /// `-[CALayer shadowOpacity]`
    pub fn shadowOpacity(self: Self) f32 {
        return self.object.msgSend(f32, "shadowOpacity", .{});
    }

    /// `-[CALayer setShadowOpacity:]`
    pub fn setShadowOpacity(self: Self, shadow_opacity: f32) void {
        return self.object.msgSend(void, "setShadowOpacity:", .{shadow_opacity});
    }

    /// `-[CALayer shadowOffset]`
    pub fn shadowOffset(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "shadowOffset", .{});
    }

    /// `-[CALayer setShadowOffset:]`
    pub fn setShadowOffset(self: Self, shadow_offset: cg.Size) void {
        return self.object.msgSend(void, "setShadowOffset:", .{shadow_offset});
    }

    /// `-[CALayer shadowRadius]`
    pub fn shadowRadius(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "shadowRadius", .{});
    }

    /// `-[CALayer setShadowRadius:]`
    pub fn setShadowRadius(self: Self, shadow_radius: cg.Float) void {
        return self.object.msgSend(void, "setShadowRadius:", .{shadow_radius});
    }

    /// `-[CALayer shadowPath]`
    pub fn shadowPath(self: Self) ?cg.Path {
        return self.object.msgSend(?cg.Path, "shadowPath", .{});
    }

    /// `-[CALayer setShadowPath:]`
    pub fn setShadowPath(self: Self, shadow_path: ?cg.Path) void {
        return self.object.msgSend(void, "setShadowPath:", .{shadow_path});
    }

    /// `-[CALayer autoresizingMask]`
    pub fn autoresizingMask(self: Self) AutoresizingMask {
        return self.object.msgSend(AutoresizingMask, "autoresizingMask", .{});
    }

    /// `-[CALayer setAutoresizingMask:]`
    pub fn setAutoresizingMask(self: Self, autoresizing_mask: AutoresizingMask) void {
        return self.object.msgSend(void, "setAutoresizingMask:", .{autoresizing_mask});
    }

    /// `-[CALayer layoutManager]`
    pub fn layoutManager(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "layoutManager", .{});
    }

    /// `-[CALayer setLayoutManager:]`
    pub fn setLayoutManager(self: Self, layout_manager: ?objc.Object) void {
        return self.object.msgSend(void, "setLayoutManager:", .{layout_manager});
    }

    /// `-[CALayer actions]`
    pub fn actions(self: Self) ?foundation.Dictionary(foundation.String, objc.Object) {
        return self.object.msgSend(?foundation.Dictionary(foundation.String, objc.Object), "actions", .{});
    }

    /// `-[CALayer setActions:]`
    pub fn setActions(self: Self, actions_: ?foundation.Dictionary(foundation.String, objc.Object)) void {
        return self.object.msgSend(void, "setActions:", .{actions_});
    }

    /// `-[CALayer name]`
    pub fn name(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "name", .{});
    }

    /// `-[CALayer setName:]`
    pub fn setName(self: Self, name_: ?foundation.String) void {
        return self.object.msgSend(void, "setName:", .{name_});
    }

    /// `-[CALayer delegate]`
    pub fn delegate(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "delegate", .{});
    }

    /// `-[CALayer setDelegate:]`
    pub fn setDelegate(self: Self, delegate_: ?objc.Object) void {
        return self.object.msgSend(void, "setDelegate:", .{delegate_});
    }

    /// `-[CALayer style]`
    pub fn style(self: Self) ?foundation.Dictionary(objc.Object, objc.Object) {
        return self.object.msgSend(?foundation.Dictionary(objc.Object, objc.Object), "style", .{});
    }

    /// `-[CALayer setStyle:]`
    pub fn setStyle(self: Self, style_: ?foundation.Dictionary(objc.Object, objc.Object)) void {
        return self.object.msgSend(void, "setStyle:", .{style_});
    }

    /// `-[CALayer addConstraint:]`
    pub fn addConstraint(self: Self, c: objc.Object) void {
        return self.object.msgSend(void, "addConstraint:", .{c});
    }

    /// `-[CALayer constraints]`
    pub fn constraints(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "constraints", .{});
    }

    /// `-[CALayer setConstraints:]`
    pub fn setConstraints(self: Self, constraints_: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setConstraints:", .{constraints_});
    }

    /// `+[CALayer layerWithRemoteClientId:]`
    pub fn layerWithRemoteClientId(client_id: u32) Layer {
        return class().msgSend(Layer, "layerWithRemoteClientId:", .{client_id});
    }

    /// `-[CALayer scrollPoint:]`
    pub fn scrollPoint(self: Self, p: cg.Point) void {
        return self.object.msgSend(void, "scrollPoint:", .{p});
    }

    /// `-[CALayer scrollRectToVisible:]`
    pub fn scrollRectToVisible(self: Self, r: cg.Rect) void {
        return self.object.msgSend(void, "scrollRectToVisible:", .{r});
    }

    /// `-[CALayer visibleRect]`
    pub fn visibleRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "visibleRect", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"+layer" = fn () Layer;
        pub const @"-init" = fn () Layer;
        pub const @"-initWithLayer:" = fn (objc.Object) Layer;
        pub const @"-presentationLayer" = fn () ?Layer;
        pub const @"-modelLayer" = fn () Layer;
        pub const @"+defaultValueForKey:" = fn (foundation.String) ?objc.Object;
        pub const @"+needsDisplayForKey:" = fn (foundation.String) bool;
        pub const @"-shouldArchiveValueForKey:" = fn (foundation.String) bool;
        pub const @"-affineTransform" = fn () cg.AffineTransform;
        pub const @"-setAffineTransform:" = fn (cg.AffineTransform) void;
        pub const @"-contentsAreFlipped" = fn () bool;
        pub const @"-removeFromSuperlayer" = fn () void;
        pub const @"-addSublayer:" = fn (Layer) void;
        pub const @"-insertSublayer:atIndex:" = fn (Layer, c_uint) void;
        pub const @"-insertSublayer:below:" = fn (Layer, ?Layer) void;
        pub const @"-insertSublayer:above:" = fn (Layer, ?Layer) void;
        pub const @"-replaceSublayer:with:" = fn (Layer, Layer) void;
        pub const @"-convertPoint:fromLayer:" = fn (cg.Point, ?Layer) cg.Point;
        pub const @"-convertPoint:toLayer:" = fn (cg.Point, ?Layer) cg.Point;
        pub const @"-convertRect:fromLayer:" = fn (cg.Rect, ?Layer) cg.Rect;
        pub const @"-convertRect:toLayer:" = fn (cg.Rect, ?Layer) cg.Rect;
        pub const @"-convertTime:fromLayer:" = fn (f64, ?Layer) f64;
        pub const @"-convertTime:toLayer:" = fn (f64, ?Layer) f64;
        pub const @"-hitTest:" = fn (cg.Point) ?Layer;
        pub const @"-containsPoint:" = fn (cg.Point) bool;
        pub const @"-display" = fn () void;
        pub const @"-setNeedsDisplay" = fn () void;
        pub const @"-setNeedsDisplayInRect:" = fn (cg.Rect) void;
        pub const @"-needsDisplay" = fn () bool;
        pub const @"-displayIfNeeded" = fn () void;
        pub const @"-drawInContext:" = fn (cg.Context) void;
        pub const @"-renderInContext:" = fn (cg.Context) void;
        pub const @"+cornerCurveExpansionFactor:" = fn (foundation.String) cg.Float;
        pub const @"-preferredFrameSize" = fn () cg.Size;
        pub const @"-setNeedsLayout" = fn () void;
        pub const @"-needsLayout" = fn () bool;
        pub const @"-layoutIfNeeded" = fn () void;
        pub const @"-layoutSublayers" = fn () void;
        pub const @"-resizeSublayersWithOldSize:" = fn (cg.Size) void;
        pub const @"-resizeWithOldSuperlayerSize:" = fn (cg.Size) void;
        pub const @"+defaultActionForKey:" = fn (foundation.String) ?objc.Object;
        pub const @"-actionForKey:" = fn (foundation.String) ?objc.Object;
        pub const @"-addAnimation:forKey:" = fn (objc.Object, ?foundation.String) void;
        pub const @"-removeAllAnimations" = fn () void;
        pub const @"-removeAnimationForKey:" = fn (foundation.String) void;
        pub const @"-animationKeys" = fn () ?foundation.Array(foundation.String);
        pub const @"-animationForKey:" = fn (foundation.String) ?objc.Object;
        pub const @"-bounds" = fn () cg.Rect;
        pub const @"-setBounds:" = fn (cg.Rect) void;
        pub const @"-position" = fn () cg.Point;
        pub const @"-setPosition:" = fn (cg.Point) void;
        pub const @"-zPosition" = fn () cg.Float;
        pub const @"-setZPosition:" = fn (cg.Float) void;
        pub const @"-anchorPoint" = fn () cg.Point;
        pub const @"-setAnchorPoint:" = fn (cg.Point) void;
        pub const @"-anchorPointZ" = fn () cg.Float;
        pub const @"-setAnchorPointZ:" = fn (cg.Float) void;
        pub const @"-transform" = fn () Transform3D;
        pub const @"-setTransform:" = fn (Transform3D) void;
        pub const @"-frame" = fn () cg.Rect;
        pub const @"-setFrame:" = fn (cg.Rect) void;
        pub const @"-isHidden" = fn () bool;
        pub const @"-setHidden:" = fn (bool) void;
        pub const @"-isDoubleSided" = fn () bool;
        pub const @"-setDoubleSided:" = fn (bool) void;
        pub const @"-isGeometryFlipped" = fn () bool;
        pub const @"-setGeometryFlipped:" = fn (bool) void;
        pub const @"-superlayer" = fn () ?Layer;
        pub const @"-sublayers" = fn () ?foundation.Array(Layer);
        pub const @"-setSublayers:" = fn (?foundation.Array(Layer)) void;
        pub const @"-sublayerTransform" = fn () Transform3D;
        pub const @"-setSublayerTransform:" = fn (Transform3D) void;
        pub const @"-mask" = fn () ?Layer;
        pub const @"-setMask:" = fn (?Layer) void;
        pub const @"-masksToBounds" = fn () bool;
        pub const @"-setMasksToBounds:" = fn (bool) void;
        pub const @"-contents" = fn () ?objc.Object;
        pub const @"-setContents:" = fn (?objc.Object) void;
        pub const @"-contentsRect" = fn () cg.Rect;
        pub const @"-setContentsRect:" = fn (cg.Rect) void;
        pub const @"-contentsGravity" = fn () foundation.String;
        pub const @"-setContentsGravity:" = fn (foundation.String) void;
        pub const @"-contentsScale" = fn () cg.Float;
        pub const @"-setContentsScale:" = fn (cg.Float) void;
        pub const @"-contentsCenter" = fn () cg.Rect;
        pub const @"-setContentsCenter:" = fn (cg.Rect) void;
        pub const @"-contentsFormat" = fn () foundation.String;
        pub const @"-setContentsFormat:" = fn (foundation.String) void;
        pub const @"-wantsExtendedDynamicRangeContent" = fn () bool;
        pub const @"-setWantsExtendedDynamicRangeContent:" = fn (bool) void;
        pub const @"-toneMapMode" = fn () foundation.String;
        pub const @"-setToneMapMode:" = fn (foundation.String) void;
        pub const @"-preferredDynamicRange" = fn () foundation.String;
        pub const @"-setPreferredDynamicRange:" = fn (foundation.String) void;
        pub const @"-contentsHeadroom" = fn () cg.Float;
        pub const @"-setContentsHeadroom:" = fn (cg.Float) void;
        pub const @"-wantsDynamicContentScaling" = fn () bool;
        pub const @"-setWantsDynamicContentScaling:" = fn (bool) void;
        pub const @"-minificationFilter" = fn () foundation.String;
        pub const @"-setMinificationFilter:" = fn (foundation.String) void;
        pub const @"-magnificationFilter" = fn () foundation.String;
        pub const @"-setMagnificationFilter:" = fn (foundation.String) void;
        pub const @"-minificationFilterBias" = fn () f32;
        pub const @"-setMinificationFilterBias:" = fn (f32) void;
        pub const @"-isOpaque" = fn () bool;
        pub const @"-setOpaque:" = fn (bool) void;
        pub const @"-needsDisplayOnBoundsChange" = fn () bool;
        pub const @"-setNeedsDisplayOnBoundsChange:" = fn (bool) void;
        pub const @"-drawsAsynchronously" = fn () bool;
        pub const @"-setDrawsAsynchronously:" = fn (bool) void;
        pub const @"-edgeAntialiasingMask" = fn () EdgeAntialiasingMask;
        pub const @"-setEdgeAntialiasingMask:" = fn (EdgeAntialiasingMask) void;
        pub const @"-allowsEdgeAntialiasing" = fn () bool;
        pub const @"-setAllowsEdgeAntialiasing:" = fn (bool) void;
        pub const @"-backgroundColor" = fn () ?cg.Color;
        pub const @"-setBackgroundColor:" = fn (?cg.Color) void;
        pub const @"-cornerRadius" = fn () cg.Float;
        pub const @"-setCornerRadius:" = fn (cg.Float) void;
        pub const @"-maskedCorners" = fn () CornerMask;
        pub const @"-setMaskedCorners:" = fn (CornerMask) void;
        pub const @"-cornerCurve" = fn () foundation.String;
        pub const @"-setCornerCurve:" = fn (foundation.String) void;
        pub const @"-borderWidth" = fn () cg.Float;
        pub const @"-setBorderWidth:" = fn (cg.Float) void;
        pub const @"-borderColor" = fn () ?cg.Color;
        pub const @"-setBorderColor:" = fn (?cg.Color) void;
        pub const @"-opacity" = fn () f32;
        pub const @"-setOpacity:" = fn (f32) void;
        pub const @"-allowsGroupOpacity" = fn () bool;
        pub const @"-setAllowsGroupOpacity:" = fn (bool) void;
        pub const @"-compositingFilter" = fn () ?objc.Object;
        pub const @"-setCompositingFilter:" = fn (?objc.Object) void;
        pub const @"-filters" = fn () ?foundation.Array(objc.Object);
        pub const @"-setFilters:" = fn (?foundation.Array(objc.Object)) void;
        pub const @"-backgroundFilters" = fn () ?foundation.Array(objc.Object);
        pub const @"-setBackgroundFilters:" = fn (?foundation.Array(objc.Object)) void;
        pub const @"-shouldRasterize" = fn () bool;
        pub const @"-setShouldRasterize:" = fn (bool) void;
        pub const @"-rasterizationScale" = fn () cg.Float;
        pub const @"-setRasterizationScale:" = fn (cg.Float) void;
        pub const @"-shadowColor" = fn () ?cg.Color;
        pub const @"-setShadowColor:" = fn (?cg.Color) void;
        pub const @"-shadowOpacity" = fn () f32;
        pub const @"-setShadowOpacity:" = fn (f32) void;
        pub const @"-shadowOffset" = fn () cg.Size;
        pub const @"-setShadowOffset:" = fn (cg.Size) void;
        pub const @"-shadowRadius" = fn () cg.Float;
        pub const @"-setShadowRadius:" = fn (cg.Float) void;
        pub const @"-shadowPath" = fn () ?cg.Path;
        pub const @"-setShadowPath:" = fn (?cg.Path) void;
        pub const @"-autoresizingMask" = fn () AutoresizingMask;
        pub const @"-setAutoresizingMask:" = fn (AutoresizingMask) void;
        pub const @"-layoutManager" = fn () ?objc.Object;
        pub const @"-setLayoutManager:" = fn (?objc.Object) void;
        pub const @"-actions" = fn () ?foundation.Dictionary(foundation.String, objc.Object);
        pub const @"-setActions:" = fn (?foundation.Dictionary(foundation.String, objc.Object)) void;
        pub const @"-name" = fn () ?foundation.String;
        pub const @"-setName:" = fn (?foundation.String) void;
        pub const @"-delegate" = fn () ?objc.Object;
        pub const @"-setDelegate:" = fn (?objc.Object) void;
        pub const @"-style" = fn () ?foundation.Dictionary(objc.Object, objc.Object);
        pub const @"-setStyle:" = fn (?foundation.Dictionary(objc.Object, objc.Object)) void;
        pub const @"-addConstraint:" = fn (objc.Object) void;
        pub const @"-constraints" = fn () ?foundation.Array(objc.Object);
        pub const @"-setConstraints:" = fn (?foundation.Array(objc.Object)) void;
        pub const @"+layerWithRemoteClientId:" = fn (u32) Layer;
        pub const @"-scrollPoint:" = fn (cg.Point) void;
        pub const @"-scrollRectToVisible:" = fn (cg.Rect) void;
        pub const @"-visibleRect" = fn () cg.Rect;
    };
};

/// `CAMetalLayer`, a subclass of `CALayer`.
pub const MetalLayer = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = Layer;
    pub const class_name = "CAMetalLayer";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[CAMetalLayer alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `CAMetalLayer`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[CAMetalLayer nextDrawable]`
    pub fn nextDrawable(self: Self) ?MetalDrawable {
        return self.object.msgSend(?MetalDrawable, "nextDrawable", .{});
    }

    /// `-[CAMetalLayer device]`
    pub fn device(self: Self) ?Device {
        return self.object.msgSend(?Device, "device", .{});
    }

    /// `-[CAMetalLayer setDevice:]`
    pub fn setDevice(self: Self, device_: ?Device) void {
        return self.object.msgSend(void, "setDevice:", .{device_});
    }

    /// `-[CAMetalLayer preferredDevice]`
    pub fn preferredDevice(self: Self) ?Device {
        return self.object.msgSend(?Device, "preferredDevice", .{});
    }

    /// `-[CAMetalLayer pixelFormat]`
    pub fn pixelFormat(self: Self) PixelFormat {
        return self.object.msgSend(PixelFormat, "pixelFormat", .{});
    }

    /// `-[CAMetalLayer setPixelFormat:]`
    pub fn setPixelFormat(self: Self, pixel_format: PixelFormat) void {
        return self.object.msgSend(void, "setPixelFormat:", .{pixel_format});
    }

    /// `-[CAMetalLayer framebufferOnly]`
    pub fn framebufferOnly(self: Self) bool {
        return self.object.msgSend(bool, "framebufferOnly", .{});
    }

    /// `-[CAMetalLayer setFramebufferOnly:]`
    pub fn setFramebufferOnly(self: Self, framebuffer_only: bool) void {
        return self.object.msgSend(void, "setFramebufferOnly:", .{framebuffer_only});
    }

    /// `-[CAMetalLayer drawableSize]`
    pub fn drawableSize(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "drawableSize", .{});
    }

    /// `-[CAMetalLayer setDrawableSize:]`
    pub fn setDrawableSize(self: Self, drawable_size: cg.Size) void {
        return self.object.msgSend(void, "setDrawableSize:", .{drawable_size});
    }

    /// `-[CAMetalLayer maximumDrawableCount]`
    pub fn maximumDrawableCount(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maximumDrawableCount", .{});
    }

    /// `-[CAMetalLayer setMaximumDrawableCount:]`
    pub fn setMaximumDrawableCount(self: Self, maximum_drawable_count: objc.UInteger) void {
        return self.object.msgSend(void, "setMaximumDrawableCount:", .{maximum_drawable_count});
    }

    /// `-[CAMetalLayer presentsWithTransaction]`
    pub fn presentsWithTransaction(self: Self) bool {
        return self.object.msgSend(bool, "presentsWithTransaction", .{});
    }

    /// `-[CAMetalLayer setPresentsWithTransaction:]`
    pub fn setPresentsWithTransaction(self: Self, presents_with_transaction: bool) void {
        return self.object.msgSend(void, "setPresentsWithTransaction:", .{presents_with_transaction});
    }

    /// `-[CAMetalLayer colorspace]`
    pub fn colorspace(self: Self) ?cg.ColorSpace {
        return self.object.msgSend(?cg.ColorSpace, "colorspace", .{});
    }

    /// `-[CAMetalLayer setColorspace:]`
    pub fn setColorspace(self: Self, colorspace_: ?cg.ColorSpace) void {
        return self.object.msgSend(void, "setColorspace:", .{colorspace_});
    }

    /// `-[CAMetalLayer wantsExtendedDynamicRangeContent]`
    pub fn wantsExtendedDynamicRangeContent(self: Self) bool {
        return self.object.msgSend(bool, "wantsExtendedDynamicRangeContent", .{});
    }

    /// `-[CAMetalLayer setWantsExtendedDynamicRangeContent:]`
    pub fn setWantsExtendedDynamicRangeContent(self: Self, wants_extended_dynamic_range_content: bool) void {
        return self.object.msgSend(void, "setWantsExtendedDynamicRangeContent:", .{wants_extended_dynamic_range_content});
    }

    /// `-[CAMetalLayer EDRMetadata]`
    pub fn edrMetadata(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "EDRMetadata", .{});
    }

    /// `-[CAMetalLayer setEDRMetadata:]`
    pub fn setEDRMetadata(self: Self, edr_metadata: ?objc.Object) void {
        return self.object.msgSend(void, "setEDRMetadata:", .{edr_metadata});
    }

    /// `-[CAMetalLayer displaySyncEnabled]`
    pub fn displaySyncEnabled(self: Self) bool {
        return self.object.msgSend(bool, "displaySyncEnabled", .{});
    }

    /// `-[CAMetalLayer setDisplaySyncEnabled:]`
    pub fn setDisplaySyncEnabled(self: Self, display_sync_enabled: bool) void {
        return self.object.msgSend(void, "setDisplaySyncEnabled:", .{display_sync_enabled});
    }

    /// `-[CAMetalLayer allowsNextDrawableTimeout]`
    pub fn allowsNextDrawableTimeout(self: Self) bool {
        return self.object.msgSend(bool, "allowsNextDrawableTimeout", .{});
    }

    /// `-[CAMetalLayer setAllowsNextDrawableTimeout:]`
    pub fn setAllowsNextDrawableTimeout(self: Self, allows_next_drawable_timeout: bool) void {
        return self.object.msgSend(void, "setAllowsNextDrawableTimeout:", .{allows_next_drawable_timeout});
    }

    /// `-[CAMetalLayer developerHUDProperties]`
    pub fn developerHUDProperties(self: Self) ?foundation.Dictionary(objc.Object, objc.Object) {
        return self.object.msgSend(?foundation.Dictionary(objc.Object, objc.Object), "developerHUDProperties", .{});
    }

    /// `-[CAMetalLayer setDeveloperHUDProperties:]`
    pub fn setDeveloperHUDProperties(self: Self, developer_hud_properties: ?foundation.Dictionary(objc.Object, objc.Object)) void {
        return self.object.msgSend(void, "setDeveloperHUDProperties:", .{developer_hud_properties});
    }

    /// `-[CAMetalLayer residencySet]`
    pub fn residencySet(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "residencySet", .{});
    }

    /// `+[CALayer layer]`
    pub fn layer() MetalLayer {
        return class().msgSend(MetalLayer, "layer", .{});
    }

    /// `-[CALayer init]`
    pub fn init(self: Self) MetalLayer {
        return self.object.msgSend(MetalLayer, "init", .{});
    }

    /// `-[CALayer initWithLayer:]`
    pub fn initWithLayer(self: Self, layer_: objc.Object) MetalLayer {
        return self.object.msgSend(MetalLayer, "initWithLayer:", .{layer_});
    }

    /// `-[CALayer presentationLayer]`
    pub fn presentationLayer(self: Self) ?MetalLayer {
        return self.object.msgSend(?MetalLayer, "presentationLayer", .{});
    }

    /// `-[CALayer modelLayer]`
    pub fn modelLayer(self: Self) MetalLayer {
        return self.object.msgSend(MetalLayer, "modelLayer", .{});
    }

    /// `+[CALayer defaultValueForKey:]`
    pub fn defaultValueForKey(key: foundation.String) ?objc.Object {
        return class().msgSend(?objc.Object, "defaultValueForKey:", .{key});
    }

    /// `+[CALayer needsDisplayForKey:]`
    pub fn needsDisplayForKey(key: foundation.String) bool {
        return class().msgSend(bool, "needsDisplayForKey:", .{key});
    }

    /// `-[CALayer shouldArchiveValueForKey:]`
    pub fn shouldArchiveValueForKey(self: Self, key: foundation.String) bool {
        return self.object.msgSend(bool, "shouldArchiveValueForKey:", .{key});
    }

    /// `-[CALayer affineTransform]`
    pub fn affineTransform(self: Self) cg.AffineTransform {
        return self.object.msgSend(cg.AffineTransform, "affineTransform", .{});
    }

    /// `-[CALayer setAffineTransform:]`
    pub fn setAffineTransform(self: Self, m: cg.AffineTransform) void {
        return self.object.msgSend(void, "setAffineTransform:", .{m});
    }

    /// `-[CALayer contentsAreFlipped]`
    pub fn contentsAreFlipped(self: Self) bool {
        return self.object.msgSend(bool, "contentsAreFlipped", .{});
    }

    /// `-[CALayer removeFromSuperlayer]`
    pub fn removeFromSuperlayer(self: Self) void {
        return self.object.msgSend(void, "removeFromSuperlayer", .{});
    }

    /// `-[CALayer addSublayer:]`
    pub fn addSublayer(self: Self, layer_: Layer) void {
        return self.object.msgSend(void, "addSublayer:", .{layer_});
    }

    /// `-[CALayer insertSublayer:atIndex:]`
    pub fn insertSublayerAtIndex(self: Self, layer_: Layer, idx: c_uint) void {
        return self.object.msgSend(void, "insertSublayer:atIndex:", .{ layer_, idx });
    }

    /// `-[CALayer insertSublayer:below:]`
    pub fn insertSublayerBelow(self: Self, layer_: Layer, sibling: ?Layer) void {
        return self.object.msgSend(void, "insertSublayer:below:", .{ layer_, sibling });
    }

    /// `-[CALayer insertSublayer:above:]`
    pub fn insertSublayerAbove(self: Self, layer_: Layer, sibling: ?Layer) void {
        return self.object.msgSend(void, "insertSublayer:above:", .{ layer_, sibling });
    }

    /// `-[CALayer replaceSublayer:with:]`
    pub fn replaceSublayerWith(self: Self, old_layer: Layer, new_layer: Layer) void {
        return self.object.msgSend(void, "replaceSublayer:with:", .{ old_layer, new_layer });
    }

    /// `-[CALayer convertPoint:fromLayer:]`
    pub fn convertPointFromLayer(self: Self, p: cg.Point, l: ?Layer) cg.Point {
        return self.object.msgSend(cg.Point, "convertPoint:fromLayer:", .{ p, l });
    }

    /// `-[CALayer convertPoint:toLayer:]`
    pub fn convertPointToLayer(self: Self, p: cg.Point, l: ?Layer) cg.Point {
        return self.object.msgSend(cg.Point, "convertPoint:toLayer:", .{ p, l });
    }

    /// `-[CALayer convertRect:fromLayer:]`
    pub fn convertRectFromLayer(self: Self, r: cg.Rect, l: ?Layer) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRect:fromLayer:", .{ r, l });
    }

    /// `-[CALayer convertRect:toLayer:]`
    pub fn convertRectToLayer(self: Self, r: cg.Rect, l: ?Layer) cg.Rect {
        return self.object.msgSend(cg.Rect, "convertRect:toLayer:", .{ r, l });
    }

    /// `-[CALayer convertTime:fromLayer:]`
    pub fn convertTimeFromLayer(self: Self, t: f64, l: ?Layer) f64 {
        return self.object.msgSend(f64, "convertTime:fromLayer:", .{ t, l });
    }

    /// `-[CALayer convertTime:toLayer:]`
    pub fn convertTimeToLayer(self: Self, t: f64, l: ?Layer) f64 {
        return self.object.msgSend(f64, "convertTime:toLayer:", .{ t, l });
    }

    /// `-[CALayer hitTest:]`
    pub fn hitTest(self: Self, p: cg.Point) ?Layer {
        return self.object.msgSend(?Layer, "hitTest:", .{p});
    }

    /// `-[CALayer containsPoint:]`
    pub fn containsPoint(self: Self, p: cg.Point) bool {
        return self.object.msgSend(bool, "containsPoint:", .{p});
    }

    /// `-[CALayer display]`
    pub fn display(self: Self) void {
        return self.object.msgSend(void, "display", .{});
    }

    /// `-[CALayer setNeedsDisplay]`
    pub fn setNeedsDisplay(self: Self) void {
        return self.object.msgSend(void, "setNeedsDisplay", .{});
    }

    /// `-[CALayer setNeedsDisplayInRect:]`
    pub fn setNeedsDisplayInRect(self: Self, r: cg.Rect) void {
        return self.object.msgSend(void, "setNeedsDisplayInRect:", .{r});
    }

    /// `-[CALayer needsDisplay]`
    pub fn needsDisplay(self: Self) bool {
        return self.object.msgSend(bool, "needsDisplay", .{});
    }

    /// `-[CALayer displayIfNeeded]`
    pub fn displayIfNeeded(self: Self) void {
        return self.object.msgSend(void, "displayIfNeeded", .{});
    }

    /// `-[CALayer drawInContext:]`
    pub fn drawInContext(self: Self, ctx: cg.Context) void {
        return self.object.msgSend(void, "drawInContext:", .{ctx});
    }

    /// `-[CALayer renderInContext:]`
    pub fn renderInContext(self: Self, ctx: cg.Context) void {
        return self.object.msgSend(void, "renderInContext:", .{ctx});
    }

    /// `+[CALayer cornerCurveExpansionFactor:]`
    pub fn cornerCurveExpansionFactor(curve: foundation.String) cg.Float {
        return class().msgSend(cg.Float, "cornerCurveExpansionFactor:", .{curve});
    }

    /// `-[CALayer preferredFrameSize]`
    pub fn preferredFrameSize(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "preferredFrameSize", .{});
    }

    /// `-[CALayer setNeedsLayout]`
    pub fn setNeedsLayout(self: Self) void {
        return self.object.msgSend(void, "setNeedsLayout", .{});
    }

    /// `-[CALayer needsLayout]`
    pub fn needsLayout(self: Self) bool {
        return self.object.msgSend(bool, "needsLayout", .{});
    }

    /// `-[CALayer layoutIfNeeded]`
    pub fn layoutIfNeeded(self: Self) void {
        return self.object.msgSend(void, "layoutIfNeeded", .{});
    }

    /// `-[CALayer layoutSublayers]`
    pub fn layoutSublayers(self: Self) void {
        return self.object.msgSend(void, "layoutSublayers", .{});
    }

    /// `-[CALayer resizeSublayersWithOldSize:]`
    pub fn resizeSublayersWithOldSize(self: Self, size: cg.Size) void {
        return self.object.msgSend(void, "resizeSublayersWithOldSize:", .{size});
    }

    /// `-[CALayer resizeWithOldSuperlayerSize:]`
    pub fn resizeWithOldSuperlayerSize(self: Self, size: cg.Size) void {
        return self.object.msgSend(void, "resizeWithOldSuperlayerSize:", .{size});
    }

    /// `+[CALayer defaultActionForKey:]`
    pub fn defaultActionForKey(event: foundation.String) ?objc.Object {
        return class().msgSend(?objc.Object, "defaultActionForKey:", .{event});
    }

    /// `-[CALayer actionForKey:]`
    pub fn actionForKey(self: Self, event: foundation.String) ?objc.Object {
        return self.object.msgSend(?objc.Object, "actionForKey:", .{event});
    }

    /// `-[CALayer addAnimation:forKey:]`
    pub fn addAnimationForKey(self: Self, anim: objc.Object, key: ?foundation.String) void {
        return self.object.msgSend(void, "addAnimation:forKey:", .{ anim, key });
    }

    /// `-[CALayer removeAllAnimations]`
    pub fn removeAllAnimations(self: Self) void {
        return self.object.msgSend(void, "removeAllAnimations", .{});
    }

    /// `-[CALayer removeAnimationForKey:]`
    pub fn removeAnimationForKey(self: Self, key: foundation.String) void {
        return self.object.msgSend(void, "removeAnimationForKey:", .{key});
    }

    /// `-[CALayer animationKeys]`
    pub fn animationKeys(self: Self) ?foundation.Array(foundation.String) {
        return self.object.msgSend(?foundation.Array(foundation.String), "animationKeys", .{});
    }

    /// `-[CALayer animationForKey:]`
    pub fn animationForKey(self: Self, key: foundation.String) ?objc.Object {
        return self.object.msgSend(?objc.Object, "animationForKey:", .{key});
    }

    /// `-[CALayer bounds]`
    pub fn bounds(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "bounds", .{});
    }

    /// `-[CALayer setBounds:]`
    pub fn setBounds(self: Self, bounds_: cg.Rect) void {
        return self.object.msgSend(void, "setBounds:", .{bounds_});
    }

    /// `-[CALayer position]`
    pub fn position(self: Self) cg.Point {
        return self.object.msgSend(cg.Point, "position", .{});
    }

    /// `-[CALayer setPosition:]`
    pub fn setPosition(self: Self, position_: cg.Point) void {
        return self.object.msgSend(void, "setPosition:", .{position_});
    }

    /// `-[CALayer zPosition]`
    pub fn zPosition(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "zPosition", .{});
    }

    /// `-[CALayer setZPosition:]`
    pub fn setZPosition(self: Self, z_position: cg.Float) void {
        return self.object.msgSend(void, "setZPosition:", .{z_position});
    }

    /// `-[CALayer anchorPoint]`
    pub fn anchorPoint(self: Self) cg.Point {
        return self.object.msgSend(cg.Point, "anchorPoint", .{});
    }

    /// `-[CALayer setAnchorPoint:]`
    pub fn setAnchorPoint(self: Self, anchor_point: cg.Point) void {
        return self.object.msgSend(void, "setAnchorPoint:", .{anchor_point});
    }

    /// `-[CALayer anchorPointZ]`
    pub fn anchorPointZ(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "anchorPointZ", .{});
    }

    /// `-[CALayer setAnchorPointZ:]`
    pub fn setAnchorPointZ(self: Self, anchor_point_z: cg.Float) void {
        return self.object.msgSend(void, "setAnchorPointZ:", .{anchor_point_z});
    }

    /// `-[CALayer transform]`
    pub fn transform(self: Self) Transform3D {
        return self.object.msgSend(Transform3D, "transform", .{});
    }

    /// `-[CALayer setTransform:]`
    pub fn setTransform(self: Self, transform_: Transform3D) void {
        return self.object.msgSend(void, "setTransform:", .{transform_});
    }

    /// `-[CALayer frame]`
    pub fn frame(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "frame", .{});
    }

    /// `-[CALayer setFrame:]`
    pub fn setFrame(self: Self, frame_: cg.Rect) void {
        return self.object.msgSend(void, "setFrame:", .{frame_});
    }

    /// `-[CALayer isHidden]`
    pub fn isHidden(self: Self) bool {
        return self.object.msgSend(bool, "isHidden", .{});
    }

    /// `-[CALayer setHidden:]`
    pub fn setHidden(self: Self, hidden: bool) void {
        return self.object.msgSend(void, "setHidden:", .{hidden});
    }

    /// `-[CALayer isDoubleSided]`
    pub fn isDoubleSided(self: Self) bool {
        return self.object.msgSend(bool, "isDoubleSided", .{});
    }

    /// `-[CALayer setDoubleSided:]`
    pub fn setDoubleSided(self: Self, double_sided: bool) void {
        return self.object.msgSend(void, "setDoubleSided:", .{double_sided});
    }

    /// `-[CALayer isGeometryFlipped]`
    pub fn isGeometryFlipped(self: Self) bool {
        return self.object.msgSend(bool, "isGeometryFlipped", .{});
    }

    /// `-[CALayer setGeometryFlipped:]`
    pub fn setGeometryFlipped(self: Self, geometry_flipped: bool) void {
        return self.object.msgSend(void, "setGeometryFlipped:", .{geometry_flipped});
    }

    /// `-[CALayer superlayer]`
    pub fn superlayer(self: Self) ?Layer {
        return self.object.msgSend(?Layer, "superlayer", .{});
    }

    /// `-[CALayer sublayers]`
    pub fn sublayers(self: Self) ?foundation.Array(Layer) {
        return self.object.msgSend(?foundation.Array(Layer), "sublayers", .{});
    }

    /// `-[CALayer setSublayers:]`
    pub fn setSublayers(self: Self, sublayers_: ?foundation.Array(Layer)) void {
        return self.object.msgSend(void, "setSublayers:", .{sublayers_});
    }

    /// `-[CALayer sublayerTransform]`
    pub fn sublayerTransform(self: Self) Transform3D {
        return self.object.msgSend(Transform3D, "sublayerTransform", .{});
    }

    /// `-[CALayer setSublayerTransform:]`
    pub fn setSublayerTransform(self: Self, sublayer_transform: Transform3D) void {
        return self.object.msgSend(void, "setSublayerTransform:", .{sublayer_transform});
    }

    /// `-[CALayer mask]`
    pub fn mask(self: Self) ?Layer {
        return self.object.msgSend(?Layer, "mask", .{});
    }

    /// `-[CALayer setMask:]`
    pub fn setMask(self: Self, mask_: ?Layer) void {
        return self.object.msgSend(void, "setMask:", .{mask_});
    }

    /// `-[CALayer masksToBounds]`
    pub fn masksToBounds(self: Self) bool {
        return self.object.msgSend(bool, "masksToBounds", .{});
    }

    /// `-[CALayer setMasksToBounds:]`
    pub fn setMasksToBounds(self: Self, masks_to_bounds: bool) void {
        return self.object.msgSend(void, "setMasksToBounds:", .{masks_to_bounds});
    }

    /// `-[CALayer contents]`
    pub fn contents(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "contents", .{});
    }

    /// `-[CALayer setContents:]`
    pub fn setContents(self: Self, contents_: ?objc.Object) void {
        return self.object.msgSend(void, "setContents:", .{contents_});
    }

    /// `-[CALayer contentsRect]`
    pub fn contentsRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "contentsRect", .{});
    }

    /// `-[CALayer setContentsRect:]`
    pub fn setContentsRect(self: Self, contents_rect: cg.Rect) void {
        return self.object.msgSend(void, "setContentsRect:", .{contents_rect});
    }

    /// `-[CALayer contentsGravity]`
    pub fn contentsGravity(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "contentsGravity", .{});
    }

    /// `-[CALayer setContentsGravity:]`
    pub fn setContentsGravity(self: Self, contents_gravity: foundation.String) void {
        return self.object.msgSend(void, "setContentsGravity:", .{contents_gravity});
    }

    /// `-[CALayer contentsScale]`
    pub fn contentsScale(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "contentsScale", .{});
    }

    /// `-[CALayer setContentsScale:]`
    pub fn setContentsScale(self: Self, contents_scale: cg.Float) void {
        return self.object.msgSend(void, "setContentsScale:", .{contents_scale});
    }

    /// `-[CALayer contentsCenter]`
    pub fn contentsCenter(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "contentsCenter", .{});
    }

    /// `-[CALayer setContentsCenter:]`
    pub fn setContentsCenter(self: Self, contents_center: cg.Rect) void {
        return self.object.msgSend(void, "setContentsCenter:", .{contents_center});
    }

    /// `-[CALayer contentsFormat]`
    pub fn contentsFormat(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "contentsFormat", .{});
    }

    /// `-[CALayer setContentsFormat:]`
    pub fn setContentsFormat(self: Self, contents_format: foundation.String) void {
        return self.object.msgSend(void, "setContentsFormat:", .{contents_format});
    }

    /// `-[CALayer toneMapMode]`
    pub fn toneMapMode(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "toneMapMode", .{});
    }

    /// `-[CALayer setToneMapMode:]`
    pub fn setToneMapMode(self: Self, tone_map_mode: foundation.String) void {
        return self.object.msgSend(void, "setToneMapMode:", .{tone_map_mode});
    }

    /// `-[CALayer preferredDynamicRange]`
    pub fn preferredDynamicRange(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "preferredDynamicRange", .{});
    }

    /// `-[CALayer setPreferredDynamicRange:]`
    pub fn setPreferredDynamicRange(self: Self, preferred_dynamic_range: foundation.String) void {
        return self.object.msgSend(void, "setPreferredDynamicRange:", .{preferred_dynamic_range});
    }

    /// `-[CALayer contentsHeadroom]`
    pub fn contentsHeadroom(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "contentsHeadroom", .{});
    }

    /// `-[CALayer setContentsHeadroom:]`
    pub fn setContentsHeadroom(self: Self, contents_headroom: cg.Float) void {
        return self.object.msgSend(void, "setContentsHeadroom:", .{contents_headroom});
    }

    /// `-[CALayer wantsDynamicContentScaling]`
    pub fn wantsDynamicContentScaling(self: Self) bool {
        return self.object.msgSend(bool, "wantsDynamicContentScaling", .{});
    }

    /// `-[CALayer setWantsDynamicContentScaling:]`
    pub fn setWantsDynamicContentScaling(self: Self, wants_dynamic_content_scaling: bool) void {
        return self.object.msgSend(void, "setWantsDynamicContentScaling:", .{wants_dynamic_content_scaling});
    }

    /// `-[CALayer minificationFilter]`
    pub fn minificationFilter(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "minificationFilter", .{});
    }

    /// `-[CALayer setMinificationFilter:]`
    pub fn setMinificationFilter(self: Self, minification_filter: foundation.String) void {
        return self.object.msgSend(void, "setMinificationFilter:", .{minification_filter});
    }

    /// `-[CALayer magnificationFilter]`
    pub fn magnificationFilter(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "magnificationFilter", .{});
    }

    /// `-[CALayer setMagnificationFilter:]`
    pub fn setMagnificationFilter(self: Self, magnification_filter: foundation.String) void {
        return self.object.msgSend(void, "setMagnificationFilter:", .{magnification_filter});
    }

    /// `-[CALayer minificationFilterBias]`
    pub fn minificationFilterBias(self: Self) f32 {
        return self.object.msgSend(f32, "minificationFilterBias", .{});
    }

    /// `-[CALayer setMinificationFilterBias:]`
    pub fn setMinificationFilterBias(self: Self, minification_filter_bias: f32) void {
        return self.object.msgSend(void, "setMinificationFilterBias:", .{minification_filter_bias});
    }

    /// `-[CALayer isOpaque]`
    pub fn isOpaque(self: Self) bool {
        return self.object.msgSend(bool, "isOpaque", .{});
    }

    /// `-[CALayer setOpaque:]`
    pub fn setOpaque(self: Self, @"opaque": bool) void {
        return self.object.msgSend(void, "setOpaque:", .{@"opaque"});
    }

    /// `-[CALayer needsDisplayOnBoundsChange]`
    pub fn needsDisplayOnBoundsChange(self: Self) bool {
        return self.object.msgSend(bool, "needsDisplayOnBoundsChange", .{});
    }

    /// `-[CALayer setNeedsDisplayOnBoundsChange:]`
    pub fn setNeedsDisplayOnBoundsChange(self: Self, needs_display_on_bounds_change: bool) void {
        return self.object.msgSend(void, "setNeedsDisplayOnBoundsChange:", .{needs_display_on_bounds_change});
    }

    /// `-[CALayer drawsAsynchronously]`
    pub fn drawsAsynchronously(self: Self) bool {
        return self.object.msgSend(bool, "drawsAsynchronously", .{});
    }

    /// `-[CALayer setDrawsAsynchronously:]`
    pub fn setDrawsAsynchronously(self: Self, draws_asynchronously: bool) void {
        return self.object.msgSend(void, "setDrawsAsynchronously:", .{draws_asynchronously});
    }

    /// `-[CALayer edgeAntialiasingMask]`
    pub fn edgeAntialiasingMask(self: Self) EdgeAntialiasingMask {
        return self.object.msgSend(EdgeAntialiasingMask, "edgeAntialiasingMask", .{});
    }

    /// `-[CALayer setEdgeAntialiasingMask:]`
    pub fn setEdgeAntialiasingMask(self: Self, edge_antialiasing_mask: EdgeAntialiasingMask) void {
        return self.object.msgSend(void, "setEdgeAntialiasingMask:", .{edge_antialiasing_mask});
    }

    /// `-[CALayer allowsEdgeAntialiasing]`
    pub fn allowsEdgeAntialiasing(self: Self) bool {
        return self.object.msgSend(bool, "allowsEdgeAntialiasing", .{});
    }

    /// `-[CALayer setAllowsEdgeAntialiasing:]`
    pub fn setAllowsEdgeAntialiasing(self: Self, allows_edge_antialiasing: bool) void {
        return self.object.msgSend(void, "setAllowsEdgeAntialiasing:", .{allows_edge_antialiasing});
    }

    /// `-[CALayer backgroundColor]`
    pub fn backgroundColor(self: Self) ?cg.Color {
        return self.object.msgSend(?cg.Color, "backgroundColor", .{});
    }

    /// `-[CALayer setBackgroundColor:]`
    pub fn setBackgroundColor(self: Self, background_color: ?cg.Color) void {
        return self.object.msgSend(void, "setBackgroundColor:", .{background_color});
    }

    /// `-[CALayer cornerRadius]`
    pub fn cornerRadius(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "cornerRadius", .{});
    }

    /// `-[CALayer setCornerRadius:]`
    pub fn setCornerRadius(self: Self, corner_radius: cg.Float) void {
        return self.object.msgSend(void, "setCornerRadius:", .{corner_radius});
    }

    /// `-[CALayer maskedCorners]`
    pub fn maskedCorners(self: Self) CornerMask {
        return self.object.msgSend(CornerMask, "maskedCorners", .{});
    }

    /// `-[CALayer setMaskedCorners:]`
    pub fn setMaskedCorners(self: Self, masked_corners: CornerMask) void {
        return self.object.msgSend(void, "setMaskedCorners:", .{masked_corners});
    }

    /// `-[CALayer cornerCurve]`
    pub fn cornerCurve(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "cornerCurve", .{});
    }

    /// `-[CALayer setCornerCurve:]`
    pub fn setCornerCurve(self: Self, corner_curve: foundation.String) void {
        return self.object.msgSend(void, "setCornerCurve:", .{corner_curve});
    }

    /// `-[CALayer borderWidth]`
    pub fn borderWidth(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "borderWidth", .{});
    }

    /// `-[CALayer setBorderWidth:]`
    pub fn setBorderWidth(self: Self, border_width: cg.Float) void {
        return self.object.msgSend(void, "setBorderWidth:", .{border_width});
    }

    /// `-[CALayer borderColor]`
    pub fn borderColor(self: Self) ?cg.Color {
        return self.object.msgSend(?cg.Color, "borderColor", .{});
    }

    /// `-[CALayer setBorderColor:]`
    pub fn setBorderColor(self: Self, border_color: ?cg.Color) void {
        return self.object.msgSend(void, "setBorderColor:", .{border_color});
    }

    /// `-[CALayer opacity]`
    pub fn opacity(self: Self) f32 {
        return self.object.msgSend(f32, "opacity", .{});
    }

    /// `-[CALayer setOpacity:]`
    pub fn setOpacity(self: Self, opacity_: f32) void {
        return self.object.msgSend(void, "setOpacity:", .{opacity_});
    }

    /// `-[CALayer allowsGroupOpacity]`
    pub fn allowsGroupOpacity(self: Self) bool {
        return self.object.msgSend(bool, "allowsGroupOpacity", .{});
    }

    /// `-[CALayer setAllowsGroupOpacity:]`
    pub fn setAllowsGroupOpacity(self: Self, allows_group_opacity: bool) void {
        return self.object.msgSend(void, "setAllowsGroupOpacity:", .{allows_group_opacity});
    }

    /// `-[CALayer compositingFilter]`
    pub fn compositingFilter(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "compositingFilter", .{});
    }

    /// `-[CALayer setCompositingFilter:]`
    pub fn setCompositingFilter(self: Self, compositing_filter: ?objc.Object) void {
        return self.object.msgSend(void, "setCompositingFilter:", .{compositing_filter});
    }

    /// `-[CALayer filters]`
    pub fn filters(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "filters", .{});
    }

    /// `-[CALayer setFilters:]`
    pub fn setFilters(self: Self, filters_: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setFilters:", .{filters_});
    }

    /// `-[CALayer backgroundFilters]`
    pub fn backgroundFilters(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "backgroundFilters", .{});
    }

    /// `-[CALayer setBackgroundFilters:]`
    pub fn setBackgroundFilters(self: Self, background_filters: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setBackgroundFilters:", .{background_filters});
    }

    /// `-[CALayer shouldRasterize]`
    pub fn shouldRasterize(self: Self) bool {
        return self.object.msgSend(bool, "shouldRasterize", .{});
    }

    /// `-[CALayer setShouldRasterize:]`
    pub fn setShouldRasterize(self: Self, should_rasterize: bool) void {
        return self.object.msgSend(void, "setShouldRasterize:", .{should_rasterize});
    }

    /// `-[CALayer rasterizationScale]`
    pub fn rasterizationScale(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "rasterizationScale", .{});
    }

    /// `-[CALayer setRasterizationScale:]`
    pub fn setRasterizationScale(self: Self, rasterization_scale: cg.Float) void {
        return self.object.msgSend(void, "setRasterizationScale:", .{rasterization_scale});
    }

    /// `-[CALayer shadowColor]`
    pub fn shadowColor(self: Self) ?cg.Color {
        return self.object.msgSend(?cg.Color, "shadowColor", .{});
    }

    /// `-[CALayer setShadowColor:]`
    pub fn setShadowColor(self: Self, shadow_color: ?cg.Color) void {
        return self.object.msgSend(void, "setShadowColor:", .{shadow_color});
    }

    /// `-[CALayer shadowOpacity]`
    pub fn shadowOpacity(self: Self) f32 {
        return self.object.msgSend(f32, "shadowOpacity", .{});
    }

    /// `-[CALayer setShadowOpacity:]`
    pub fn setShadowOpacity(self: Self, shadow_opacity: f32) void {
        return self.object.msgSend(void, "setShadowOpacity:", .{shadow_opacity});
    }

    /// `-[CALayer shadowOffset]`
    pub fn shadowOffset(self: Self) cg.Size {
        return self.object.msgSend(cg.Size, "shadowOffset", .{});
    }

    /// `-[CALayer setShadowOffset:]`
    pub fn setShadowOffset(self: Self, shadow_offset: cg.Size) void {
        return self.object.msgSend(void, "setShadowOffset:", .{shadow_offset});
    }

    /// `-[CALayer shadowRadius]`
    pub fn shadowRadius(self: Self) cg.Float {
        return self.object.msgSend(cg.Float, "shadowRadius", .{});
    }

    /// `-[CALayer setShadowRadius:]`
    pub fn setShadowRadius(self: Self, shadow_radius: cg.Float) void {
        return self.object.msgSend(void, "setShadowRadius:", .{shadow_radius});
    }

    /// `-[CALayer shadowPath]`
    pub fn shadowPath(self: Self) ?cg.Path {
        return self.object.msgSend(?cg.Path, "shadowPath", .{});
    }

    /// `-[CALayer setShadowPath:]`
    pub fn setShadowPath(self: Self, shadow_path: ?cg.Path) void {
        return self.object.msgSend(void, "setShadowPath:", .{shadow_path});
    }

    /// `-[CALayer autoresizingMask]`
    pub fn autoresizingMask(self: Self) AutoresizingMask {
        return self.object.msgSend(AutoresizingMask, "autoresizingMask", .{});
    }

    /// `-[CALayer setAutoresizingMask:]`
    pub fn setAutoresizingMask(self: Self, autoresizing_mask: AutoresizingMask) void {
        return self.object.msgSend(void, "setAutoresizingMask:", .{autoresizing_mask});
    }

    /// `-[CALayer layoutManager]`
    pub fn layoutManager(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "layoutManager", .{});
    }

    /// `-[CALayer setLayoutManager:]`
    pub fn setLayoutManager(self: Self, layout_manager: ?objc.Object) void {
        return self.object.msgSend(void, "setLayoutManager:", .{layout_manager});
    }

    /// `-[CALayer actions]`
    pub fn actions(self: Self) ?foundation.Dictionary(foundation.String, objc.Object) {
        return self.object.msgSend(?foundation.Dictionary(foundation.String, objc.Object), "actions", .{});
    }

    /// `-[CALayer setActions:]`
    pub fn setActions(self: Self, actions_: ?foundation.Dictionary(foundation.String, objc.Object)) void {
        return self.object.msgSend(void, "setActions:", .{actions_});
    }

    /// `-[CALayer name]`
    pub fn name(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "name", .{});
    }

    /// `-[CALayer setName:]`
    pub fn setName(self: Self, name_: ?foundation.String) void {
        return self.object.msgSend(void, "setName:", .{name_});
    }

    /// `-[CALayer delegate]`
    pub fn delegate(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "delegate", .{});
    }

    /// `-[CALayer setDelegate:]`
    pub fn setDelegate(self: Self, delegate_: ?objc.Object) void {
        return self.object.msgSend(void, "setDelegate:", .{delegate_});
    }

    /// `-[CALayer style]`
    pub fn style(self: Self) ?foundation.Dictionary(objc.Object, objc.Object) {
        return self.object.msgSend(?foundation.Dictionary(objc.Object, objc.Object), "style", .{});
    }

    /// `-[CALayer setStyle:]`
    pub fn setStyle(self: Self, style_: ?foundation.Dictionary(objc.Object, objc.Object)) void {
        return self.object.msgSend(void, "setStyle:", .{style_});
    }

    /// `-[CALayer addConstraint:]`
    pub fn addConstraint(self: Self, c: objc.Object) void {
        return self.object.msgSend(void, "addConstraint:", .{c});
    }

    /// `-[CALayer constraints]`
    pub fn constraints(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "constraints", .{});
    }

    /// `-[CALayer setConstraints:]`
    pub fn setConstraints(self: Self, constraints_: ?foundation.Array(objc.Object)) void {
        return self.object.msgSend(void, "setConstraints:", .{constraints_});
    }

    /// `+[CALayer layerWithRemoteClientId:]`
    pub fn layerWithRemoteClientId(client_id: u32) Layer {
        return class().msgSend(Layer, "layerWithRemoteClientId:", .{client_id});
    }

    /// `-[CALayer scrollPoint:]`
    pub fn scrollPoint(self: Self, p: cg.Point) void {
        return self.object.msgSend(void, "scrollPoint:", .{p});
    }

    /// `-[CALayer scrollRectToVisible:]`
    pub fn scrollRectToVisible(self: Self, r: cg.Rect) void {
        return self.object.msgSend(void, "scrollRectToVisible:", .{r});
    }

    /// `-[CALayer visibleRect]`
    pub fn visibleRect(self: Self) cg.Rect {
        return self.object.msgSend(cg.Rect, "visibleRect", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-nextDrawable" = fn () ?MetalDrawable;
        pub const @"-device" = fn () ?Device;
        pub const @"-setDevice:" = fn (?Device) void;
        pub const @"-preferredDevice" = fn () ?Device;
        pub const @"-pixelFormat" = fn () PixelFormat;
        pub const @"-setPixelFormat:" = fn (PixelFormat) void;
        pub const @"-framebufferOnly" = fn () bool;
        pub const @"-setFramebufferOnly:" = fn (bool) void;
        pub const @"-drawableSize" = fn () cg.Size;
        pub const @"-setDrawableSize:" = fn (cg.Size) void;
        pub const @"-maximumDrawableCount" = fn () objc.UInteger;
        pub const @"-setMaximumDrawableCount:" = fn (objc.UInteger) void;
        pub const @"-presentsWithTransaction" = fn () bool;
        pub const @"-setPresentsWithTransaction:" = fn (bool) void;
        pub const @"-colorspace" = fn () ?cg.ColorSpace;
        pub const @"-setColorspace:" = fn (?cg.ColorSpace) void;
        pub const @"-wantsExtendedDynamicRangeContent" = fn () bool;
        pub const @"-setWantsExtendedDynamicRangeContent:" = fn (bool) void;
        pub const @"-EDRMetadata" = fn () ?objc.Object;
        pub const @"-setEDRMetadata:" = fn (?objc.Object) void;
        pub const @"-displaySyncEnabled" = fn () bool;
        pub const @"-setDisplaySyncEnabled:" = fn (bool) void;
        pub const @"-allowsNextDrawableTimeout" = fn () bool;
        pub const @"-setAllowsNextDrawableTimeout:" = fn (bool) void;
        pub const @"-developerHUDProperties" = fn () ?foundation.Dictionary(objc.Object, objc.Object);
        pub const @"-setDeveloperHUDProperties:" = fn (?foundation.Dictionary(objc.Object, objc.Object)) void;
        pub const @"-residencySet" = fn () objc.Object;
    };
};

/// `CADisplayLink`, a subclass of `NSObject`.
pub const DisplayLink = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const class_name = "CADisplayLink";

    pub fn class() objc.Class {
        return lookUp(class_name);
    }

    /// An uninitialised instance, for an `init...` method. Yours.
    pub fn alloc() Self {
        return class().msgSend(Self, "alloc", .{});
    }

    /// `[[CADisplayLink alloc] init]`. Yours.
    pub fn new() Self {
        return class().msgSend(Self, "new", .{});
    }

    /// An object that came from elsewhere, taken to be a `CADisplayLink`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a superclass's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(class_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `+[CADisplayLink displayLinkWithTarget:selector:]`
    pub fn displayLinkWithTargetSelector(target: objc.Object, sel: objc.Sel) DisplayLink {
        return class().msgSend(DisplayLink, "displayLinkWithTarget:selector:", .{ target, sel });
    }

    /// `-[CADisplayLink addToRunLoop:forMode:]`
    pub fn addToRunLoopForMode(self: Self, runloop: objc.Object, mode: ?foundation.String) void {
        return self.object.msgSend(void, "addToRunLoop:forMode:", .{ runloop, mode });
    }

    /// `-[CADisplayLink removeFromRunLoop:forMode:]`
    pub fn removeFromRunLoopForMode(self: Self, runloop: objc.Object, mode: ?foundation.String) void {
        return self.object.msgSend(void, "removeFromRunLoop:forMode:", .{ runloop, mode });
    }

    /// `-[CADisplayLink invalidate]`
    pub fn invalidate(self: Self) void {
        return self.object.msgSend(void, "invalidate", .{});
    }

    /// `-[CADisplayLink timestamp]`
    pub fn timestamp(self: Self) f64 {
        return self.object.msgSend(f64, "timestamp", .{});
    }

    /// `-[CADisplayLink duration]`
    pub fn duration(self: Self) f64 {
        return self.object.msgSend(f64, "duration", .{});
    }

    /// `-[CADisplayLink targetTimestamp]`
    pub fn targetTimestamp(self: Self) f64 {
        return self.object.msgSend(f64, "targetTimestamp", .{});
    }

    /// `-[CADisplayLink isPaused]`
    pub fn isPaused(self: Self) bool {
        return self.object.msgSend(bool, "isPaused", .{});
    }

    /// `-[CADisplayLink setPaused:]`
    pub fn setPaused(self: Self, paused: bool) void {
        return self.object.msgSend(void, "setPaused:", .{paused});
    }

    /// `-[CADisplayLink frameInterval]`
    pub fn frameInterval(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "frameInterval", .{});
    }

    /// `-[CADisplayLink setFrameInterval:]`
    pub fn setFrameInterval(self: Self, frame_interval: objc.Integer) void {
        return self.object.msgSend(void, "setFrameInterval:", .{frame_interval});
    }

    /// `-[CADisplayLink preferredFramesPerSecond]`
    pub fn preferredFramesPerSecond(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "preferredFramesPerSecond", .{});
    }

    /// `-[CADisplayLink setPreferredFramesPerSecond:]`
    pub fn setPreferredFramesPerSecond(self: Self, preferred_frames_per_second: objc.Integer) void {
        return self.object.msgSend(void, "setPreferredFramesPerSecond:", .{preferred_frames_per_second});
    }

    /// `-[CADisplayLink preferredFrameRateRange]`
    pub fn preferredFrameRateRange(self: Self) FrameRateRange {
        return self.object.msgSend(FrameRateRange, "preferredFrameRateRange", .{});
    }

    /// `-[CADisplayLink setPreferredFrameRateRange:]`
    pub fn setPreferredFrameRateRange(self: Self, preferred_frame_rate_range: FrameRateRange) void {
        return self.object.msgSend(void, "setPreferredFrameRateRange:", .{preferred_frame_rate_range});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"+displayLinkWithTarget:selector:" = fn (objc.Object, objc.Sel) DisplayLink;
        pub const @"-addToRunLoop:forMode:" = fn (objc.Object, ?foundation.String) void;
        pub const @"-removeFromRunLoop:forMode:" = fn (objc.Object, ?foundation.String) void;
        pub const @"-invalidate" = fn () void;
        pub const @"-timestamp" = fn () f64;
        pub const @"-duration" = fn () f64;
        pub const @"-targetTimestamp" = fn () f64;
        pub const @"-isPaused" = fn () bool;
        pub const @"-setPaused:" = fn (bool) void;
        pub const @"-frameInterval" = fn () objc.Integer;
        pub const @"-setFrameInterval:" = fn (objc.Integer) void;
        pub const @"-preferredFramesPerSecond" = fn () objc.Integer;
        pub const @"-setPreferredFramesPerSecond:" = fn (objc.Integer) void;
        pub const @"-preferredFrameRateRange" = fn () FrameRateRange;
        pub const @"-setPreferredFrameRateRange:" = fn (FrameRateRange) void;
    };
};

/// An object conforming to `MTLDevice`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const Device = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "MTLDevice";

    /// An object that came from elsewhere, taken to conform to `MTLDevice`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLDevice newLogStateWithDescriptor:error:]`
    pub fn newLogStateWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newLogStateWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice newCommandQueue]`
    pub fn newCommandQueue(self: Self) ?CommandQueue {
        return self.object.msgSend(?CommandQueue, "newCommandQueue", .{});
    }

    /// `-[MTLDevice newCommandQueueWithMaxCommandBufferCount:]`
    pub fn newCommandQueueWithMaxCommandBufferCount(self: Self, max_command_buffer_count: objc.UInteger) ?CommandQueue {
        return self.object.msgSend(?CommandQueue, "newCommandQueueWithMaxCommandBufferCount:", .{max_command_buffer_count});
    }

    /// `-[MTLDevice newCommandQueueWithDescriptor:]`
    pub fn newCommandQueueWithDescriptor(self: Self, descriptor: objc.Object) ?CommandQueue {
        return self.object.msgSend(?CommandQueue, "newCommandQueueWithDescriptor:", .{descriptor});
    }

    /// `-[MTLDevice heapTextureSizeAndAlignWithDescriptor:]`
    pub fn heapTextureSizeAndAlignWithDescriptor(self: Self, desc: TextureDescriptor) SizeAndAlign {
        return self.object.msgSend(SizeAndAlign, "heapTextureSizeAndAlignWithDescriptor:", .{desc});
    }

    /// `-[MTLDevice heapBufferSizeAndAlignWithLength:options:]`
    pub fn heapBufferSizeAndAlignWithLengthOptions(self: Self, length: objc.UInteger, options: ResourceOptions) SizeAndAlign {
        return self.object.msgSend(SizeAndAlign, "heapBufferSizeAndAlignWithLength:options:", .{ length, options });
    }

    /// `-[MTLDevice newHeapWithDescriptor:]`
    pub fn newHeapWithDescriptor(self: Self, descriptor: objc.Object) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newHeapWithDescriptor:", .{descriptor});
    }

    /// `-[MTLDevice newBufferWithLength:options:]`
    pub fn newBufferWithLengthOptions(self: Self, length: objc.UInteger, options: ResourceOptions) ?Buffer {
        return self.object.msgSend(?Buffer, "newBufferWithLength:options:", .{ length, options });
    }

    /// `-[MTLDevice newBufferWithBytes:length:options:]`
    pub fn newBufferWithBytesLengthOptions(self: Self, pointer: ?*const anyopaque, length: objc.UInteger, options: ResourceOptions) ?Buffer {
        return self.object.msgSend(?Buffer, "newBufferWithBytes:length:options:", .{ pointer, length, options });
    }

    /// `-[MTLDevice newBufferWithBytesNoCopy:length:options:deallocator:]`
    pub fn newBufferWithBytesNoCopyLengthOptionsDeallocator(self: Self, pointer: ?*anyopaque, length: objc.UInteger, options: ResourceOptions, deallocator: ?objc.BlockRef(fn (?*anyopaque, objc.UInteger) void)) ?Buffer {
        return self.object.msgSend(?Buffer, "newBufferWithBytesNoCopy:length:options:deallocator:", .{ pointer, length, options, deallocator });
    }

    /// `-[MTLDevice newDepthStencilStateWithDescriptor:]`
    pub fn newDepthStencilStateWithDescriptor(self: Self, descriptor: DepthStencilDescriptor) ?DepthStencilState {
        return self.object.msgSend(?DepthStencilState, "newDepthStencilStateWithDescriptor:", .{descriptor});
    }

    /// `-[MTLDevice newTextureWithDescriptor:]`
    pub fn newTextureWithDescriptor(self: Self, descriptor: TextureDescriptor) ?Texture {
        return self.object.msgSend(?Texture, "newTextureWithDescriptor:", .{descriptor});
    }

    /// `-[MTLDevice newTextureWithDescriptor:iosurface:plane:]`
    pub fn newTextureWithDescriptorIosurfacePlane(self: Self, descriptor: TextureDescriptor, iosurface: io_surface.Surface, plane: objc.UInteger) ?Texture {
        return self.object.msgSend(?Texture, "newTextureWithDescriptor:iosurface:plane:", .{ descriptor, iosurface, plane });
    }

    /// `-[MTLDevice newSharedTextureWithDescriptor:]`
    pub fn newSharedTextureWithDescriptor(self: Self, descriptor: TextureDescriptor) ?Texture {
        return self.object.msgSend(?Texture, "newSharedTextureWithDescriptor:", .{descriptor});
    }

    /// `-[MTLDevice newSharedTextureWithHandle:]`
    pub fn newSharedTextureWithHandle(self: Self, shared_handle: objc.Object) ?Texture {
        return self.object.msgSend(?Texture, "newSharedTextureWithHandle:", .{shared_handle});
    }

    /// `-[MTLDevice newSamplerStateWithDescriptor:]`
    pub fn newSamplerStateWithDescriptor(self: Self, descriptor: SamplerDescriptor) ?SamplerState {
        return self.object.msgSend(?SamplerState, "newSamplerStateWithDescriptor:", .{descriptor});
    }

    /// `-[MTLDevice newDefaultLibrary]`
    pub fn newDefaultLibrary(self: Self) ?Library {
        return self.object.msgSend(?Library, "newDefaultLibrary", .{});
    }

    /// `-[MTLDevice newDefaultLibraryWithBundle:error:]`
    pub fn newDefaultLibraryWithBundleError(self: Self, bundle: objc.Object, @"error": ?*objc.abi.Id) ?Library {
        return self.object.msgSend(?Library, "newDefaultLibraryWithBundle:error:", .{ bundle, @"error" });
    }

    /// `-[MTLDevice newLibraryWithFile:error:]`
    pub fn newLibraryWithFileError(self: Self, filepath: foundation.String, @"error": ?*objc.abi.Id) ?Library {
        return self.object.msgSend(?Library, "newLibraryWithFile:error:", .{ filepath, @"error" });
    }

    /// `-[MTLDevice newLibraryWithURL:error:]`
    pub fn newLibraryWithURLError(self: Self, url: foundation.Url, @"error": ?*objc.abi.Id) ?Library {
        return self.object.msgSend(?Library, "newLibraryWithURL:error:", .{ url, @"error" });
    }

    /// `-[MTLDevice newLibraryWithData:error:]`
    pub fn newLibraryWithDataError(self: Self, data: ?objc.Object, @"error": ?*objc.abi.Id) ?Library {
        return self.object.msgSend(?Library, "newLibraryWithData:error:", .{ data, @"error" });
    }

    /// `-[MTLDevice newLibraryWithSource:options:error:]`
    pub fn newLibraryWithSourceOptionsError(self: Self, source: foundation.String, options: ?CompileOptions, @"error": ?*objc.abi.Id) ?Library {
        return self.object.msgSend(?Library, "newLibraryWithSource:options:error:", .{ source, options, @"error" });
    }

    /// `-[MTLDevice newLibraryWithSource:options:completionHandler:]`
    pub fn newLibraryWithSourceOptionsCompletionHandler(self: Self, source: foundation.String, options: ?CompileOptions, completion_handler: ?objc.BlockRef(fn (?Library, ?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "newLibraryWithSource:options:completionHandler:", .{ source, options, completion_handler });
    }

    /// `-[MTLDevice newLibraryWithStitchedDescriptor:error:]`
    pub fn newLibraryWithStitchedDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?Library {
        return self.object.msgSend(?Library, "newLibraryWithStitchedDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice newLibraryWithStitchedDescriptor:completionHandler:]`
    pub fn newLibraryWithStitchedDescriptorCompletionHandler(self: Self, descriptor: objc.Object, completion_handler: ?objc.BlockRef(fn (?Library, ?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "newLibraryWithStitchedDescriptor:completionHandler:", .{ descriptor, completion_handler });
    }

    /// `-[MTLDevice newRenderPipelineStateWithDescriptor:error:]`
    pub fn newRenderPipelineStateWithDescriptorError(self: Self, descriptor: RenderPipelineDescriptor, @"error": ?*objc.abi.Id) ?RenderPipelineState {
        return self.object.msgSend(?RenderPipelineState, "newRenderPipelineStateWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice newRenderPipelineStateWithDescriptor:options:reflection:error:]`
    pub fn newRenderPipelineStateWithDescriptorOptionsReflectionError(self: Self, descriptor: RenderPipelineDescriptor, options: PipelineOption, reflection: ?objc.Object, @"error": ?*objc.abi.Id) ?RenderPipelineState {
        return self.object.msgSend(?RenderPipelineState, "newRenderPipelineStateWithDescriptor:options:reflection:error:", .{ descriptor, options, reflection, @"error" });
    }

    /// `-[MTLDevice newRenderPipelineStateWithDescriptor:completionHandler:]`
    pub fn newRenderPipelineStateWithDescriptorCompletionHandler(self: Self, descriptor: RenderPipelineDescriptor, completion_handler: ?objc.BlockRef(fn (?RenderPipelineState, ?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "newRenderPipelineStateWithDescriptor:completionHandler:", .{ descriptor, completion_handler });
    }

    /// `-[MTLDevice newRenderPipelineStateWithDescriptor:options:completionHandler:]`
    pub fn newRenderPipelineStateWithDescriptorOptionsCompletionHandler(self: Self, descriptor: RenderPipelineDescriptor, options: PipelineOption, completion_handler: ?objc.BlockRef(fn (?RenderPipelineState, ?objc.Object, ?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "newRenderPipelineStateWithDescriptor:options:completionHandler:", .{ descriptor, options, completion_handler });
    }

    /// `-[MTLDevice newComputePipelineStateWithFunction:error:]`
    pub fn newComputePipelineStateWithFunctionError(self: Self, compute_function: Function, @"error": ?*objc.abi.Id) ?ComputePipelineState {
        return self.object.msgSend(?ComputePipelineState, "newComputePipelineStateWithFunction:error:", .{ compute_function, @"error" });
    }

    /// `-[MTLDevice newComputePipelineStateWithFunction:options:reflection:error:]`
    pub fn newComputePipelineStateWithFunctionOptionsReflectionError(self: Self, compute_function: Function, options: PipelineOption, reflection: ?objc.Object, @"error": ?*objc.abi.Id) ?ComputePipelineState {
        return self.object.msgSend(?ComputePipelineState, "newComputePipelineStateWithFunction:options:reflection:error:", .{ compute_function, options, reflection, @"error" });
    }

    /// `-[MTLDevice newComputePipelineStateWithFunction:completionHandler:]`
    pub fn newComputePipelineStateWithFunctionCompletionHandler(self: Self, compute_function: Function, completion_handler: ?objc.BlockRef(fn (?ComputePipelineState, ?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "newComputePipelineStateWithFunction:completionHandler:", .{ compute_function, completion_handler });
    }

    /// `-[MTLDevice newComputePipelineStateWithFunction:options:completionHandler:]`
    pub fn newComputePipelineStateWithFunctionOptionsCompletionHandler(self: Self, compute_function: Function, options: PipelineOption, completion_handler: ?objc.BlockRef(fn (?ComputePipelineState, ?objc.Object, ?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "newComputePipelineStateWithFunction:options:completionHandler:", .{ compute_function, options, completion_handler });
    }

    /// `-[MTLDevice newComputePipelineStateWithDescriptor:options:reflection:error:]`
    pub fn newComputePipelineStateWithDescriptorOptionsReflectionError(self: Self, descriptor: ComputePipelineDescriptor, options: PipelineOption, reflection: ?objc.Object, @"error": ?*objc.abi.Id) ?ComputePipelineState {
        return self.object.msgSend(?ComputePipelineState, "newComputePipelineStateWithDescriptor:options:reflection:error:", .{ descriptor, options, reflection, @"error" });
    }

    /// `-[MTLDevice newComputePipelineStateWithDescriptor:options:completionHandler:]`
    pub fn newComputePipelineStateWithDescriptorOptionsCompletionHandler(self: Self, descriptor: ComputePipelineDescriptor, options: PipelineOption, completion_handler: ?objc.BlockRef(fn (?ComputePipelineState, ?objc.Object, ?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "newComputePipelineStateWithDescriptor:options:completionHandler:", .{ descriptor, options, completion_handler });
    }

    /// `-[MTLDevice newFence]`
    pub fn newFence(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newFence", .{});
    }

    /// `-[MTLDevice supportsFeatureSet:]`
    pub fn supportsFeatureSet(self: Self, feature_set: FeatureSet) bool {
        return self.object.msgSend(bool, "supportsFeatureSet:", .{feature_set});
    }

    /// `-[MTLDevice supportsFamily:]`
    pub fn supportsFamily(self: Self, gpu_family: GPUFamily) bool {
        return self.object.msgSend(bool, "supportsFamily:", .{gpu_family});
    }

    /// `-[MTLDevice supportsTextureSampleCount:]`
    pub fn supportsTextureSampleCount(self: Self, sample_count: objc.UInteger) bool {
        return self.object.msgSend(bool, "supportsTextureSampleCount:", .{sample_count});
    }

    /// `-[MTLDevice minimumLinearTextureAlignmentForPixelFormat:]`
    pub fn minimumLinearTextureAlignmentForPixelFormat(self: Self, format: PixelFormat) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "minimumLinearTextureAlignmentForPixelFormat:", .{format});
    }

    /// `-[MTLDevice minimumTextureBufferAlignmentForPixelFormat:]`
    pub fn minimumTextureBufferAlignmentForPixelFormat(self: Self, format: PixelFormat) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "minimumTextureBufferAlignmentForPixelFormat:", .{format});
    }

    /// `-[MTLDevice newRenderPipelineStateWithTileDescriptor:options:reflection:error:]`
    pub fn newRenderPipelineStateWithTileDescriptorOptionsReflectionError(self: Self, descriptor: objc.Object, options: PipelineOption, reflection: ?objc.Object, @"error": ?*objc.abi.Id) ?RenderPipelineState {
        return self.object.msgSend(?RenderPipelineState, "newRenderPipelineStateWithTileDescriptor:options:reflection:error:", .{ descriptor, options, reflection, @"error" });
    }

    /// `-[MTLDevice newRenderPipelineStateWithTileDescriptor:options:completionHandler:]`
    pub fn newRenderPipelineStateWithTileDescriptorOptionsCompletionHandler(self: Self, descriptor: objc.Object, options: PipelineOption, completion_handler: ?objc.BlockRef(fn (?RenderPipelineState, ?objc.Object, ?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "newRenderPipelineStateWithTileDescriptor:options:completionHandler:", .{ descriptor, options, completion_handler });
    }

    /// `-[MTLDevice newRenderPipelineStateWithMeshDescriptor:options:reflection:error:]`
    pub fn newRenderPipelineStateWithMeshDescriptorOptionsReflectionError(self: Self, descriptor: objc.Object, options: PipelineOption, reflection: ?objc.Object, @"error": ?*objc.abi.Id) ?RenderPipelineState {
        return self.object.msgSend(?RenderPipelineState, "newRenderPipelineStateWithMeshDescriptor:options:reflection:error:", .{ descriptor, options, reflection, @"error" });
    }

    /// `-[MTLDevice newRenderPipelineStateWithMeshDescriptor:options:completionHandler:]`
    pub fn newRenderPipelineStateWithMeshDescriptorOptionsCompletionHandler(self: Self, descriptor: objc.Object, options: PipelineOption, completion_handler: ?objc.BlockRef(fn (?RenderPipelineState, ?objc.Object, ?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "newRenderPipelineStateWithMeshDescriptor:options:completionHandler:", .{ descriptor, options, completion_handler });
    }

    /// `-[MTLDevice getDefaultSamplePositions:count:]`
    pub fn getDefaultSamplePositionsCount(self: Self, positions: objc.Object, count: objc.UInteger) void {
        return self.object.msgSend(void, "getDefaultSamplePositions:count:", .{ positions, count });
    }

    /// `-[MTLDevice newArgumentEncoderWithArguments:]`
    pub fn newArgumentEncoderWithArguments(self: Self, arguments: foundation.Array(objc.Object)) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newArgumentEncoderWithArguments:", .{arguments});
    }

    /// `-[MTLDevice supportsRasterizationRateMapWithLayerCount:]`
    pub fn supportsRasterizationRateMapWithLayerCount(self: Self, layer_count: objc.UInteger) bool {
        return self.object.msgSend(bool, "supportsRasterizationRateMapWithLayerCount:", .{layer_count});
    }

    /// `-[MTLDevice newRasterizationRateMapWithDescriptor:]`
    pub fn newRasterizationRateMapWithDescriptor(self: Self, descriptor: objc.Object) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newRasterizationRateMapWithDescriptor:", .{descriptor});
    }

    /// `-[MTLDevice newIndirectCommandBufferWithDescriptor:maxCommandCount:options:]`
    pub fn newIndirectCommandBufferWithDescriptorMaxCommandCountOptions(self: Self, descriptor: objc.Object, max_count: objc.UInteger, options: ResourceOptions) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newIndirectCommandBufferWithDescriptor:maxCommandCount:options:", .{ descriptor, max_count, options });
    }

    /// `-[MTLDevice newEvent]`
    pub fn newEvent(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newEvent", .{});
    }

    /// `-[MTLDevice newSharedEvent]`
    pub fn newSharedEvent(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newSharedEvent", .{});
    }

    /// `-[MTLDevice newSharedEventWithHandle:]`
    pub fn newSharedEventWithHandle(self: Self, shared_event_handle: objc.Object) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newSharedEventWithHandle:", .{shared_event_handle});
    }

    /// `-[MTLDevice newIOHandleWithURL:error:]`
    pub fn newIOHandleWithURLError(self: Self, url: foundation.Url, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newIOHandleWithURL:error:", .{ url, @"error" });
    }

    /// `-[MTLDevice newIOCommandQueueWithDescriptor:error:]`
    pub fn newIOCommandQueueWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newIOCommandQueueWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice newIOHandleWithURL:compressionMethod:error:]`
    pub fn newIOHandleWithURLCompressionMethodError(self: Self, url: foundation.Url, compression_method: IOCompressionMethod, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newIOHandleWithURL:compressionMethod:error:", .{ url, compression_method, @"error" });
    }

    /// `-[MTLDevice newIOFileHandleWithURL:error:]`
    pub fn newIOFileHandleWithURLError(self: Self, url: foundation.Url, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newIOFileHandleWithURL:error:", .{ url, @"error" });
    }

    /// `-[MTLDevice newIOFileHandleWithURL:compressionMethod:error:]`
    pub fn newIOFileHandleWithURLCompressionMethodError(self: Self, url: foundation.Url, compression_method: IOCompressionMethod, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newIOFileHandleWithURL:compressionMethod:error:", .{ url, compression_method, @"error" });
    }

    /// `-[MTLDevice sparseTileSizeWithTextureType:pixelFormat:sampleCount:]`
    pub fn sparseTileSizeWithTextureTypePixelFormatSampleCount(self: Self, texture_type: TextureType, pixel_format: PixelFormat, sample_count: objc.UInteger) Size {
        return self.object.msgSend(Size, "sparseTileSizeWithTextureType:pixelFormat:sampleCount:", .{ texture_type, pixel_format, sample_count });
    }

    /// `-[MTLDevice convertSparsePixelRegions:toTileRegions:withTileSize:alignmentMode:numRegions:]`
    pub fn convertSparsePixelRegionsToTileRegionsWithTileSizeAlignmentModeNumRegions(self: Self, pixel_regions: ?[*]const Region, tile_regions: ?*Region, tile_size: Size, mode: SparseTextureRegionAlignmentMode, num_regions: objc.UInteger) void {
        return self.object.msgSend(void, "convertSparsePixelRegions:toTileRegions:withTileSize:alignmentMode:numRegions:", .{ pixel_regions, tile_regions, tile_size, mode, num_regions });
    }

    /// `-[MTLDevice convertSparseTileRegions:toPixelRegions:withTileSize:numRegions:]`
    pub fn convertSparseTileRegionsToPixelRegionsWithTileSizeNumRegions(self: Self, tile_regions: ?[*]const Region, pixel_regions: ?*Region, tile_size: Size, num_regions: objc.UInteger) void {
        return self.object.msgSend(void, "convertSparseTileRegions:toPixelRegions:withTileSize:numRegions:", .{ tile_regions, pixel_regions, tile_size, num_regions });
    }

    /// `-[MTLDevice sparseTileSizeInBytesForSparsePageSize:]`
    pub fn sparseTileSizeInBytesForSparsePageSize(self: Self, sparse_page_size: SparsePageSize) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "sparseTileSizeInBytesForSparsePageSize:", .{sparse_page_size});
    }

    /// `-[MTLDevice sparseTileSizeWithTextureType:pixelFormat:sampleCount:sparsePageSize:]`
    pub fn sparseTileSizeWithTextureTypePixelFormatSampleCountSparsePageSize(self: Self, texture_type: TextureType, pixel_format: PixelFormat, sample_count: objc.UInteger, sparse_page_size: SparsePageSize) Size {
        return self.object.msgSend(Size, "sparseTileSizeWithTextureType:pixelFormat:sampleCount:sparsePageSize:", .{ texture_type, pixel_format, sample_count, sparse_page_size });
    }

    /// `-[MTLDevice newCounterSampleBufferWithDescriptor:error:]`
    pub fn newCounterSampleBufferWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newCounterSampleBufferWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice sampleTimestamps:gpuTimestamp:]`
    pub fn sampleTimestampsGpuTimestamp(self: Self, cpu_timestamp: objc.Object, gpu_timestamp: objc.Object) void {
        return self.object.msgSend(void, "sampleTimestamps:gpuTimestamp:", .{ cpu_timestamp, gpu_timestamp });
    }

    /// `-[MTLDevice newArgumentEncoderWithBufferBinding:]`
    pub fn newArgumentEncoderWithBufferBinding(self: Self, buffer_binding: objc.Object) objc.Object {
        return self.object.msgSend(objc.Object, "newArgumentEncoderWithBufferBinding:", .{buffer_binding});
    }

    /// `-[MTLDevice supportsCounterSampling:]`
    pub fn supportsCounterSampling(self: Self, sampling_point: CounterSamplingPoint) bool {
        return self.object.msgSend(bool, "supportsCounterSampling:", .{sampling_point});
    }

    /// `-[MTLDevice supportsVertexAmplificationCount:]`
    pub fn supportsVertexAmplificationCount(self: Self, count: objc.UInteger) bool {
        return self.object.msgSend(bool, "supportsVertexAmplificationCount:", .{count});
    }

    /// `-[MTLDevice newDynamicLibrary:error:]`
    pub fn newDynamicLibraryError(self: Self, library: Library, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newDynamicLibrary:error:", .{ library, @"error" });
    }

    /// `-[MTLDevice newDynamicLibraryWithURL:error:]`
    pub fn newDynamicLibraryWithURLError(self: Self, url: foundation.Url, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newDynamicLibraryWithURL:error:", .{ url, @"error" });
    }

    /// `-[MTLDevice newBinaryArchiveWithDescriptor:error:]`
    pub fn newBinaryArchiveWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newBinaryArchiveWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice accelerationStructureSizesWithDescriptor:]`
    pub fn accelerationStructureSizesWithDescriptor(self: Self, descriptor: objc.Object) AccelerationStructureSizes {
        return self.object.msgSend(AccelerationStructureSizes, "accelerationStructureSizesWithDescriptor:", .{descriptor});
    }

    /// `-[MTLDevice newAccelerationStructureWithSize:]`
    pub fn newAccelerationStructureWithSize(self: Self, size: objc.UInteger) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newAccelerationStructureWithSize:", .{size});
    }

    /// `-[MTLDevice newAccelerationStructureWithDescriptor:]`
    pub fn newAccelerationStructureWithDescriptor(self: Self, descriptor: objc.Object) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newAccelerationStructureWithDescriptor:", .{descriptor});
    }

    /// `-[MTLDevice heapAccelerationStructureSizeAndAlignWithSize:]`
    pub fn heapAccelerationStructureSizeAndAlignWithSize(self: Self, size: objc.UInteger) SizeAndAlign {
        return self.object.msgSend(SizeAndAlign, "heapAccelerationStructureSizeAndAlignWithSize:", .{size});
    }

    /// `-[MTLDevice heapAccelerationStructureSizeAndAlignWithDescriptor:]`
    pub fn heapAccelerationStructureSizeAndAlignWithDescriptor(self: Self, descriptor: objc.Object) SizeAndAlign {
        return self.object.msgSend(SizeAndAlign, "heapAccelerationStructureSizeAndAlignWithDescriptor:", .{descriptor});
    }

    /// `-[MTLDevice newResidencySetWithDescriptor:error:]`
    pub fn newResidencySetWithDescriptorError(self: Self, desc: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newResidencySetWithDescriptor:error:", .{ desc, @"error" });
    }

    /// `-[MTLDevice tensorSizeAndAlignWithDescriptor:]`
    pub fn tensorSizeAndAlignWithDescriptor(self: Self, descriptor: objc.Object) SizeAndAlign {
        return self.object.msgSend(SizeAndAlign, "tensorSizeAndAlignWithDescriptor:", .{descriptor});
    }

    /// `-[MTLDevice newTensorWithDescriptor:error:]`
    pub fn newTensorWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newTensorWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice newTensorWithDescriptor:attachments:error:]`
    pub fn newTensorWithDescriptorAttachmentsError(self: Self, descriptor: objc.Object, attachments: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newTensorWithDescriptor:attachments:error:", .{ descriptor, attachments, @"error" });
    }

    /// `-[MTLDevice functionHandleWithFunction:]`
    pub fn functionHandleWithFunction(self: Self, function: Function) ?objc.Object {
        return self.object.msgSend(?objc.Object, "functionHandleWithFunction:", .{function});
    }

    /// `-[MTLDevice newCommandAllocator]`
    pub fn newCommandAllocator(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newCommandAllocator", .{});
    }

    /// `-[MTLDevice newCommandAllocatorWithDescriptor:error:]`
    pub fn newCommandAllocatorWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newCommandAllocatorWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice newMTL4CommandQueue]`
    pub fn newMTL4CommandQueue(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newMTL4CommandQueue", .{});
    }

    /// `-[MTLDevice newMTL4CommandQueueWithDescriptor:error:]`
    pub fn newMTL4CommandQueueWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newMTL4CommandQueueWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice newCommandBuffer]`
    pub fn newCommandBuffer(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newCommandBuffer", .{});
    }

    /// `-[MTLDevice newArgumentTableWithDescriptor:error:]`
    pub fn newArgumentTableWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newArgumentTableWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice newTextureViewPoolWithDescriptor:error:]`
    pub fn newTextureViewPoolWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newTextureViewPoolWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice newCompilerWithDescriptor:error:]`
    pub fn newCompilerWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newCompilerWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice newArchiveWithURL:error:]`
    pub fn newArchiveWithURLError(self: Self, url: foundation.Url, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newArchiveWithURL:error:", .{ url, @"error" });
    }

    /// `-[MTLDevice newPipelineDataSetSerializerWithDescriptor:]`
    pub fn newPipelineDataSetSerializerWithDescriptor(self: Self, descriptor: objc.Object) objc.Object {
        return self.object.msgSend(objc.Object, "newPipelineDataSetSerializerWithDescriptor:", .{descriptor});
    }

    /// `-[MTLDevice newBufferWithLength:options:placementSparsePageSize:]`
    pub fn newBufferWithLengthOptionsPlacementSparsePageSize(self: Self, length: objc.UInteger, options: ResourceOptions, placement_sparse_page_size: SparsePageSize) ?Buffer {
        return self.object.msgSend(?Buffer, "newBufferWithLength:options:placementSparsePageSize:", .{ length, options, placement_sparse_page_size });
    }

    /// `-[MTLDevice newCounterHeapWithDescriptor:error:]`
    pub fn newCounterHeapWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newCounterHeapWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLDevice sizeOfCounterHeapEntry:]`
    pub fn sizeOfCounterHeapEntry(self: Self, @"type": MTL4CounterHeapType) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "sizeOfCounterHeapEntry:", .{@"type"});
    }

    /// `-[MTLDevice queryTimestampFrequency]`
    pub fn queryTimestampFrequency(self: Self) u64 {
        return self.object.msgSend(u64, "queryTimestampFrequency", .{});
    }

    /// `-[MTLDevice functionHandleWithBinaryFunction:]`
    pub fn functionHandleWithBinaryFunction(self: Self, function: objc.Object) ?objc.Object {
        return self.object.msgSend(?objc.Object, "functionHandleWithBinaryFunction:", .{function});
    }

    /// `-[MTLDevice name]`
    pub fn name(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "name", .{});
    }

    /// `-[MTLDevice registryID]`
    pub fn registryID(self: Self) u64 {
        return self.object.msgSend(u64, "registryID", .{});
    }

    /// `-[MTLDevice architecture]`
    pub fn architecture(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "architecture", .{});
    }

    /// `-[MTLDevice maxThreadsPerThreadgroup]`
    pub fn maxThreadsPerThreadgroup(self: Self) Size {
        return self.object.msgSend(Size, "maxThreadsPerThreadgroup", .{});
    }

    /// `-[MTLDevice isLowPower]`
    pub fn isLowPower(self: Self) bool {
        return self.object.msgSend(bool, "isLowPower", .{});
    }

    /// `-[MTLDevice isHeadless]`
    pub fn isHeadless(self: Self) bool {
        return self.object.msgSend(bool, "isHeadless", .{});
    }

    /// `-[MTLDevice isRemovable]`
    pub fn isRemovable(self: Self) bool {
        return self.object.msgSend(bool, "isRemovable", .{});
    }

    /// `-[MTLDevice hasUnifiedMemory]`
    pub fn hasUnifiedMemory(self: Self) bool {
        return self.object.msgSend(bool, "hasUnifiedMemory", .{});
    }

    /// `-[MTLDevice recommendedMaxWorkingSetSize]`
    pub fn recommendedMaxWorkingSetSize(self: Self) u64 {
        return self.object.msgSend(u64, "recommendedMaxWorkingSetSize", .{});
    }

    /// `-[MTLDevice location]`
    pub fn location(self: Self) DeviceLocation {
        return self.object.msgSend(DeviceLocation, "location", .{});
    }

    /// `-[MTLDevice locationNumber]`
    pub fn locationNumber(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "locationNumber", .{});
    }

    /// `-[MTLDevice maxTransferRate]`
    pub fn maxTransferRate(self: Self) u64 {
        return self.object.msgSend(u64, "maxTransferRate", .{});
    }

    /// `-[MTLDevice isDepth24Stencil8PixelFormatSupported]`
    pub fn isDepth24Stencil8PixelFormatSupported(self: Self) bool {
        return self.object.msgSend(bool, "isDepth24Stencil8PixelFormatSupported", .{});
    }

    /// `-[MTLDevice readWriteTextureSupport]`
    pub fn readWriteTextureSupport(self: Self) ReadWriteTextureTier {
        return self.object.msgSend(ReadWriteTextureTier, "readWriteTextureSupport", .{});
    }

    /// `-[MTLDevice argumentBuffersSupport]`
    pub fn argumentBuffersSupport(self: Self) ArgumentBuffersTier {
        return self.object.msgSend(ArgumentBuffersTier, "argumentBuffersSupport", .{});
    }

    /// `-[MTLDevice areRasterOrderGroupsSupported]`
    pub fn areRasterOrderGroupsSupported(self: Self) bool {
        return self.object.msgSend(bool, "areRasterOrderGroupsSupported", .{});
    }

    /// `-[MTLDevice supports32BitFloatFiltering]`
    pub fn supports32BitFloatFiltering(self: Self) bool {
        return self.object.msgSend(bool, "supports32BitFloatFiltering", .{});
    }

    /// `-[MTLDevice supports32BitMSAA]`
    pub fn supports32BitMSAA(self: Self) bool {
        return self.object.msgSend(bool, "supports32BitMSAA", .{});
    }

    /// `-[MTLDevice supportsQueryTextureLOD]`
    pub fn supportsQueryTextureLOD(self: Self) bool {
        return self.object.msgSend(bool, "supportsQueryTextureLOD", .{});
    }

    /// `-[MTLDevice supportsBCTextureCompression]`
    pub fn supportsBCTextureCompression(self: Self) bool {
        return self.object.msgSend(bool, "supportsBCTextureCompression", .{});
    }

    /// `-[MTLDevice supportsPullModelInterpolation]`
    pub fn supportsPullModelInterpolation(self: Self) bool {
        return self.object.msgSend(bool, "supportsPullModelInterpolation", .{});
    }

    /// `-[MTLDevice areBarycentricCoordsSupported]`
    pub fn areBarycentricCoordsSupported(self: Self) bool {
        return self.object.msgSend(bool, "areBarycentricCoordsSupported", .{});
    }

    /// `-[MTLDevice supportsShaderBarycentricCoordinates]`
    pub fn supportsShaderBarycentricCoordinates(self: Self) bool {
        return self.object.msgSend(bool, "supportsShaderBarycentricCoordinates", .{});
    }

    /// `-[MTLDevice currentAllocatedSize]`
    pub fn currentAllocatedSize(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "currentAllocatedSize", .{});
    }

    /// `-[MTLDevice maxThreadgroupMemoryLength]`
    pub fn maxThreadgroupMemoryLength(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxThreadgroupMemoryLength", .{});
    }

    /// `-[MTLDevice maxArgumentBufferSamplerCount]`
    pub fn maxArgumentBufferSamplerCount(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxArgumentBufferSamplerCount", .{});
    }

    /// `-[MTLDevice areProgrammableSamplePositionsSupported]`
    pub fn areProgrammableSamplePositionsSupported(self: Self) bool {
        return self.object.msgSend(bool, "areProgrammableSamplePositionsSupported", .{});
    }

    /// `-[MTLDevice peerGroupID]`
    pub fn peerGroupID(self: Self) u64 {
        return self.object.msgSend(u64, "peerGroupID", .{});
    }

    /// `-[MTLDevice peerIndex]`
    pub fn peerIndex(self: Self) u32 {
        return self.object.msgSend(u32, "peerIndex", .{});
    }

    /// `-[MTLDevice peerCount]`
    pub fn peerCount(self: Self) u32 {
        return self.object.msgSend(u32, "peerCount", .{});
    }

    /// `-[MTLDevice sparseTileSizeInBytes]`
    pub fn sparseTileSizeInBytes(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "sparseTileSizeInBytes", .{});
    }

    /// `-[MTLDevice maxBufferLength]`
    pub fn maxBufferLength(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxBufferLength", .{});
    }

    /// `-[MTLDevice counterSets]`
    pub fn counterSets(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "counterSets", .{});
    }

    /// `-[MTLDevice supportsDynamicLibraries]`
    pub fn supportsDynamicLibraries(self: Self) bool {
        return self.object.msgSend(bool, "supportsDynamicLibraries", .{});
    }

    /// `-[MTLDevice supportsRenderDynamicLibraries]`
    pub fn supportsRenderDynamicLibraries(self: Self) bool {
        return self.object.msgSend(bool, "supportsRenderDynamicLibraries", .{});
    }

    /// `-[MTLDevice supportsPlacementSparse]`
    pub fn supportsPlacementSparse(self: Self) bool {
        return self.object.msgSend(bool, "supportsPlacementSparse", .{});
    }

    /// `-[MTLDevice supportsRaytracing]`
    pub fn supportsRaytracing(self: Self) bool {
        return self.object.msgSend(bool, "supportsRaytracing", .{});
    }

    /// `-[MTLDevice supportsFunctionPointers]`
    pub fn supportsFunctionPointers(self: Self) bool {
        return self.object.msgSend(bool, "supportsFunctionPointers", .{});
    }

    /// `-[MTLDevice supportsFunctionPointersFromRender]`
    pub fn supportsFunctionPointersFromRender(self: Self) bool {
        return self.object.msgSend(bool, "supportsFunctionPointersFromRender", .{});
    }

    /// `-[MTLDevice supportsRaytracingFromRender]`
    pub fn supportsRaytracingFromRender(self: Self) bool {
        return self.object.msgSend(bool, "supportsRaytracingFromRender", .{});
    }

    /// `-[MTLDevice supportsPrimitiveMotionBlur]`
    pub fn supportsPrimitiveMotionBlur(self: Self) bool {
        return self.object.msgSend(bool, "supportsPrimitiveMotionBlur", .{});
    }

    /// `-[MTLDevice shouldMaximizeConcurrentCompilation]`
    pub fn shouldMaximizeConcurrentCompilation(self: Self) bool {
        return self.object.msgSend(bool, "shouldMaximizeConcurrentCompilation", .{});
    }

    /// `-[MTLDevice setShouldMaximizeConcurrentCompilation:]`
    pub fn setShouldMaximizeConcurrentCompilation(self: Self, should_maximize_concurrent_compilation: bool) void {
        return self.object.msgSend(void, "setShouldMaximizeConcurrentCompilation:", .{should_maximize_concurrent_compilation});
    }

    /// `-[MTLDevice maximumConcurrentCompilationTaskCount]`
    pub fn maximumConcurrentCompilationTaskCount(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maximumConcurrentCompilationTaskCount", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-newLogStateWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newCommandQueue" = fn () ?CommandQueue;
        pub const @"-newCommandQueueWithMaxCommandBufferCount:" = fn (objc.UInteger) ?CommandQueue;
        pub const @"-newCommandQueueWithDescriptor:" = fn (objc.Object) ?CommandQueue;
        pub const @"-heapTextureSizeAndAlignWithDescriptor:" = fn (TextureDescriptor) SizeAndAlign;
        pub const @"-heapBufferSizeAndAlignWithLength:options:" = fn (objc.UInteger, ResourceOptions) SizeAndAlign;
        pub const @"-newHeapWithDescriptor:" = fn (objc.Object) ?objc.Object;
        pub const @"-newBufferWithLength:options:" = fn (objc.UInteger, ResourceOptions) ?Buffer;
        pub const @"-newBufferWithBytes:length:options:" = fn (?*const anyopaque, objc.UInteger, ResourceOptions) ?Buffer;
        pub const @"-newBufferWithBytesNoCopy:length:options:deallocator:" = fn (?*anyopaque, objc.UInteger, ResourceOptions, ?objc.BlockRef(fn (?*anyopaque, objc.UInteger) void)) ?Buffer;
        pub const @"-newDepthStencilStateWithDescriptor:" = fn (DepthStencilDescriptor) ?DepthStencilState;
        pub const @"-newTextureWithDescriptor:" = fn (TextureDescriptor) ?Texture;
        pub const @"-newTextureWithDescriptor:iosurface:plane:" = fn (TextureDescriptor, io_surface.Surface, objc.UInteger) ?Texture;
        pub const @"-newSharedTextureWithDescriptor:" = fn (TextureDescriptor) ?Texture;
        pub const @"-newSharedTextureWithHandle:" = fn (objc.Object) ?Texture;
        pub const @"-newSamplerStateWithDescriptor:" = fn (SamplerDescriptor) ?SamplerState;
        pub const @"-newDefaultLibrary" = fn () ?Library;
        pub const @"-newDefaultLibraryWithBundle:error:" = fn (objc.Object, ?*objc.abi.Id) ?Library;
        pub const @"-newLibraryWithFile:error:" = fn (foundation.String, ?*objc.abi.Id) ?Library;
        pub const @"-newLibraryWithURL:error:" = fn (foundation.Url, ?*objc.abi.Id) ?Library;
        pub const @"-newLibraryWithData:error:" = fn (?objc.Object, ?*objc.abi.Id) ?Library;
        pub const @"-newLibraryWithSource:options:error:" = fn (foundation.String, ?CompileOptions, ?*objc.abi.Id) ?Library;
        pub const @"-newLibraryWithSource:options:completionHandler:" = fn (foundation.String, ?CompileOptions, ?objc.BlockRef(fn (?Library, ?foundation.ErrorObject) void)) void;
        pub const @"-newLibraryWithStitchedDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?Library;
        pub const @"-newLibraryWithStitchedDescriptor:completionHandler:" = fn (objc.Object, ?objc.BlockRef(fn (?Library, ?foundation.ErrorObject) void)) void;
        pub const @"-newRenderPipelineStateWithDescriptor:error:" = fn (RenderPipelineDescriptor, ?*objc.abi.Id) ?RenderPipelineState;
        pub const @"-newRenderPipelineStateWithDescriptor:options:reflection:error:" = fn (RenderPipelineDescriptor, PipelineOption, ?objc.Object, ?*objc.abi.Id) ?RenderPipelineState;
        pub const @"-newRenderPipelineStateWithDescriptor:completionHandler:" = fn (RenderPipelineDescriptor, ?objc.BlockRef(fn (?RenderPipelineState, ?foundation.ErrorObject) void)) void;
        pub const @"-newRenderPipelineStateWithDescriptor:options:completionHandler:" = fn (RenderPipelineDescriptor, PipelineOption, ?objc.BlockRef(fn (?RenderPipelineState, ?objc.Object, ?foundation.ErrorObject) void)) void;
        pub const @"-newComputePipelineStateWithFunction:error:" = fn (Function, ?*objc.abi.Id) ?ComputePipelineState;
        pub const @"-newComputePipelineStateWithFunction:options:reflection:error:" = fn (Function, PipelineOption, ?objc.Object, ?*objc.abi.Id) ?ComputePipelineState;
        pub const @"-newComputePipelineStateWithFunction:completionHandler:" = fn (Function, ?objc.BlockRef(fn (?ComputePipelineState, ?foundation.ErrorObject) void)) void;
        pub const @"-newComputePipelineStateWithFunction:options:completionHandler:" = fn (Function, PipelineOption, ?objc.BlockRef(fn (?ComputePipelineState, ?objc.Object, ?foundation.ErrorObject) void)) void;
        pub const @"-newComputePipelineStateWithDescriptor:options:reflection:error:" = fn (ComputePipelineDescriptor, PipelineOption, ?objc.Object, ?*objc.abi.Id) ?ComputePipelineState;
        pub const @"-newComputePipelineStateWithDescriptor:options:completionHandler:" = fn (ComputePipelineDescriptor, PipelineOption, ?objc.BlockRef(fn (?ComputePipelineState, ?objc.Object, ?foundation.ErrorObject) void)) void;
        pub const @"-newFence" = fn () ?objc.Object;
        pub const @"-supportsFeatureSet:" = fn (FeatureSet) bool;
        pub const @"-supportsFamily:" = fn (GPUFamily) bool;
        pub const @"-supportsTextureSampleCount:" = fn (objc.UInteger) bool;
        pub const @"-minimumLinearTextureAlignmentForPixelFormat:" = fn (PixelFormat) objc.UInteger;
        pub const @"-minimumTextureBufferAlignmentForPixelFormat:" = fn (PixelFormat) objc.UInteger;
        pub const @"-newRenderPipelineStateWithTileDescriptor:options:reflection:error:" = fn (objc.Object, PipelineOption, ?objc.Object, ?*objc.abi.Id) ?RenderPipelineState;
        pub const @"-newRenderPipelineStateWithTileDescriptor:options:completionHandler:" = fn (objc.Object, PipelineOption, ?objc.BlockRef(fn (?RenderPipelineState, ?objc.Object, ?foundation.ErrorObject) void)) void;
        pub const @"-newRenderPipelineStateWithMeshDescriptor:options:reflection:error:" = fn (objc.Object, PipelineOption, ?objc.Object, ?*objc.abi.Id) ?RenderPipelineState;
        pub const @"-newRenderPipelineStateWithMeshDescriptor:options:completionHandler:" = fn (objc.Object, PipelineOption, ?objc.BlockRef(fn (?RenderPipelineState, ?objc.Object, ?foundation.ErrorObject) void)) void;
        pub const @"-getDefaultSamplePositions:count:" = fn (objc.Object, objc.UInteger) void;
        pub const @"-newArgumentEncoderWithArguments:" = fn (foundation.Array(objc.Object)) ?objc.Object;
        pub const @"-supportsRasterizationRateMapWithLayerCount:" = fn (objc.UInteger) bool;
        pub const @"-newRasterizationRateMapWithDescriptor:" = fn (objc.Object) ?objc.Object;
        pub const @"-newIndirectCommandBufferWithDescriptor:maxCommandCount:options:" = fn (objc.Object, objc.UInteger, ResourceOptions) ?objc.Object;
        pub const @"-newEvent" = fn () ?objc.Object;
        pub const @"-newSharedEvent" = fn () ?objc.Object;
        pub const @"-newSharedEventWithHandle:" = fn (objc.Object) ?objc.Object;
        pub const @"-newIOHandleWithURL:error:" = fn (foundation.Url, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newIOCommandQueueWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newIOHandleWithURL:compressionMethod:error:" = fn (foundation.Url, IOCompressionMethod, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newIOFileHandleWithURL:error:" = fn (foundation.Url, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newIOFileHandleWithURL:compressionMethod:error:" = fn (foundation.Url, IOCompressionMethod, ?*objc.abi.Id) ?objc.Object;
        pub const @"-sparseTileSizeWithTextureType:pixelFormat:sampleCount:" = fn (TextureType, PixelFormat, objc.UInteger) Size;
        pub const @"-convertSparsePixelRegions:toTileRegions:withTileSize:alignmentMode:numRegions:" = fn (?[*]const Region, ?*Region, Size, SparseTextureRegionAlignmentMode, objc.UInteger) void;
        pub const @"-convertSparseTileRegions:toPixelRegions:withTileSize:numRegions:" = fn (?[*]const Region, ?*Region, Size, objc.UInteger) void;
        pub const @"-sparseTileSizeInBytesForSparsePageSize:" = fn (SparsePageSize) objc.UInteger;
        pub const @"-sparseTileSizeWithTextureType:pixelFormat:sampleCount:sparsePageSize:" = fn (TextureType, PixelFormat, objc.UInteger, SparsePageSize) Size;
        pub const @"-newCounterSampleBufferWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-sampleTimestamps:gpuTimestamp:" = fn (objc.Object, objc.Object) void;
        pub const @"-newArgumentEncoderWithBufferBinding:" = fn (objc.Object) objc.Object;
        pub const @"-supportsCounterSampling:" = fn (CounterSamplingPoint) bool;
        pub const @"-supportsVertexAmplificationCount:" = fn (objc.UInteger) bool;
        pub const @"-newDynamicLibrary:error:" = fn (Library, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newDynamicLibraryWithURL:error:" = fn (foundation.Url, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newBinaryArchiveWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-accelerationStructureSizesWithDescriptor:" = fn (objc.Object) AccelerationStructureSizes;
        pub const @"-newAccelerationStructureWithSize:" = fn (objc.UInteger) ?objc.Object;
        pub const @"-newAccelerationStructureWithDescriptor:" = fn (objc.Object) ?objc.Object;
        pub const @"-heapAccelerationStructureSizeAndAlignWithSize:" = fn (objc.UInteger) SizeAndAlign;
        pub const @"-heapAccelerationStructureSizeAndAlignWithDescriptor:" = fn (objc.Object) SizeAndAlign;
        pub const @"-newResidencySetWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-tensorSizeAndAlignWithDescriptor:" = fn (objc.Object) SizeAndAlign;
        pub const @"-newTensorWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newTensorWithDescriptor:attachments:error:" = fn (objc.Object, objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-functionHandleWithFunction:" = fn (Function) ?objc.Object;
        pub const @"-newCommandAllocator" = fn () ?objc.Object;
        pub const @"-newCommandAllocatorWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newMTL4CommandQueue" = fn () ?objc.Object;
        pub const @"-newMTL4CommandQueueWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newCommandBuffer" = fn () ?objc.Object;
        pub const @"-newArgumentTableWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newTextureViewPoolWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newCompilerWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newArchiveWithURL:error:" = fn (foundation.Url, ?*objc.abi.Id) ?objc.Object;
        pub const @"-newPipelineDataSetSerializerWithDescriptor:" = fn (objc.Object) objc.Object;
        pub const @"-newBufferWithLength:options:placementSparsePageSize:" = fn (objc.UInteger, ResourceOptions, SparsePageSize) ?Buffer;
        pub const @"-newCounterHeapWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?objc.Object;
        pub const @"-sizeOfCounterHeapEntry:" = fn (MTL4CounterHeapType) objc.UInteger;
        pub const @"-queryTimestampFrequency" = fn () u64;
        pub const @"-functionHandleWithBinaryFunction:" = fn (objc.Object) ?objc.Object;
        pub const @"-name" = fn () foundation.String;
        pub const @"-registryID" = fn () u64;
        pub const @"-architecture" = fn () objc.Object;
        pub const @"-maxThreadsPerThreadgroup" = fn () Size;
        pub const @"-isLowPower" = fn () bool;
        pub const @"-isHeadless" = fn () bool;
        pub const @"-isRemovable" = fn () bool;
        pub const @"-hasUnifiedMemory" = fn () bool;
        pub const @"-recommendedMaxWorkingSetSize" = fn () u64;
        pub const @"-location" = fn () DeviceLocation;
        pub const @"-locationNumber" = fn () objc.UInteger;
        pub const @"-maxTransferRate" = fn () u64;
        pub const @"-isDepth24Stencil8PixelFormatSupported" = fn () bool;
        pub const @"-readWriteTextureSupport" = fn () ReadWriteTextureTier;
        pub const @"-argumentBuffersSupport" = fn () ArgumentBuffersTier;
        pub const @"-areRasterOrderGroupsSupported" = fn () bool;
        pub const @"-supports32BitFloatFiltering" = fn () bool;
        pub const @"-supports32BitMSAA" = fn () bool;
        pub const @"-supportsQueryTextureLOD" = fn () bool;
        pub const @"-supportsBCTextureCompression" = fn () bool;
        pub const @"-supportsPullModelInterpolation" = fn () bool;
        pub const @"-areBarycentricCoordsSupported" = fn () bool;
        pub const @"-supportsShaderBarycentricCoordinates" = fn () bool;
        pub const @"-currentAllocatedSize" = fn () objc.UInteger;
        pub const @"-maxThreadgroupMemoryLength" = fn () objc.UInteger;
        pub const @"-maxArgumentBufferSamplerCount" = fn () objc.UInteger;
        pub const @"-areProgrammableSamplePositionsSupported" = fn () bool;
        pub const @"-peerGroupID" = fn () u64;
        pub const @"-peerIndex" = fn () u32;
        pub const @"-peerCount" = fn () u32;
        pub const @"-sparseTileSizeInBytes" = fn () objc.UInteger;
        pub const @"-maxBufferLength" = fn () objc.UInteger;
        pub const @"-counterSets" = fn () ?foundation.Array(objc.Object);
        pub const @"-supportsDynamicLibraries" = fn () bool;
        pub const @"-supportsRenderDynamicLibraries" = fn () bool;
        pub const @"-supportsPlacementSparse" = fn () bool;
        pub const @"-supportsRaytracing" = fn () bool;
        pub const @"-supportsFunctionPointers" = fn () bool;
        pub const @"-supportsFunctionPointersFromRender" = fn () bool;
        pub const @"-supportsRaytracingFromRender" = fn () bool;
        pub const @"-supportsPrimitiveMotionBlur" = fn () bool;
        pub const @"-shouldMaximizeConcurrentCompilation" = fn () bool;
        pub const @"-setShouldMaximizeConcurrentCompilation:" = fn (bool) void;
        pub const @"-maximumConcurrentCompilationTaskCount" = fn () objc.UInteger;
    };
};

/// An object conforming to `MTLCommandQueue`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const CommandQueue = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "MTLCommandQueue";

    /// An object that came from elsewhere, taken to conform to `MTLCommandQueue`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLCommandQueue commandBuffer]`
    pub fn commandBuffer(self: Self) ?CommandBuffer {
        return self.object.msgSend(?CommandBuffer, "commandBuffer", .{});
    }

    /// `-[MTLCommandQueue commandBufferWithDescriptor:]`
    pub fn commandBufferWithDescriptor(self: Self, descriptor: objc.Object) ?CommandBuffer {
        return self.object.msgSend(?CommandBuffer, "commandBufferWithDescriptor:", .{descriptor});
    }

    /// `-[MTLCommandQueue commandBufferWithUnretainedReferences]`
    pub fn commandBufferWithUnretainedReferences(self: Self) ?CommandBuffer {
        return self.object.msgSend(?CommandBuffer, "commandBufferWithUnretainedReferences", .{});
    }

    /// `-[MTLCommandQueue insertDebugCaptureBoundary]`
    pub fn insertDebugCaptureBoundary(self: Self) void {
        return self.object.msgSend(void, "insertDebugCaptureBoundary", .{});
    }

    /// `-[MTLCommandQueue addResidencySet:]`
    pub fn addResidencySet(self: Self, residency_set: objc.Object) void {
        return self.object.msgSend(void, "addResidencySet:", .{residency_set});
    }

    /// `-[MTLCommandQueue addResidencySets:count:]`
    pub fn addResidencySetsCount(self: Self, residency_sets: [*]const objc.Object, count: objc.UInteger) void {
        return self.object.msgSend(void, "addResidencySets:count:", .{ residency_sets, count });
    }

    /// `-[MTLCommandQueue removeResidencySet:]`
    pub fn removeResidencySet(self: Self, residency_set: objc.Object) void {
        return self.object.msgSend(void, "removeResidencySet:", .{residency_set});
    }

    /// `-[MTLCommandQueue removeResidencySets:count:]`
    pub fn removeResidencySetsCount(self: Self, residency_sets: [*]const objc.Object, count: objc.UInteger) void {
        return self.object.msgSend(void, "removeResidencySets:count:", .{ residency_sets, count });
    }

    /// `-[MTLCommandQueue label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLCommandQueue setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// `-[MTLCommandQueue device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-commandBuffer" = fn () ?CommandBuffer;
        pub const @"-commandBufferWithDescriptor:" = fn (objc.Object) ?CommandBuffer;
        pub const @"-commandBufferWithUnretainedReferences" = fn () ?CommandBuffer;
        pub const @"-insertDebugCaptureBoundary" = fn () void;
        pub const @"-addResidencySet:" = fn (objc.Object) void;
        pub const @"-addResidencySets:count:" = fn ([*]const objc.Object, objc.UInteger) void;
        pub const @"-removeResidencySet:" = fn (objc.Object) void;
        pub const @"-removeResidencySets:count:" = fn ([*]const objc.Object, objc.UInteger) void;
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-setLabel:" = fn (?foundation.String) void;
        pub const @"-device" = fn () Device;
    };
};

/// An object conforming to `MTLCommandBuffer`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const CommandBuffer = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "MTLCommandBuffer";

    /// An object that came from elsewhere, taken to conform to `MTLCommandBuffer`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLCommandBuffer enqueue]`
    pub fn enqueue(self: Self) void {
        return self.object.msgSend(void, "enqueue", .{});
    }

    /// `-[MTLCommandBuffer commit]`
    pub fn commit(self: Self) void {
        return self.object.msgSend(void, "commit", .{});
    }

    /// `-[MTLCommandBuffer addScheduledHandler:]`
    pub fn addScheduledHandler(self: Self, block: ?objc.BlockRef(fn (CommandBuffer) void)) void {
        return self.object.msgSend(void, "addScheduledHandler:", .{block});
    }

    /// `-[MTLCommandBuffer presentDrawable:]`
    pub fn presentDrawable(self: Self, drawable: Drawable) void {
        return self.object.msgSend(void, "presentDrawable:", .{drawable});
    }

    /// `-[MTLCommandBuffer presentDrawable:atTime:]`
    pub fn presentDrawableAtTime(self: Self, drawable: Drawable, presentation_time: f64) void {
        return self.object.msgSend(void, "presentDrawable:atTime:", .{ drawable, presentation_time });
    }

    /// `-[MTLCommandBuffer presentDrawable:afterMinimumDuration:]`
    pub fn presentDrawableAfterMinimumDuration(self: Self, drawable: Drawable, duration: f64) void {
        return self.object.msgSend(void, "presentDrawable:afterMinimumDuration:", .{ drawable, duration });
    }

    /// `-[MTLCommandBuffer waitUntilScheduled]`
    pub fn waitUntilScheduled(self: Self) void {
        return self.object.msgSend(void, "waitUntilScheduled", .{});
    }

    /// `-[MTLCommandBuffer addCompletedHandler:]`
    pub fn addCompletedHandler(self: Self, block: ?objc.BlockRef(fn (CommandBuffer) void)) void {
        return self.object.msgSend(void, "addCompletedHandler:", .{block});
    }

    /// `-[MTLCommandBuffer waitUntilCompleted]`
    pub fn waitUntilCompleted(self: Self) void {
        return self.object.msgSend(void, "waitUntilCompleted", .{});
    }

    /// `-[MTLCommandBuffer blitCommandEncoder]`
    pub fn blitCommandEncoder(self: Self) ?BlitCommandEncoder {
        return self.object.msgSend(?BlitCommandEncoder, "blitCommandEncoder", .{});
    }

    /// `-[MTLCommandBuffer renderCommandEncoderWithDescriptor:]`
    pub fn renderCommandEncoderWithDescriptor(self: Self, render_pass_descriptor: RenderPassDescriptor) ?RenderCommandEncoder {
        return self.object.msgSend(?RenderCommandEncoder, "renderCommandEncoderWithDescriptor:", .{render_pass_descriptor});
    }

    /// `-[MTLCommandBuffer computeCommandEncoderWithDescriptor:]`
    pub fn computeCommandEncoderWithDescriptor(self: Self, compute_pass_descriptor: objc.Object) ?ComputeCommandEncoder {
        return self.object.msgSend(?ComputeCommandEncoder, "computeCommandEncoderWithDescriptor:", .{compute_pass_descriptor});
    }

    /// `-[MTLCommandBuffer blitCommandEncoderWithDescriptor:]`
    pub fn blitCommandEncoderWithDescriptor(self: Self, blit_pass_descriptor: objc.Object) ?BlitCommandEncoder {
        return self.object.msgSend(?BlitCommandEncoder, "blitCommandEncoderWithDescriptor:", .{blit_pass_descriptor});
    }

    /// `-[MTLCommandBuffer computeCommandEncoder]`
    pub fn computeCommandEncoder(self: Self) ?ComputeCommandEncoder {
        return self.object.msgSend(?ComputeCommandEncoder, "computeCommandEncoder", .{});
    }

    /// `-[MTLCommandBuffer computeCommandEncoderWithDispatchType:]`
    pub fn computeCommandEncoderWithDispatchType(self: Self, dispatch_type: DispatchType) ?ComputeCommandEncoder {
        return self.object.msgSend(?ComputeCommandEncoder, "computeCommandEncoderWithDispatchType:", .{dispatch_type});
    }

    /// `-[MTLCommandBuffer encodeWaitForEvent:value:]`
    pub fn encodeWaitForEventValue(self: Self, event: objc.Object, value: u64) void {
        return self.object.msgSend(void, "encodeWaitForEvent:value:", .{ event, value });
    }

    /// `-[MTLCommandBuffer encodeSignalEvent:value:]`
    pub fn encodeSignalEventValue(self: Self, event: objc.Object, value: u64) void {
        return self.object.msgSend(void, "encodeSignalEvent:value:", .{ event, value });
    }

    /// `-[MTLCommandBuffer parallelRenderCommandEncoderWithDescriptor:]`
    pub fn parallelRenderCommandEncoderWithDescriptor(self: Self, render_pass_descriptor: RenderPassDescriptor) ?objc.Object {
        return self.object.msgSend(?objc.Object, "parallelRenderCommandEncoderWithDescriptor:", .{render_pass_descriptor});
    }

    /// `-[MTLCommandBuffer resourceStateCommandEncoder]`
    pub fn resourceStateCommandEncoder(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "resourceStateCommandEncoder", .{});
    }

    /// `-[MTLCommandBuffer resourceStateCommandEncoderWithDescriptor:]`
    pub fn resourceStateCommandEncoderWithDescriptor(self: Self, resource_state_pass_descriptor: objc.Object) ?objc.Object {
        return self.object.msgSend(?objc.Object, "resourceStateCommandEncoderWithDescriptor:", .{resource_state_pass_descriptor});
    }

    /// `-[MTLCommandBuffer accelerationStructureCommandEncoder]`
    pub fn accelerationStructureCommandEncoder(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "accelerationStructureCommandEncoder", .{});
    }

    /// `-[MTLCommandBuffer accelerationStructureCommandEncoderWithDescriptor:]`
    pub fn accelerationStructureCommandEncoderWithDescriptor(self: Self, descriptor: objc.Object) objc.Object {
        return self.object.msgSend(objc.Object, "accelerationStructureCommandEncoderWithDescriptor:", .{descriptor});
    }

    /// `-[MTLCommandBuffer pushDebugGroup:]`
    pub fn pushDebugGroup(self: Self, string: foundation.String) void {
        return self.object.msgSend(void, "pushDebugGroup:", .{string});
    }

    /// `-[MTLCommandBuffer popDebugGroup]`
    pub fn popDebugGroup(self: Self) void {
        return self.object.msgSend(void, "popDebugGroup", .{});
    }

    /// `-[MTLCommandBuffer useResidencySet:]`
    pub fn useResidencySet(self: Self, residency_set: objc.Object) void {
        return self.object.msgSend(void, "useResidencySet:", .{residency_set});
    }

    /// `-[MTLCommandBuffer useResidencySets:count:]`
    pub fn useResidencySetsCount(self: Self, residency_sets: [*]const objc.Object, count: objc.UInteger) void {
        return self.object.msgSend(void, "useResidencySets:count:", .{ residency_sets, count });
    }

    /// `-[MTLCommandBuffer device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLCommandBuffer commandQueue]`
    pub fn commandQueue(self: Self) CommandQueue {
        return self.object.msgSend(CommandQueue, "commandQueue", .{});
    }

    /// `-[MTLCommandBuffer retainedReferences]`
    pub fn retainedReferences(self: Self) bool {
        return self.object.msgSend(bool, "retainedReferences", .{});
    }

    /// `-[MTLCommandBuffer errorOptions]`
    pub fn errorOptions(self: Self) CommandBufferErrorOption {
        return self.object.msgSend(CommandBufferErrorOption, "errorOptions", .{});
    }

    /// `-[MTLCommandBuffer label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLCommandBuffer setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// `-[MTLCommandBuffer kernelStartTime]`
    pub fn kernelStartTime(self: Self) f64 {
        return self.object.msgSend(f64, "kernelStartTime", .{});
    }

    /// `-[MTLCommandBuffer kernelEndTime]`
    pub fn kernelEndTime(self: Self) f64 {
        return self.object.msgSend(f64, "kernelEndTime", .{});
    }

    /// `-[MTLCommandBuffer logs]`
    pub fn logs(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "logs", .{});
    }

    /// `-[MTLCommandBuffer GPUStartTime]`
    pub fn gpuStartTime(self: Self) f64 {
        return self.object.msgSend(f64, "GPUStartTime", .{});
    }

    /// `-[MTLCommandBuffer GPUEndTime]`
    pub fn gpuEndTime(self: Self) f64 {
        return self.object.msgSend(f64, "GPUEndTime", .{});
    }

    /// `-[MTLCommandBuffer status]`
    pub fn status(self: Self) CommandBufferStatus {
        return self.object.msgSend(CommandBufferStatus, "status", .{});
    }

    /// `-[MTLCommandBuffer error]`
    pub fn @"error"(self: Self) ?foundation.ErrorObject {
        return self.object.msgSend(?foundation.ErrorObject, "error", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-enqueue" = fn () void;
        pub const @"-commit" = fn () void;
        pub const @"-addScheduledHandler:" = fn (?objc.BlockRef(fn (CommandBuffer) void)) void;
        pub const @"-presentDrawable:" = fn (Drawable) void;
        pub const @"-presentDrawable:atTime:" = fn (Drawable, f64) void;
        pub const @"-presentDrawable:afterMinimumDuration:" = fn (Drawable, f64) void;
        pub const @"-waitUntilScheduled" = fn () void;
        pub const @"-addCompletedHandler:" = fn (?objc.BlockRef(fn (CommandBuffer) void)) void;
        pub const @"-waitUntilCompleted" = fn () void;
        pub const @"-blitCommandEncoder" = fn () ?BlitCommandEncoder;
        pub const @"-renderCommandEncoderWithDescriptor:" = fn (RenderPassDescriptor) ?RenderCommandEncoder;
        pub const @"-computeCommandEncoderWithDescriptor:" = fn (objc.Object) ?ComputeCommandEncoder;
        pub const @"-blitCommandEncoderWithDescriptor:" = fn (objc.Object) ?BlitCommandEncoder;
        pub const @"-computeCommandEncoder" = fn () ?ComputeCommandEncoder;
        pub const @"-computeCommandEncoderWithDispatchType:" = fn (DispatchType) ?ComputeCommandEncoder;
        pub const @"-encodeWaitForEvent:value:" = fn (objc.Object, u64) void;
        pub const @"-encodeSignalEvent:value:" = fn (objc.Object, u64) void;
        pub const @"-parallelRenderCommandEncoderWithDescriptor:" = fn (RenderPassDescriptor) ?objc.Object;
        pub const @"-resourceStateCommandEncoder" = fn () ?objc.Object;
        pub const @"-resourceStateCommandEncoderWithDescriptor:" = fn (objc.Object) ?objc.Object;
        pub const @"-accelerationStructureCommandEncoder" = fn () ?objc.Object;
        pub const @"-accelerationStructureCommandEncoderWithDescriptor:" = fn (objc.Object) objc.Object;
        pub const @"-pushDebugGroup:" = fn (foundation.String) void;
        pub const @"-popDebugGroup" = fn () void;
        pub const @"-useResidencySet:" = fn (objc.Object) void;
        pub const @"-useResidencySets:count:" = fn ([*]const objc.Object, objc.UInteger) void;
        pub const @"-device" = fn () Device;
        pub const @"-commandQueue" = fn () CommandQueue;
        pub const @"-retainedReferences" = fn () bool;
        pub const @"-errorOptions" = fn () CommandBufferErrorOption;
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-setLabel:" = fn (?foundation.String) void;
        pub const @"-kernelStartTime" = fn () f64;
        pub const @"-kernelEndTime" = fn () f64;
        pub const @"-logs" = fn () objc.Object;
        pub const @"-GPUStartTime" = fn () f64;
        pub const @"-GPUEndTime" = fn () f64;
        pub const @"-status" = fn () CommandBufferStatus;
        pub const @"-error" = fn () ?foundation.ErrorObject;
    };
};

/// An object conforming to `MTLCommandEncoder`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const CommandEncoder = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "MTLCommandEncoder";

    /// An object that came from elsewhere, taken to conform to `MTLCommandEncoder`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLCommandEncoder endEncoding]`
    pub fn endEncoding(self: Self) void {
        return self.object.msgSend(void, "endEncoding", .{});
    }

    /// `-[MTLCommandEncoder barrierAfterQueueStages:beforeStages:]`
    pub fn barrierAfterQueueStagesBeforeStages(self: Self, after_queue_stages: Stages, before_stages: Stages) void {
        return self.object.msgSend(void, "barrierAfterQueueStages:beforeStages:", .{ after_queue_stages, before_stages });
    }

    /// `-[MTLCommandEncoder insertDebugSignpost:]`
    pub fn insertDebugSignpost(self: Self, string: foundation.String) void {
        return self.object.msgSend(void, "insertDebugSignpost:", .{string});
    }

    /// `-[MTLCommandEncoder pushDebugGroup:]`
    pub fn pushDebugGroup(self: Self, string: foundation.String) void {
        return self.object.msgSend(void, "pushDebugGroup:", .{string});
    }

    /// `-[MTLCommandEncoder popDebugGroup]`
    pub fn popDebugGroup(self: Self) void {
        return self.object.msgSend(void, "popDebugGroup", .{});
    }

    /// `-[MTLCommandEncoder device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLCommandEncoder label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLCommandEncoder setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-endEncoding" = fn () void;
        pub const @"-barrierAfterQueueStages:beforeStages:" = fn (Stages, Stages) void;
        pub const @"-insertDebugSignpost:" = fn (foundation.String) void;
        pub const @"-pushDebugGroup:" = fn (foundation.String) void;
        pub const @"-popDebugGroup" = fn () void;
        pub const @"-device" = fn () Device;
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-setLabel:" = fn (?foundation.String) void;
    };
};

/// An object conforming to `MTLRenderCommandEncoder`, which extends `MTLCommandEncoder`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const RenderCommandEncoder = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = CommandEncoder;
    pub const protocol_name = "MTLRenderCommandEncoder";

    /// An object that came from elsewhere, taken to conform to `MTLRenderCommandEncoder`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLRenderCommandEncoder setRenderPipelineState:]`
    pub fn setRenderPipelineState(self: Self, pipeline_state: RenderPipelineState) void {
        return self.object.msgSend(void, "setRenderPipelineState:", .{pipeline_state});
    }

    /// `-[MTLRenderCommandEncoder setVertexBytes:length:atIndex:]`
    pub fn setVertexBytesLengthAtIndex(self: Self, bytes: ?*const anyopaque, length: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setVertexBytes:length:atIndex:", .{ bytes, length, index });
    }

    /// `-[MTLRenderCommandEncoder setVertexBuffer:offset:atIndex:]`
    pub fn setVertexBufferOffsetAtIndex(self: Self, buffer: ?Buffer, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setVertexBuffer:offset:atIndex:", .{ buffer, offset, index });
    }

    /// `-[MTLRenderCommandEncoder setVertexBufferOffset:atIndex:]`
    pub fn setVertexBufferOffsetAtIndex_(self: Self, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setVertexBufferOffset:atIndex:", .{ offset, index });
    }

    /// `-[MTLRenderCommandEncoder setVertexBuffers:offsets:withRange:]`
    pub fn setVertexBuffersOffsetsWithRange(self: Self, buffers: [*]const objc.Nullable(Buffer), offsets: ?[*]const objc.UInteger, range: objc.Range) void {
        return self.object.msgSend(void, "setVertexBuffers:offsets:withRange:", .{ buffers, offsets, range });
    }

    /// `-[MTLRenderCommandEncoder setVertexBuffer:offset:attributeStride:atIndex:]`
    pub fn setVertexBufferOffsetAttributeStrideAtIndex(self: Self, buffer: ?Buffer, offset: objc.UInteger, stride: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setVertexBuffer:offset:attributeStride:atIndex:", .{ buffer, offset, stride, index });
    }

    /// `-[MTLRenderCommandEncoder setVertexBuffers:offsets:attributeStrides:withRange:]`
    pub fn setVertexBuffersOffsetsAttributeStridesWithRange(self: Self, buffers: [*]const objc.Nullable(Buffer), offsets: ?[*]const objc.UInteger, strides: ?[*]const objc.UInteger, range: objc.Range) void {
        return self.object.msgSend(void, "setVertexBuffers:offsets:attributeStrides:withRange:", .{ buffers, offsets, strides, range });
    }

    /// `-[MTLRenderCommandEncoder setVertexBufferOffset:attributeStride:atIndex:]`
    pub fn setVertexBufferOffsetAttributeStrideAtIndex_(self: Self, offset: objc.UInteger, stride: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setVertexBufferOffset:attributeStride:atIndex:", .{ offset, stride, index });
    }

    /// `-[MTLRenderCommandEncoder setVertexBytes:length:attributeStride:atIndex:]`
    pub fn setVertexBytesLengthAttributeStrideAtIndex(self: Self, bytes: ?*const anyopaque, length: objc.UInteger, stride: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setVertexBytes:length:attributeStride:atIndex:", .{ bytes, length, stride, index });
    }

    /// `-[MTLRenderCommandEncoder setVertexTexture:atIndex:]`
    pub fn setVertexTextureAtIndex(self: Self, texture: ?Texture, index: objc.UInteger) void {
        return self.object.msgSend(void, "setVertexTexture:atIndex:", .{ texture, index });
    }

    /// `-[MTLRenderCommandEncoder setVertexTextures:withRange:]`
    pub fn setVertexTexturesWithRange(self: Self, textures: [*]const objc.Nullable(Texture), range: objc.Range) void {
        return self.object.msgSend(void, "setVertexTextures:withRange:", .{ textures, range });
    }

    /// `-[MTLRenderCommandEncoder setVertexSamplerState:atIndex:]`
    pub fn setVertexSamplerStateAtIndex(self: Self, sampler: ?SamplerState, index: objc.UInteger) void {
        return self.object.msgSend(void, "setVertexSamplerState:atIndex:", .{ sampler, index });
    }

    /// `-[MTLRenderCommandEncoder setVertexSamplerStates:withRange:]`
    pub fn setVertexSamplerStatesWithRange(self: Self, samplers: [*]const objc.Nullable(SamplerState), range: objc.Range) void {
        return self.object.msgSend(void, "setVertexSamplerStates:withRange:", .{ samplers, range });
    }

    /// `-[MTLRenderCommandEncoder setVertexSamplerState:lodMinClamp:lodMaxClamp:atIndex:]`
    pub fn setVertexSamplerStateLodMinClampLodMaxClampAtIndex(self: Self, sampler: ?SamplerState, lod_min_clamp: f32, lod_max_clamp: f32, index: objc.UInteger) void {
        return self.object.msgSend(void, "setVertexSamplerState:lodMinClamp:lodMaxClamp:atIndex:", .{ sampler, lod_min_clamp, lod_max_clamp, index });
    }

    /// `-[MTLRenderCommandEncoder setVertexSamplerStates:lodMinClamps:lodMaxClamps:withRange:]`
    pub fn setVertexSamplerStatesLodMinClampsLodMaxClampsWithRange(self: Self, samplers: [*]const objc.Nullable(SamplerState), lod_min_clamps: ?[*]const f32, lod_max_clamps: ?[*]const f32, range: objc.Range) void {
        return self.object.msgSend(void, "setVertexSamplerStates:lodMinClamps:lodMaxClamps:withRange:", .{ samplers, lod_min_clamps, lod_max_clamps, range });
    }

    /// `-[MTLRenderCommandEncoder setVertexVisibleFunctionTable:atBufferIndex:]`
    pub fn setVertexVisibleFunctionTableAtBufferIndex(self: Self, function_table: ?objc.Object, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setVertexVisibleFunctionTable:atBufferIndex:", .{ function_table, buffer_index });
    }

    /// `-[MTLRenderCommandEncoder setVertexVisibleFunctionTables:withBufferRange:]`
    pub fn setVertexVisibleFunctionTablesWithBufferRange(self: Self, function_tables: [*]const objc.Nullable(objc.Object), range: objc.Range) void {
        return self.object.msgSend(void, "setVertexVisibleFunctionTables:withBufferRange:", .{ function_tables, range });
    }

    /// `-[MTLRenderCommandEncoder setVertexIntersectionFunctionTable:atBufferIndex:]`
    pub fn setVertexIntersectionFunctionTableAtBufferIndex(self: Self, intersection_function_table: ?objc.Object, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setVertexIntersectionFunctionTable:atBufferIndex:", .{ intersection_function_table, buffer_index });
    }

    /// `-[MTLRenderCommandEncoder setVertexIntersectionFunctionTables:withBufferRange:]`
    pub fn setVertexIntersectionFunctionTablesWithBufferRange(self: Self, intersection_function_tables: [*]const objc.Nullable(objc.Object), range: objc.Range) void {
        return self.object.msgSend(void, "setVertexIntersectionFunctionTables:withBufferRange:", .{ intersection_function_tables, range });
    }

    /// `-[MTLRenderCommandEncoder setVertexAccelerationStructure:atBufferIndex:]`
    pub fn setVertexAccelerationStructureAtBufferIndex(self: Self, acceleration_structure: ?objc.Object, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setVertexAccelerationStructure:atBufferIndex:", .{ acceleration_structure, buffer_index });
    }

    /// `-[MTLRenderCommandEncoder setViewport:]`
    pub fn setViewport(self: Self, viewport: Viewport) void {
        return self.object.msgSend(void, "setViewport:", .{viewport});
    }

    /// `-[MTLRenderCommandEncoder setViewports:count:]`
    pub fn setViewportsCount(self: Self, viewports: ?[*]const Viewport, count: objc.UInteger) void {
        return self.object.msgSend(void, "setViewports:count:", .{ viewports, count });
    }

    /// `-[MTLRenderCommandEncoder setFrontFacingWinding:]`
    pub fn setFrontFacingWinding(self: Self, front_facing_winding: Winding) void {
        return self.object.msgSend(void, "setFrontFacingWinding:", .{front_facing_winding});
    }

    /// `-[MTLRenderCommandEncoder setVertexAmplificationCount:viewMappings:]`
    pub fn setVertexAmplificationCountViewMappings(self: Self, count: objc.UInteger, view_mappings: ?objc.Object) void {
        return self.object.msgSend(void, "setVertexAmplificationCount:viewMappings:", .{ count, view_mappings });
    }

    /// `-[MTLRenderCommandEncoder setCullMode:]`
    pub fn setCullMode(self: Self, cull_mode: CullMode) void {
        return self.object.msgSend(void, "setCullMode:", .{cull_mode});
    }

    /// `-[MTLRenderCommandEncoder setDepthClipMode:]`
    pub fn setDepthClipMode(self: Self, depth_clip_mode: DepthClipMode) void {
        return self.object.msgSend(void, "setDepthClipMode:", .{depth_clip_mode});
    }

    /// `-[MTLRenderCommandEncoder setDepthBias:slopeScale:clamp:]`
    pub fn setDepthBiasSlopeScaleClamp(self: Self, depth_bias: f32, slope_scale: f32, clamp: f32) void {
        return self.object.msgSend(void, "setDepthBias:slopeScale:clamp:", .{ depth_bias, slope_scale, clamp });
    }

    /// `-[MTLRenderCommandEncoder setDepthTestMinBound:maxBound:]`
    pub fn setDepthTestMinBoundMaxBound(self: Self, min_bound: f32, max_bound: f32) void {
        return self.object.msgSend(void, "setDepthTestMinBound:maxBound:", .{ min_bound, max_bound });
    }

    /// `-[MTLRenderCommandEncoder setScissorRect:]`
    pub fn setScissorRect(self: Self, rect: ScissorRect) void {
        return self.object.msgSend(void, "setScissorRect:", .{rect});
    }

    /// `-[MTLRenderCommandEncoder setScissorRects:count:]`
    pub fn setScissorRectsCount(self: Self, scissor_rects: ?[*]const ScissorRect, count: objc.UInteger) void {
        return self.object.msgSend(void, "setScissorRects:count:", .{ scissor_rects, count });
    }

    /// `-[MTLRenderCommandEncoder setTriangleFillMode:]`
    pub fn setTriangleFillMode(self: Self, fill_mode: TriangleFillMode) void {
        return self.object.msgSend(void, "setTriangleFillMode:", .{fill_mode});
    }

    /// `-[MTLRenderCommandEncoder setFragmentBytes:length:atIndex:]`
    pub fn setFragmentBytesLengthAtIndex(self: Self, bytes: ?*const anyopaque, length: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setFragmentBytes:length:atIndex:", .{ bytes, length, index });
    }

    /// `-[MTLRenderCommandEncoder setFragmentBuffer:offset:atIndex:]`
    pub fn setFragmentBufferOffsetAtIndex(self: Self, buffer: ?Buffer, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setFragmentBuffer:offset:atIndex:", .{ buffer, offset, index });
    }

    /// `-[MTLRenderCommandEncoder setFragmentBufferOffset:atIndex:]`
    pub fn setFragmentBufferOffsetAtIndex_(self: Self, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setFragmentBufferOffset:atIndex:", .{ offset, index });
    }

    /// `-[MTLRenderCommandEncoder setFragmentBuffers:offsets:withRange:]`
    pub fn setFragmentBuffersOffsetsWithRange(self: Self, buffers: [*]const objc.Nullable(Buffer), offsets: ?[*]const objc.UInteger, range: objc.Range) void {
        return self.object.msgSend(void, "setFragmentBuffers:offsets:withRange:", .{ buffers, offsets, range });
    }

    /// `-[MTLRenderCommandEncoder setFragmentTexture:atIndex:]`
    pub fn setFragmentTextureAtIndex(self: Self, texture: ?Texture, index: objc.UInteger) void {
        return self.object.msgSend(void, "setFragmentTexture:atIndex:", .{ texture, index });
    }

    /// `-[MTLRenderCommandEncoder setFragmentTextures:withRange:]`
    pub fn setFragmentTexturesWithRange(self: Self, textures: [*]const objc.Nullable(Texture), range: objc.Range) void {
        return self.object.msgSend(void, "setFragmentTextures:withRange:", .{ textures, range });
    }

    /// `-[MTLRenderCommandEncoder setFragmentSamplerState:atIndex:]`
    pub fn setFragmentSamplerStateAtIndex(self: Self, sampler: ?SamplerState, index: objc.UInteger) void {
        return self.object.msgSend(void, "setFragmentSamplerState:atIndex:", .{ sampler, index });
    }

    /// `-[MTLRenderCommandEncoder setFragmentSamplerStates:withRange:]`
    pub fn setFragmentSamplerStatesWithRange(self: Self, samplers: [*]const objc.Nullable(SamplerState), range: objc.Range) void {
        return self.object.msgSend(void, "setFragmentSamplerStates:withRange:", .{ samplers, range });
    }

    /// `-[MTLRenderCommandEncoder setFragmentSamplerState:lodMinClamp:lodMaxClamp:atIndex:]`
    pub fn setFragmentSamplerStateLodMinClampLodMaxClampAtIndex(self: Self, sampler: ?SamplerState, lod_min_clamp: f32, lod_max_clamp: f32, index: objc.UInteger) void {
        return self.object.msgSend(void, "setFragmentSamplerState:lodMinClamp:lodMaxClamp:atIndex:", .{ sampler, lod_min_clamp, lod_max_clamp, index });
    }

    /// `-[MTLRenderCommandEncoder setFragmentSamplerStates:lodMinClamps:lodMaxClamps:withRange:]`
    pub fn setFragmentSamplerStatesLodMinClampsLodMaxClampsWithRange(self: Self, samplers: [*]const objc.Nullable(SamplerState), lod_min_clamps: ?[*]const f32, lod_max_clamps: ?[*]const f32, range: objc.Range) void {
        return self.object.msgSend(void, "setFragmentSamplerStates:lodMinClamps:lodMaxClamps:withRange:", .{ samplers, lod_min_clamps, lod_max_clamps, range });
    }

    /// `-[MTLRenderCommandEncoder setFragmentVisibleFunctionTable:atBufferIndex:]`
    pub fn setFragmentVisibleFunctionTableAtBufferIndex(self: Self, function_table: ?objc.Object, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setFragmentVisibleFunctionTable:atBufferIndex:", .{ function_table, buffer_index });
    }

    /// `-[MTLRenderCommandEncoder setFragmentVisibleFunctionTables:withBufferRange:]`
    pub fn setFragmentVisibleFunctionTablesWithBufferRange(self: Self, function_tables: [*]const objc.Nullable(objc.Object), range: objc.Range) void {
        return self.object.msgSend(void, "setFragmentVisibleFunctionTables:withBufferRange:", .{ function_tables, range });
    }

    /// `-[MTLRenderCommandEncoder setFragmentIntersectionFunctionTable:atBufferIndex:]`
    pub fn setFragmentIntersectionFunctionTableAtBufferIndex(self: Self, intersection_function_table: ?objc.Object, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setFragmentIntersectionFunctionTable:atBufferIndex:", .{ intersection_function_table, buffer_index });
    }

    /// `-[MTLRenderCommandEncoder setFragmentIntersectionFunctionTables:withBufferRange:]`
    pub fn setFragmentIntersectionFunctionTablesWithBufferRange(self: Self, intersection_function_tables: [*]const objc.Nullable(objc.Object), range: objc.Range) void {
        return self.object.msgSend(void, "setFragmentIntersectionFunctionTables:withBufferRange:", .{ intersection_function_tables, range });
    }

    /// `-[MTLRenderCommandEncoder setFragmentAccelerationStructure:atBufferIndex:]`
    pub fn setFragmentAccelerationStructureAtBufferIndex(self: Self, acceleration_structure: ?objc.Object, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setFragmentAccelerationStructure:atBufferIndex:", .{ acceleration_structure, buffer_index });
    }

    /// `-[MTLRenderCommandEncoder setBlendColorRed:green:blue:alpha:]`
    pub fn setBlendColorRedGreenBlueAlpha(self: Self, red: f32, green: f32, blue: f32, alpha: f32) void {
        return self.object.msgSend(void, "setBlendColorRed:green:blue:alpha:", .{ red, green, blue, alpha });
    }

    /// `-[MTLRenderCommandEncoder setDepthStencilState:]`
    pub fn setDepthStencilState(self: Self, depth_stencil_state: ?DepthStencilState) void {
        return self.object.msgSend(void, "setDepthStencilState:", .{depth_stencil_state});
    }

    /// `-[MTLRenderCommandEncoder setStencilReferenceValue:]`
    pub fn setStencilReferenceValue(self: Self, reference_value: u32) void {
        return self.object.msgSend(void, "setStencilReferenceValue:", .{reference_value});
    }

    /// `-[MTLRenderCommandEncoder setStencilFrontReferenceValue:backReferenceValue:]`
    pub fn setStencilFrontReferenceValueBackReferenceValue(self: Self, front_reference_value: u32, back_reference_value: u32) void {
        return self.object.msgSend(void, "setStencilFrontReferenceValue:backReferenceValue:", .{ front_reference_value, back_reference_value });
    }

    /// `-[MTLRenderCommandEncoder setVisibilityResultMode:offset:]`
    pub fn setVisibilityResultModeOffset(self: Self, mode: VisibilityResultMode, offset: objc.UInteger) void {
        return self.object.msgSend(void, "setVisibilityResultMode:offset:", .{ mode, offset });
    }

    /// `-[MTLRenderCommandEncoder setColorStoreAction:atIndex:]`
    pub fn setColorStoreActionAtIndex(self: Self, store_action: StoreAction, color_attachment_index: objc.UInteger) void {
        return self.object.msgSend(void, "setColorStoreAction:atIndex:", .{ store_action, color_attachment_index });
    }

    /// `-[MTLRenderCommandEncoder setDepthStoreAction:]`
    pub fn setDepthStoreAction(self: Self, store_action: StoreAction) void {
        return self.object.msgSend(void, "setDepthStoreAction:", .{store_action});
    }

    /// `-[MTLRenderCommandEncoder setStencilStoreAction:]`
    pub fn setStencilStoreAction(self: Self, store_action: StoreAction) void {
        return self.object.msgSend(void, "setStencilStoreAction:", .{store_action});
    }

    /// `-[MTLRenderCommandEncoder setColorStoreActionOptions:atIndex:]`
    pub fn setColorStoreActionOptionsAtIndex(self: Self, store_action_options: StoreActionOptions, color_attachment_index: objc.UInteger) void {
        return self.object.msgSend(void, "setColorStoreActionOptions:atIndex:", .{ store_action_options, color_attachment_index });
    }

    /// `-[MTLRenderCommandEncoder setDepthStoreActionOptions:]`
    pub fn setDepthStoreActionOptions(self: Self, store_action_options: StoreActionOptions) void {
        return self.object.msgSend(void, "setDepthStoreActionOptions:", .{store_action_options});
    }

    /// `-[MTLRenderCommandEncoder setStencilStoreActionOptions:]`
    pub fn setStencilStoreActionOptions(self: Self, store_action_options: StoreActionOptions) void {
        return self.object.msgSend(void, "setStencilStoreActionOptions:", .{store_action_options});
    }

    /// `-[MTLRenderCommandEncoder setObjectBytes:length:atIndex:]`
    pub fn setObjectBytesLengthAtIndex(self: Self, bytes: ?*const anyopaque, length: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setObjectBytes:length:atIndex:", .{ bytes, length, index });
    }

    /// `-[MTLRenderCommandEncoder setObjectBuffer:offset:atIndex:]`
    pub fn setObjectBufferOffsetAtIndex(self: Self, buffer: ?Buffer, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setObjectBuffer:offset:atIndex:", .{ buffer, offset, index });
    }

    /// `-[MTLRenderCommandEncoder setObjectBufferOffset:atIndex:]`
    pub fn setObjectBufferOffsetAtIndex_(self: Self, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setObjectBufferOffset:atIndex:", .{ offset, index });
    }

    /// `-[MTLRenderCommandEncoder setObjectBuffers:offsets:withRange:]`
    pub fn setObjectBuffersOffsetsWithRange(self: Self, buffers: [*]const objc.Nullable(Buffer), offsets: ?[*]const objc.UInteger, range: objc.Range) void {
        return self.object.msgSend(void, "setObjectBuffers:offsets:withRange:", .{ buffers, offsets, range });
    }

    /// `-[MTLRenderCommandEncoder setObjectTexture:atIndex:]`
    pub fn setObjectTextureAtIndex(self: Self, texture: ?Texture, index: objc.UInteger) void {
        return self.object.msgSend(void, "setObjectTexture:atIndex:", .{ texture, index });
    }

    /// `-[MTLRenderCommandEncoder setObjectTextures:withRange:]`
    pub fn setObjectTexturesWithRange(self: Self, textures: [*]const objc.Nullable(Texture), range: objc.Range) void {
        return self.object.msgSend(void, "setObjectTextures:withRange:", .{ textures, range });
    }

    /// `-[MTLRenderCommandEncoder setObjectSamplerState:atIndex:]`
    pub fn setObjectSamplerStateAtIndex(self: Self, sampler: ?SamplerState, index: objc.UInteger) void {
        return self.object.msgSend(void, "setObjectSamplerState:atIndex:", .{ sampler, index });
    }

    /// `-[MTLRenderCommandEncoder setObjectSamplerStates:withRange:]`
    pub fn setObjectSamplerStatesWithRange(self: Self, samplers: [*]const objc.Nullable(SamplerState), range: objc.Range) void {
        return self.object.msgSend(void, "setObjectSamplerStates:withRange:", .{ samplers, range });
    }

    /// `-[MTLRenderCommandEncoder setObjectSamplerState:lodMinClamp:lodMaxClamp:atIndex:]`
    pub fn setObjectSamplerStateLodMinClampLodMaxClampAtIndex(self: Self, sampler: ?SamplerState, lod_min_clamp: f32, lod_max_clamp: f32, index: objc.UInteger) void {
        return self.object.msgSend(void, "setObjectSamplerState:lodMinClamp:lodMaxClamp:atIndex:", .{ sampler, lod_min_clamp, lod_max_clamp, index });
    }

    /// `-[MTLRenderCommandEncoder setObjectSamplerStates:lodMinClamps:lodMaxClamps:withRange:]`
    pub fn setObjectSamplerStatesLodMinClampsLodMaxClampsWithRange(self: Self, samplers: [*]const objc.Nullable(SamplerState), lod_min_clamps: ?[*]const f32, lod_max_clamps: ?[*]const f32, range: objc.Range) void {
        return self.object.msgSend(void, "setObjectSamplerStates:lodMinClamps:lodMaxClamps:withRange:", .{ samplers, lod_min_clamps, lod_max_clamps, range });
    }

    /// `-[MTLRenderCommandEncoder setObjectThreadgroupMemoryLength:atIndex:]`
    pub fn setObjectThreadgroupMemoryLengthAtIndex(self: Self, length: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setObjectThreadgroupMemoryLength:atIndex:", .{ length, index });
    }

    /// `-[MTLRenderCommandEncoder setMeshBytes:length:atIndex:]`
    pub fn setMeshBytesLengthAtIndex(self: Self, bytes: ?*const anyopaque, length: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setMeshBytes:length:atIndex:", .{ bytes, length, index });
    }

    /// `-[MTLRenderCommandEncoder setMeshBuffer:offset:atIndex:]`
    pub fn setMeshBufferOffsetAtIndex(self: Self, buffer: ?Buffer, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setMeshBuffer:offset:atIndex:", .{ buffer, offset, index });
    }

    /// `-[MTLRenderCommandEncoder setMeshBufferOffset:atIndex:]`
    pub fn setMeshBufferOffsetAtIndex_(self: Self, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setMeshBufferOffset:atIndex:", .{ offset, index });
    }

    /// `-[MTLRenderCommandEncoder setMeshBuffers:offsets:withRange:]`
    pub fn setMeshBuffersOffsetsWithRange(self: Self, buffers: [*]const objc.Nullable(Buffer), offsets: ?[*]const objc.UInteger, range: objc.Range) void {
        return self.object.msgSend(void, "setMeshBuffers:offsets:withRange:", .{ buffers, offsets, range });
    }

    /// `-[MTLRenderCommandEncoder setMeshTexture:atIndex:]`
    pub fn setMeshTextureAtIndex(self: Self, texture: ?Texture, index: objc.UInteger) void {
        return self.object.msgSend(void, "setMeshTexture:atIndex:", .{ texture, index });
    }

    /// `-[MTLRenderCommandEncoder setMeshTextures:withRange:]`
    pub fn setMeshTexturesWithRange(self: Self, textures: [*]const objc.Nullable(Texture), range: objc.Range) void {
        return self.object.msgSend(void, "setMeshTextures:withRange:", .{ textures, range });
    }

    /// `-[MTLRenderCommandEncoder setMeshSamplerState:atIndex:]`
    pub fn setMeshSamplerStateAtIndex(self: Self, sampler: ?SamplerState, index: objc.UInteger) void {
        return self.object.msgSend(void, "setMeshSamplerState:atIndex:", .{ sampler, index });
    }

    /// `-[MTLRenderCommandEncoder setMeshSamplerStates:withRange:]`
    pub fn setMeshSamplerStatesWithRange(self: Self, samplers: [*]const objc.Nullable(SamplerState), range: objc.Range) void {
        return self.object.msgSend(void, "setMeshSamplerStates:withRange:", .{ samplers, range });
    }

    /// `-[MTLRenderCommandEncoder setMeshSamplerState:lodMinClamp:lodMaxClamp:atIndex:]`
    pub fn setMeshSamplerStateLodMinClampLodMaxClampAtIndex(self: Self, sampler: ?SamplerState, lod_min_clamp: f32, lod_max_clamp: f32, index: objc.UInteger) void {
        return self.object.msgSend(void, "setMeshSamplerState:lodMinClamp:lodMaxClamp:atIndex:", .{ sampler, lod_min_clamp, lod_max_clamp, index });
    }

    /// `-[MTLRenderCommandEncoder setMeshSamplerStates:lodMinClamps:lodMaxClamps:withRange:]`
    pub fn setMeshSamplerStatesLodMinClampsLodMaxClampsWithRange(self: Self, samplers: [*]const objc.Nullable(SamplerState), lod_min_clamps: ?[*]const f32, lod_max_clamps: ?[*]const f32, range: objc.Range) void {
        return self.object.msgSend(void, "setMeshSamplerStates:lodMinClamps:lodMaxClamps:withRange:", .{ samplers, lod_min_clamps, lod_max_clamps, range });
    }

    /// `-[MTLRenderCommandEncoder drawMeshThreadgroups:threadsPerObjectThreadgroup:threadsPerMeshThreadgroup:]`
    pub fn drawMeshThreadgroupsThreadsPerObjectThreadgroupThreadsPerMeshThreadgroup(self: Self, threadgroups_per_grid: Size, threads_per_object_threadgroup: Size, threads_per_mesh_threadgroup: Size) void {
        return self.object.msgSend(void, "drawMeshThreadgroups:threadsPerObjectThreadgroup:threadsPerMeshThreadgroup:", .{ threadgroups_per_grid, threads_per_object_threadgroup, threads_per_mesh_threadgroup });
    }

    /// `-[MTLRenderCommandEncoder drawMeshThreads:threadsPerObjectThreadgroup:threadsPerMeshThreadgroup:]`
    pub fn drawMeshThreadsThreadsPerObjectThreadgroupThreadsPerMeshThreadgroup(self: Self, threads_per_grid: Size, threads_per_object_threadgroup: Size, threads_per_mesh_threadgroup: Size) void {
        return self.object.msgSend(void, "drawMeshThreads:threadsPerObjectThreadgroup:threadsPerMeshThreadgroup:", .{ threads_per_grid, threads_per_object_threadgroup, threads_per_mesh_threadgroup });
    }

    /// `-[MTLRenderCommandEncoder drawMeshThreadgroupsWithIndirectBuffer:indirectBufferOffset:threadsPerObjectThreadgroup:threadsPerMeshThreadgroup:]`
    pub fn drawMeshThreadgroupsWithIndirectBufferIndirectBufferOffsetThreadsPerObjectThreadgroupThreadsPerMeshThreadgroup(self: Self, indirect_buffer: Buffer, indirect_buffer_offset: objc.UInteger, threads_per_object_threadgroup: Size, threads_per_mesh_threadgroup: Size) void {
        return self.object.msgSend(void, "drawMeshThreadgroupsWithIndirectBuffer:indirectBufferOffset:threadsPerObjectThreadgroup:threadsPerMeshThreadgroup:", .{ indirect_buffer, indirect_buffer_offset, threads_per_object_threadgroup, threads_per_mesh_threadgroup });
    }

    /// `-[MTLRenderCommandEncoder drawPrimitives:vertexStart:vertexCount:instanceCount:]`
    pub fn drawPrimitivesVertexStartVertexCountInstanceCount(self: Self, primitive_type: PrimitiveType, vertex_start: objc.UInteger, vertex_count: objc.UInteger, instance_count: objc.UInteger) void {
        return self.object.msgSend(void, "drawPrimitives:vertexStart:vertexCount:instanceCount:", .{ primitive_type, vertex_start, vertex_count, instance_count });
    }

    /// `-[MTLRenderCommandEncoder drawPrimitives:vertexStart:vertexCount:]`
    pub fn drawPrimitivesVertexStartVertexCount(self: Self, primitive_type: PrimitiveType, vertex_start: objc.UInteger, vertex_count: objc.UInteger) void {
        return self.object.msgSend(void, "drawPrimitives:vertexStart:vertexCount:", .{ primitive_type, vertex_start, vertex_count });
    }

    /// `-[MTLRenderCommandEncoder drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:instanceCount:]`
    pub fn drawIndexedPrimitivesIndexCountIndexTypeIndexBufferIndexBufferOffsetInstanceCount(self: Self, primitive_type: PrimitiveType, index_count: objc.UInteger, index_type: IndexType, index_buffer: Buffer, index_buffer_offset: objc.UInteger, instance_count: objc.UInteger) void {
        return self.object.msgSend(void, "drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:instanceCount:", .{ primitive_type, index_count, index_type, index_buffer, index_buffer_offset, instance_count });
    }

    /// `-[MTLRenderCommandEncoder drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:]`
    pub fn drawIndexedPrimitivesIndexCountIndexTypeIndexBufferIndexBufferOffset(self: Self, primitive_type: PrimitiveType, index_count: objc.UInteger, index_type: IndexType, index_buffer: Buffer, index_buffer_offset: objc.UInteger) void {
        return self.object.msgSend(void, "drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:", .{ primitive_type, index_count, index_type, index_buffer, index_buffer_offset });
    }

    /// `-[MTLRenderCommandEncoder drawPrimitives:vertexStart:vertexCount:instanceCount:baseInstance:]`
    pub fn drawPrimitivesVertexStartVertexCountInstanceCountBaseInstance(self: Self, primitive_type: PrimitiveType, vertex_start: objc.UInteger, vertex_count: objc.UInteger, instance_count: objc.UInteger, base_instance: objc.UInteger) void {
        return self.object.msgSend(void, "drawPrimitives:vertexStart:vertexCount:instanceCount:baseInstance:", .{ primitive_type, vertex_start, vertex_count, instance_count, base_instance });
    }

    /// `-[MTLRenderCommandEncoder drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:instanceCount:baseVertex:baseInstance:]`
    pub fn drawIndexedPrimitivesIndexCountIndexTypeIndexBufferIndexBufferOffsetInstanceCountBaseVertexBaseInstance(self: Self, primitive_type: PrimitiveType, index_count: objc.UInteger, index_type: IndexType, index_buffer: Buffer, index_buffer_offset: objc.UInteger, instance_count: objc.UInteger, base_vertex: objc.Integer, base_instance: objc.UInteger) void {
        return self.object.msgSend(void, "drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:instanceCount:baseVertex:baseInstance:", .{ primitive_type, index_count, index_type, index_buffer, index_buffer_offset, instance_count, base_vertex, base_instance });
    }

    /// `-[MTLRenderCommandEncoder drawPrimitives:indirectBuffer:indirectBufferOffset:]`
    pub fn drawPrimitivesIndirectBufferIndirectBufferOffset(self: Self, primitive_type: PrimitiveType, indirect_buffer: Buffer, indirect_buffer_offset: objc.UInteger) void {
        return self.object.msgSend(void, "drawPrimitives:indirectBuffer:indirectBufferOffset:", .{ primitive_type, indirect_buffer, indirect_buffer_offset });
    }

    /// `-[MTLRenderCommandEncoder drawIndexedPrimitives:indexType:indexBuffer:indexBufferOffset:indirectBuffer:indirectBufferOffset:]`
    pub fn drawIndexedPrimitivesIndexTypeIndexBufferIndexBufferOffsetIndirectBufferIndirectBufferOffset(self: Self, primitive_type: PrimitiveType, index_type: IndexType, index_buffer: Buffer, index_buffer_offset: objc.UInteger, indirect_buffer: Buffer, indirect_buffer_offset: objc.UInteger) void {
        return self.object.msgSend(void, "drawIndexedPrimitives:indexType:indexBuffer:indexBufferOffset:indirectBuffer:indirectBufferOffset:", .{ primitive_type, index_type, index_buffer, index_buffer_offset, indirect_buffer, indirect_buffer_offset });
    }

    /// `-[MTLRenderCommandEncoder textureBarrier]`
    pub fn textureBarrier(self: Self) void {
        return self.object.msgSend(void, "textureBarrier", .{});
    }

    /// `-[MTLRenderCommandEncoder updateFence:afterStages:]`
    pub fn updateFenceAfterStages(self: Self, fence: objc.Object, stages: RenderStages) void {
        return self.object.msgSend(void, "updateFence:afterStages:", .{ fence, stages });
    }

    /// `-[MTLRenderCommandEncoder waitForFence:beforeStages:]`
    pub fn waitForFenceBeforeStages(self: Self, fence: objc.Object, stages: RenderStages) void {
        return self.object.msgSend(void, "waitForFence:beforeStages:", .{ fence, stages });
    }

    /// `-[MTLRenderCommandEncoder setTessellationFactorBuffer:offset:instanceStride:]`
    pub fn setTessellationFactorBufferOffsetInstanceStride(self: Self, buffer: ?Buffer, offset: objc.UInteger, instance_stride: objc.UInteger) void {
        return self.object.msgSend(void, "setTessellationFactorBuffer:offset:instanceStride:", .{ buffer, offset, instance_stride });
    }

    /// `-[MTLRenderCommandEncoder setTessellationFactorScale:]`
    pub fn setTessellationFactorScale(self: Self, scale: f32) void {
        return self.object.msgSend(void, "setTessellationFactorScale:", .{scale});
    }

    /// `-[MTLRenderCommandEncoder drawPatches:patchStart:patchCount:patchIndexBuffer:patchIndexBufferOffset:instanceCount:baseInstance:]`
    pub fn drawPatchesPatchStartPatchCountPatchIndexBufferPatchIndexBufferOffsetInstanceCountBaseInstance(self: Self, number_of_patch_control_points: objc.UInteger, patch_start: objc.UInteger, patch_count: objc.UInteger, patch_index_buffer: ?Buffer, patch_index_buffer_offset: objc.UInteger, instance_count: objc.UInteger, base_instance: objc.UInteger) void {
        return self.object.msgSend(void, "drawPatches:patchStart:patchCount:patchIndexBuffer:patchIndexBufferOffset:instanceCount:baseInstance:", .{ number_of_patch_control_points, patch_start, patch_count, patch_index_buffer, patch_index_buffer_offset, instance_count, base_instance });
    }

    /// `-[MTLRenderCommandEncoder drawPatches:patchIndexBuffer:patchIndexBufferOffset:indirectBuffer:indirectBufferOffset:]`
    pub fn drawPatchesPatchIndexBufferPatchIndexBufferOffsetIndirectBufferIndirectBufferOffset(self: Self, number_of_patch_control_points: objc.UInteger, patch_index_buffer: ?Buffer, patch_index_buffer_offset: objc.UInteger, indirect_buffer: Buffer, indirect_buffer_offset: objc.UInteger) void {
        return self.object.msgSend(void, "drawPatches:patchIndexBuffer:patchIndexBufferOffset:indirectBuffer:indirectBufferOffset:", .{ number_of_patch_control_points, patch_index_buffer, patch_index_buffer_offset, indirect_buffer, indirect_buffer_offset });
    }

    /// `-[MTLRenderCommandEncoder drawIndexedPatches:patchStart:patchCount:patchIndexBuffer:patchIndexBufferOffset:controlPointIndexBuffer:controlPointIndexBufferOffset:instanceCount:baseInstance:]`
    pub fn drawIndexedPatchesPatchStartPatchCountPatchIndexBufferPatchIndexBufferOffsetControlPointIndexBufferControlPointIndexBufferOffsetInstanceCountBaseInstance(self: Self, number_of_patch_control_points: objc.UInteger, patch_start: objc.UInteger, patch_count: objc.UInteger, patch_index_buffer: ?Buffer, patch_index_buffer_offset: objc.UInteger, control_point_index_buffer: Buffer, control_point_index_buffer_offset: objc.UInteger, instance_count: objc.UInteger, base_instance: objc.UInteger) void {
        return self.object.msgSend(void, "drawIndexedPatches:patchStart:patchCount:patchIndexBuffer:patchIndexBufferOffset:controlPointIndexBuffer:controlPointIndexBufferOffset:instanceCount:baseInstance:", .{ number_of_patch_control_points, patch_start, patch_count, patch_index_buffer, patch_index_buffer_offset, control_point_index_buffer, control_point_index_buffer_offset, instance_count, base_instance });
    }

    /// `-[MTLRenderCommandEncoder drawIndexedPatches:patchIndexBuffer:patchIndexBufferOffset:controlPointIndexBuffer:controlPointIndexBufferOffset:indirectBuffer:indirectBufferOffset:]`
    pub fn drawIndexedPatchesPatchIndexBufferPatchIndexBufferOffsetControlPointIndexBufferControlPointIndexBufferOffsetIndirectBufferIndirectBufferOffset(self: Self, number_of_patch_control_points: objc.UInteger, patch_index_buffer: ?Buffer, patch_index_buffer_offset: objc.UInteger, control_point_index_buffer: Buffer, control_point_index_buffer_offset: objc.UInteger, indirect_buffer: Buffer, indirect_buffer_offset: objc.UInteger) void {
        return self.object.msgSend(void, "drawIndexedPatches:patchIndexBuffer:patchIndexBufferOffset:controlPointIndexBuffer:controlPointIndexBufferOffset:indirectBuffer:indirectBufferOffset:", .{ number_of_patch_control_points, patch_index_buffer, patch_index_buffer_offset, control_point_index_buffer, control_point_index_buffer_offset, indirect_buffer, indirect_buffer_offset });
    }

    /// `-[MTLRenderCommandEncoder setTileBytes:length:atIndex:]`
    pub fn setTileBytesLengthAtIndex(self: Self, bytes: ?*const anyopaque, length: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setTileBytes:length:atIndex:", .{ bytes, length, index });
    }

    /// `-[MTLRenderCommandEncoder setTileBuffer:offset:atIndex:]`
    pub fn setTileBufferOffsetAtIndex(self: Self, buffer: ?Buffer, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setTileBuffer:offset:atIndex:", .{ buffer, offset, index });
    }

    /// `-[MTLRenderCommandEncoder setTileBufferOffset:atIndex:]`
    pub fn setTileBufferOffsetAtIndex_(self: Self, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setTileBufferOffset:atIndex:", .{ offset, index });
    }

    /// `-[MTLRenderCommandEncoder setTileBuffers:offsets:withRange:]`
    pub fn setTileBuffersOffsetsWithRange(self: Self, buffers: [*]const objc.Nullable(Buffer), offsets: ?[*]const objc.UInteger, range: objc.Range) void {
        return self.object.msgSend(void, "setTileBuffers:offsets:withRange:", .{ buffers, offsets, range });
    }

    /// `-[MTLRenderCommandEncoder setTileTexture:atIndex:]`
    pub fn setTileTextureAtIndex(self: Self, texture: ?Texture, index: objc.UInteger) void {
        return self.object.msgSend(void, "setTileTexture:atIndex:", .{ texture, index });
    }

    /// `-[MTLRenderCommandEncoder setTileTextures:withRange:]`
    pub fn setTileTexturesWithRange(self: Self, textures: [*]const objc.Nullable(Texture), range: objc.Range) void {
        return self.object.msgSend(void, "setTileTextures:withRange:", .{ textures, range });
    }

    /// `-[MTLRenderCommandEncoder setTileSamplerState:atIndex:]`
    pub fn setTileSamplerStateAtIndex(self: Self, sampler: ?SamplerState, index: objc.UInteger) void {
        return self.object.msgSend(void, "setTileSamplerState:atIndex:", .{ sampler, index });
    }

    /// `-[MTLRenderCommandEncoder setTileSamplerStates:withRange:]`
    pub fn setTileSamplerStatesWithRange(self: Self, samplers: [*]const objc.Nullable(SamplerState), range: objc.Range) void {
        return self.object.msgSend(void, "setTileSamplerStates:withRange:", .{ samplers, range });
    }

    /// `-[MTLRenderCommandEncoder setTileSamplerState:lodMinClamp:lodMaxClamp:atIndex:]`
    pub fn setTileSamplerStateLodMinClampLodMaxClampAtIndex(self: Self, sampler: ?SamplerState, lod_min_clamp: f32, lod_max_clamp: f32, index: objc.UInteger) void {
        return self.object.msgSend(void, "setTileSamplerState:lodMinClamp:lodMaxClamp:atIndex:", .{ sampler, lod_min_clamp, lod_max_clamp, index });
    }

    /// `-[MTLRenderCommandEncoder setTileSamplerStates:lodMinClamps:lodMaxClamps:withRange:]`
    pub fn setTileSamplerStatesLodMinClampsLodMaxClampsWithRange(self: Self, samplers: [*]const objc.Nullable(SamplerState), lod_min_clamps: ?[*]const f32, lod_max_clamps: ?[*]const f32, range: objc.Range) void {
        return self.object.msgSend(void, "setTileSamplerStates:lodMinClamps:lodMaxClamps:withRange:", .{ samplers, lod_min_clamps, lod_max_clamps, range });
    }

    /// `-[MTLRenderCommandEncoder setTileVisibleFunctionTable:atBufferIndex:]`
    pub fn setTileVisibleFunctionTableAtBufferIndex(self: Self, function_table: ?objc.Object, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setTileVisibleFunctionTable:atBufferIndex:", .{ function_table, buffer_index });
    }

    /// `-[MTLRenderCommandEncoder setTileVisibleFunctionTables:withBufferRange:]`
    pub fn setTileVisibleFunctionTablesWithBufferRange(self: Self, function_tables: [*]const objc.Nullable(objc.Object), range: objc.Range) void {
        return self.object.msgSend(void, "setTileVisibleFunctionTables:withBufferRange:", .{ function_tables, range });
    }

    /// `-[MTLRenderCommandEncoder setTileIntersectionFunctionTable:atBufferIndex:]`
    pub fn setTileIntersectionFunctionTableAtBufferIndex(self: Self, intersection_function_table: ?objc.Object, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setTileIntersectionFunctionTable:atBufferIndex:", .{ intersection_function_table, buffer_index });
    }

    /// `-[MTLRenderCommandEncoder setTileIntersectionFunctionTables:withBufferRange:]`
    pub fn setTileIntersectionFunctionTablesWithBufferRange(self: Self, intersection_function_tables: [*]const objc.Nullable(objc.Object), range: objc.Range) void {
        return self.object.msgSend(void, "setTileIntersectionFunctionTables:withBufferRange:", .{ intersection_function_tables, range });
    }

    /// `-[MTLRenderCommandEncoder setTileAccelerationStructure:atBufferIndex:]`
    pub fn setTileAccelerationStructureAtBufferIndex(self: Self, acceleration_structure: ?objc.Object, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setTileAccelerationStructure:atBufferIndex:", .{ acceleration_structure, buffer_index });
    }

    /// `-[MTLRenderCommandEncoder dispatchThreadsPerTile:]`
    pub fn dispatchThreadsPerTile(self: Self, threads_per_tile: Size) void {
        return self.object.msgSend(void, "dispatchThreadsPerTile:", .{threads_per_tile});
    }

    /// `-[MTLRenderCommandEncoder setThreadgroupMemoryLength:offset:atIndex:]`
    pub fn setThreadgroupMemoryLengthOffsetAtIndex(self: Self, length: objc.UInteger, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setThreadgroupMemoryLength:offset:atIndex:", .{ length, offset, index });
    }

    /// `-[MTLRenderCommandEncoder useResource:usage:]`
    pub fn useResourceUsage(self: Self, resource: Resource, usage: ResourceUsage) void {
        return self.object.msgSend(void, "useResource:usage:", .{ resource, usage });
    }

    /// `-[MTLRenderCommandEncoder useResources:count:usage:]`
    pub fn useResourcesCountUsage(self: Self, resources: [*]const Resource, count: objc.UInteger, usage: ResourceUsage) void {
        return self.object.msgSend(void, "useResources:count:usage:", .{ resources, count, usage });
    }

    /// `-[MTLRenderCommandEncoder useResource:usage:stages:]`
    pub fn useResourceUsageStages(self: Self, resource: Resource, usage: ResourceUsage, stages: RenderStages) void {
        return self.object.msgSend(void, "useResource:usage:stages:", .{ resource, usage, stages });
    }

    /// `-[MTLRenderCommandEncoder useResources:count:usage:stages:]`
    pub fn useResourcesCountUsageStages(self: Self, resources: [*]const Resource, count: objc.UInteger, usage: ResourceUsage, stages: RenderStages) void {
        return self.object.msgSend(void, "useResources:count:usage:stages:", .{ resources, count, usage, stages });
    }

    /// `-[MTLRenderCommandEncoder useHeap:]`
    pub fn useHeap(self: Self, heap: objc.Object) void {
        return self.object.msgSend(void, "useHeap:", .{heap});
    }

    /// `-[MTLRenderCommandEncoder useHeaps:count:]`
    pub fn useHeapsCount(self: Self, heaps: [*]const objc.Object, count: objc.UInteger) void {
        return self.object.msgSend(void, "useHeaps:count:", .{ heaps, count });
    }

    /// `-[MTLRenderCommandEncoder useHeap:stages:]`
    pub fn useHeapStages(self: Self, heap: objc.Object, stages: RenderStages) void {
        return self.object.msgSend(void, "useHeap:stages:", .{ heap, stages });
    }

    /// `-[MTLRenderCommandEncoder useHeaps:count:stages:]`
    pub fn useHeapsCountStages(self: Self, heaps: [*]const objc.Object, count: objc.UInteger, stages: RenderStages) void {
        return self.object.msgSend(void, "useHeaps:count:stages:", .{ heaps, count, stages });
    }

    /// `-[MTLRenderCommandEncoder executeCommandsInBuffer:withRange:]`
    pub fn executeCommandsInBufferWithRange(self: Self, indirect_command_buffer: objc.Object, execution_range: objc.Range) void {
        return self.object.msgSend(void, "executeCommandsInBuffer:withRange:", .{ indirect_command_buffer, execution_range });
    }

    /// `-[MTLRenderCommandEncoder executeCommandsInBuffer:indirectBuffer:indirectBufferOffset:]`
    pub fn executeCommandsInBufferIndirectBufferIndirectBufferOffset(self: Self, indirect_commandbuffer: objc.Object, indirect_range_buffer: Buffer, indirect_buffer_offset: objc.UInteger) void {
        return self.object.msgSend(void, "executeCommandsInBuffer:indirectBuffer:indirectBufferOffset:", .{ indirect_commandbuffer, indirect_range_buffer, indirect_buffer_offset });
    }

    /// `-[MTLRenderCommandEncoder memoryBarrierWithScope:afterStages:beforeStages:]`
    pub fn memoryBarrierWithScopeAfterStagesBeforeStages(self: Self, scope: BarrierScope, after: RenderStages, before: RenderStages) void {
        return self.object.msgSend(void, "memoryBarrierWithScope:afterStages:beforeStages:", .{ scope, after, before });
    }

    /// `-[MTLRenderCommandEncoder memoryBarrierWithResources:count:afterStages:beforeStages:]`
    pub fn memoryBarrierWithResourcesCountAfterStagesBeforeStages(self: Self, resources: [*]const Resource, count: objc.UInteger, after: RenderStages, before: RenderStages) void {
        return self.object.msgSend(void, "memoryBarrierWithResources:count:afterStages:beforeStages:", .{ resources, count, after, before });
    }

    /// `-[MTLRenderCommandEncoder sampleCountersInBuffer:atSampleIndex:withBarrier:]`
    pub fn sampleCountersInBufferAtSampleIndexWithBarrier(self: Self, sample_buffer: objc.Object, sample_index: objc.UInteger, barrier: bool) void {
        return self.object.msgSend(void, "sampleCountersInBuffer:atSampleIndex:withBarrier:", .{ sample_buffer, sample_index, barrier });
    }

    /// `-[MTLRenderCommandEncoder setColorAttachmentMap:]`
    pub fn setColorAttachmentMap(self: Self, mapping: ?objc.Object) void {
        return self.object.msgSend(void, "setColorAttachmentMap:", .{mapping});
    }

    /// `-[MTLRenderCommandEncoder tileWidth]`
    pub fn tileWidth(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "tileWidth", .{});
    }

    /// `-[MTLRenderCommandEncoder tileHeight]`
    pub fn tileHeight(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "tileHeight", .{});
    }

    /// `-[MTLCommandEncoder endEncoding]`
    pub fn endEncoding(self: Self) void {
        return self.object.msgSend(void, "endEncoding", .{});
    }

    /// `-[MTLCommandEncoder barrierAfterQueueStages:beforeStages:]`
    pub fn barrierAfterQueueStagesBeforeStages(self: Self, after_queue_stages: Stages, before_stages: Stages) void {
        return self.object.msgSend(void, "barrierAfterQueueStages:beforeStages:", .{ after_queue_stages, before_stages });
    }

    /// `-[MTLCommandEncoder insertDebugSignpost:]`
    pub fn insertDebugSignpost(self: Self, string: foundation.String) void {
        return self.object.msgSend(void, "insertDebugSignpost:", .{string});
    }

    /// `-[MTLCommandEncoder pushDebugGroup:]`
    pub fn pushDebugGroup(self: Self, string: foundation.String) void {
        return self.object.msgSend(void, "pushDebugGroup:", .{string});
    }

    /// `-[MTLCommandEncoder popDebugGroup]`
    pub fn popDebugGroup(self: Self) void {
        return self.object.msgSend(void, "popDebugGroup", .{});
    }

    /// `-[MTLCommandEncoder device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLCommandEncoder label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLCommandEncoder setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-setRenderPipelineState:" = fn (RenderPipelineState) void;
        pub const @"-setVertexBytes:length:atIndex:" = fn (?*const anyopaque, objc.UInteger, objc.UInteger) void;
        pub const @"-setVertexBuffer:offset:atIndex:" = fn (?Buffer, objc.UInteger, objc.UInteger) void;
        pub const @"-setVertexBufferOffset:atIndex:" = fn (objc.UInteger, objc.UInteger) void;
        pub const @"-setVertexBuffers:offsets:withRange:" = fn ([*]const objc.Nullable(Buffer), ?[*]const objc.UInteger, objc.Range) void;
        pub const @"-setVertexBuffer:offset:attributeStride:atIndex:" = fn (?Buffer, objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-setVertexBuffers:offsets:attributeStrides:withRange:" = fn ([*]const objc.Nullable(Buffer), ?[*]const objc.UInteger, ?[*]const objc.UInteger, objc.Range) void;
        pub const @"-setVertexBufferOffset:attributeStride:atIndex:" = fn (objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-setVertexBytes:length:attributeStride:atIndex:" = fn (?*const anyopaque, objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-setVertexTexture:atIndex:" = fn (?Texture, objc.UInteger) void;
        pub const @"-setVertexTextures:withRange:" = fn ([*]const objc.Nullable(Texture), objc.Range) void;
        pub const @"-setVertexSamplerState:atIndex:" = fn (?SamplerState, objc.UInteger) void;
        pub const @"-setVertexSamplerStates:withRange:" = fn ([*]const objc.Nullable(SamplerState), objc.Range) void;
        pub const @"-setVertexSamplerState:lodMinClamp:lodMaxClamp:atIndex:" = fn (?SamplerState, f32, f32, objc.UInteger) void;
        pub const @"-setVertexSamplerStates:lodMinClamps:lodMaxClamps:withRange:" = fn ([*]const objc.Nullable(SamplerState), ?[*]const f32, ?[*]const f32, objc.Range) void;
        pub const @"-setVertexVisibleFunctionTable:atBufferIndex:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-setVertexVisibleFunctionTables:withBufferRange:" = fn ([*]const objc.Nullable(objc.Object), objc.Range) void;
        pub const @"-setVertexIntersectionFunctionTable:atBufferIndex:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-setVertexIntersectionFunctionTables:withBufferRange:" = fn ([*]const objc.Nullable(objc.Object), objc.Range) void;
        pub const @"-setVertexAccelerationStructure:atBufferIndex:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-setViewport:" = fn (Viewport) void;
        pub const @"-setViewports:count:" = fn (?[*]const Viewport, objc.UInteger) void;
        pub const @"-setFrontFacingWinding:" = fn (Winding) void;
        pub const @"-setVertexAmplificationCount:viewMappings:" = fn (objc.UInteger, ?objc.Object) void;
        pub const @"-setCullMode:" = fn (CullMode) void;
        pub const @"-setDepthClipMode:" = fn (DepthClipMode) void;
        pub const @"-setDepthBias:slopeScale:clamp:" = fn (f32, f32, f32) void;
        pub const @"-setDepthTestMinBound:maxBound:" = fn (f32, f32) void;
        pub const @"-setScissorRect:" = fn (ScissorRect) void;
        pub const @"-setScissorRects:count:" = fn (?[*]const ScissorRect, objc.UInteger) void;
        pub const @"-setTriangleFillMode:" = fn (TriangleFillMode) void;
        pub const @"-setFragmentBytes:length:atIndex:" = fn (?*const anyopaque, objc.UInteger, objc.UInteger) void;
        pub const @"-setFragmentBuffer:offset:atIndex:" = fn (?Buffer, objc.UInteger, objc.UInteger) void;
        pub const @"-setFragmentBufferOffset:atIndex:" = fn (objc.UInteger, objc.UInteger) void;
        pub const @"-setFragmentBuffers:offsets:withRange:" = fn ([*]const objc.Nullable(Buffer), ?[*]const objc.UInteger, objc.Range) void;
        pub const @"-setFragmentTexture:atIndex:" = fn (?Texture, objc.UInteger) void;
        pub const @"-setFragmentTextures:withRange:" = fn ([*]const objc.Nullable(Texture), objc.Range) void;
        pub const @"-setFragmentSamplerState:atIndex:" = fn (?SamplerState, objc.UInteger) void;
        pub const @"-setFragmentSamplerStates:withRange:" = fn ([*]const objc.Nullable(SamplerState), objc.Range) void;
        pub const @"-setFragmentSamplerState:lodMinClamp:lodMaxClamp:atIndex:" = fn (?SamplerState, f32, f32, objc.UInteger) void;
        pub const @"-setFragmentSamplerStates:lodMinClamps:lodMaxClamps:withRange:" = fn ([*]const objc.Nullable(SamplerState), ?[*]const f32, ?[*]const f32, objc.Range) void;
        pub const @"-setFragmentVisibleFunctionTable:atBufferIndex:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-setFragmentVisibleFunctionTables:withBufferRange:" = fn ([*]const objc.Nullable(objc.Object), objc.Range) void;
        pub const @"-setFragmentIntersectionFunctionTable:atBufferIndex:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-setFragmentIntersectionFunctionTables:withBufferRange:" = fn ([*]const objc.Nullable(objc.Object), objc.Range) void;
        pub const @"-setFragmentAccelerationStructure:atBufferIndex:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-setBlendColorRed:green:blue:alpha:" = fn (f32, f32, f32, f32) void;
        pub const @"-setDepthStencilState:" = fn (?DepthStencilState) void;
        pub const @"-setStencilReferenceValue:" = fn (u32) void;
        pub const @"-setStencilFrontReferenceValue:backReferenceValue:" = fn (u32, u32) void;
        pub const @"-setVisibilityResultMode:offset:" = fn (VisibilityResultMode, objc.UInteger) void;
        pub const @"-setColorStoreAction:atIndex:" = fn (StoreAction, objc.UInteger) void;
        pub const @"-setDepthStoreAction:" = fn (StoreAction) void;
        pub const @"-setStencilStoreAction:" = fn (StoreAction) void;
        pub const @"-setColorStoreActionOptions:atIndex:" = fn (StoreActionOptions, objc.UInteger) void;
        pub const @"-setDepthStoreActionOptions:" = fn (StoreActionOptions) void;
        pub const @"-setStencilStoreActionOptions:" = fn (StoreActionOptions) void;
        pub const @"-setObjectBytes:length:atIndex:" = fn (?*const anyopaque, objc.UInteger, objc.UInteger) void;
        pub const @"-setObjectBuffer:offset:atIndex:" = fn (?Buffer, objc.UInteger, objc.UInteger) void;
        pub const @"-setObjectBufferOffset:atIndex:" = fn (objc.UInteger, objc.UInteger) void;
        pub const @"-setObjectBuffers:offsets:withRange:" = fn ([*]const objc.Nullable(Buffer), ?[*]const objc.UInteger, objc.Range) void;
        pub const @"-setObjectTexture:atIndex:" = fn (?Texture, objc.UInteger) void;
        pub const @"-setObjectTextures:withRange:" = fn ([*]const objc.Nullable(Texture), objc.Range) void;
        pub const @"-setObjectSamplerState:atIndex:" = fn (?SamplerState, objc.UInteger) void;
        pub const @"-setObjectSamplerStates:withRange:" = fn ([*]const objc.Nullable(SamplerState), objc.Range) void;
        pub const @"-setObjectSamplerState:lodMinClamp:lodMaxClamp:atIndex:" = fn (?SamplerState, f32, f32, objc.UInteger) void;
        pub const @"-setObjectSamplerStates:lodMinClamps:lodMaxClamps:withRange:" = fn ([*]const objc.Nullable(SamplerState), ?[*]const f32, ?[*]const f32, objc.Range) void;
        pub const @"-setObjectThreadgroupMemoryLength:atIndex:" = fn (objc.UInteger, objc.UInteger) void;
        pub const @"-setMeshBytes:length:atIndex:" = fn (?*const anyopaque, objc.UInteger, objc.UInteger) void;
        pub const @"-setMeshBuffer:offset:atIndex:" = fn (?Buffer, objc.UInteger, objc.UInteger) void;
        pub const @"-setMeshBufferOffset:atIndex:" = fn (objc.UInteger, objc.UInteger) void;
        pub const @"-setMeshBuffers:offsets:withRange:" = fn ([*]const objc.Nullable(Buffer), ?[*]const objc.UInteger, objc.Range) void;
        pub const @"-setMeshTexture:atIndex:" = fn (?Texture, objc.UInteger) void;
        pub const @"-setMeshTextures:withRange:" = fn ([*]const objc.Nullable(Texture), objc.Range) void;
        pub const @"-setMeshSamplerState:atIndex:" = fn (?SamplerState, objc.UInteger) void;
        pub const @"-setMeshSamplerStates:withRange:" = fn ([*]const objc.Nullable(SamplerState), objc.Range) void;
        pub const @"-setMeshSamplerState:lodMinClamp:lodMaxClamp:atIndex:" = fn (?SamplerState, f32, f32, objc.UInteger) void;
        pub const @"-setMeshSamplerStates:lodMinClamps:lodMaxClamps:withRange:" = fn ([*]const objc.Nullable(SamplerState), ?[*]const f32, ?[*]const f32, objc.Range) void;
        pub const @"-drawMeshThreadgroups:threadsPerObjectThreadgroup:threadsPerMeshThreadgroup:" = fn (Size, Size, Size) void;
        pub const @"-drawMeshThreads:threadsPerObjectThreadgroup:threadsPerMeshThreadgroup:" = fn (Size, Size, Size) void;
        pub const @"-drawMeshThreadgroupsWithIndirectBuffer:indirectBufferOffset:threadsPerObjectThreadgroup:threadsPerMeshThreadgroup:" = fn (Buffer, objc.UInteger, Size, Size) void;
        pub const @"-drawPrimitives:vertexStart:vertexCount:instanceCount:" = fn (PrimitiveType, objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-drawPrimitives:vertexStart:vertexCount:" = fn (PrimitiveType, objc.UInteger, objc.UInteger) void;
        pub const @"-drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:instanceCount:" = fn (PrimitiveType, objc.UInteger, IndexType, Buffer, objc.UInteger, objc.UInteger) void;
        pub const @"-drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:" = fn (PrimitiveType, objc.UInteger, IndexType, Buffer, objc.UInteger) void;
        pub const @"-drawPrimitives:vertexStart:vertexCount:instanceCount:baseInstance:" = fn (PrimitiveType, objc.UInteger, objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-drawIndexedPrimitives:indexCount:indexType:indexBuffer:indexBufferOffset:instanceCount:baseVertex:baseInstance:" = fn (PrimitiveType, objc.UInteger, IndexType, Buffer, objc.UInteger, objc.UInteger, objc.Integer, objc.UInteger) void;
        pub const @"-drawPrimitives:indirectBuffer:indirectBufferOffset:" = fn (PrimitiveType, Buffer, objc.UInteger) void;
        pub const @"-drawIndexedPrimitives:indexType:indexBuffer:indexBufferOffset:indirectBuffer:indirectBufferOffset:" = fn (PrimitiveType, IndexType, Buffer, objc.UInteger, Buffer, objc.UInteger) void;
        pub const @"-textureBarrier" = fn () void;
        pub const @"-updateFence:afterStages:" = fn (objc.Object, RenderStages) void;
        pub const @"-waitForFence:beforeStages:" = fn (objc.Object, RenderStages) void;
        pub const @"-setTessellationFactorBuffer:offset:instanceStride:" = fn (?Buffer, objc.UInteger, objc.UInteger) void;
        pub const @"-setTessellationFactorScale:" = fn (f32) void;
        pub const @"-drawPatches:patchStart:patchCount:patchIndexBuffer:patchIndexBufferOffset:instanceCount:baseInstance:" = fn (objc.UInteger, objc.UInteger, objc.UInteger, ?Buffer, objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-drawPatches:patchIndexBuffer:patchIndexBufferOffset:indirectBuffer:indirectBufferOffset:" = fn (objc.UInteger, ?Buffer, objc.UInteger, Buffer, objc.UInteger) void;
        pub const @"-drawIndexedPatches:patchStart:patchCount:patchIndexBuffer:patchIndexBufferOffset:controlPointIndexBuffer:controlPointIndexBufferOffset:instanceCount:baseInstance:" = fn (objc.UInteger, objc.UInteger, objc.UInteger, ?Buffer, objc.UInteger, Buffer, objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-drawIndexedPatches:patchIndexBuffer:patchIndexBufferOffset:controlPointIndexBuffer:controlPointIndexBufferOffset:indirectBuffer:indirectBufferOffset:" = fn (objc.UInteger, ?Buffer, objc.UInteger, Buffer, objc.UInteger, Buffer, objc.UInteger) void;
        pub const @"-setTileBytes:length:atIndex:" = fn (?*const anyopaque, objc.UInteger, objc.UInteger) void;
        pub const @"-setTileBuffer:offset:atIndex:" = fn (?Buffer, objc.UInteger, objc.UInteger) void;
        pub const @"-setTileBufferOffset:atIndex:" = fn (objc.UInteger, objc.UInteger) void;
        pub const @"-setTileBuffers:offsets:withRange:" = fn ([*]const objc.Nullable(Buffer), ?[*]const objc.UInteger, objc.Range) void;
        pub const @"-setTileTexture:atIndex:" = fn (?Texture, objc.UInteger) void;
        pub const @"-setTileTextures:withRange:" = fn ([*]const objc.Nullable(Texture), objc.Range) void;
        pub const @"-setTileSamplerState:atIndex:" = fn (?SamplerState, objc.UInteger) void;
        pub const @"-setTileSamplerStates:withRange:" = fn ([*]const objc.Nullable(SamplerState), objc.Range) void;
        pub const @"-setTileSamplerState:lodMinClamp:lodMaxClamp:atIndex:" = fn (?SamplerState, f32, f32, objc.UInteger) void;
        pub const @"-setTileSamplerStates:lodMinClamps:lodMaxClamps:withRange:" = fn ([*]const objc.Nullable(SamplerState), ?[*]const f32, ?[*]const f32, objc.Range) void;
        pub const @"-setTileVisibleFunctionTable:atBufferIndex:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-setTileVisibleFunctionTables:withBufferRange:" = fn ([*]const objc.Nullable(objc.Object), objc.Range) void;
        pub const @"-setTileIntersectionFunctionTable:atBufferIndex:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-setTileIntersectionFunctionTables:withBufferRange:" = fn ([*]const objc.Nullable(objc.Object), objc.Range) void;
        pub const @"-setTileAccelerationStructure:atBufferIndex:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-dispatchThreadsPerTile:" = fn (Size) void;
        pub const @"-setThreadgroupMemoryLength:offset:atIndex:" = fn (objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-useResource:usage:" = fn (Resource, ResourceUsage) void;
        pub const @"-useResources:count:usage:" = fn ([*]const Resource, objc.UInteger, ResourceUsage) void;
        pub const @"-useResource:usage:stages:" = fn (Resource, ResourceUsage, RenderStages) void;
        pub const @"-useResources:count:usage:stages:" = fn ([*]const Resource, objc.UInteger, ResourceUsage, RenderStages) void;
        pub const @"-useHeap:" = fn (objc.Object) void;
        pub const @"-useHeaps:count:" = fn ([*]const objc.Object, objc.UInteger) void;
        pub const @"-useHeap:stages:" = fn (objc.Object, RenderStages) void;
        pub const @"-useHeaps:count:stages:" = fn ([*]const objc.Object, objc.UInteger, RenderStages) void;
        pub const @"-executeCommandsInBuffer:withRange:" = fn (objc.Object, objc.Range) void;
        pub const @"-executeCommandsInBuffer:indirectBuffer:indirectBufferOffset:" = fn (objc.Object, Buffer, objc.UInteger) void;
        pub const @"-memoryBarrierWithScope:afterStages:beforeStages:" = fn (BarrierScope, RenderStages, RenderStages) void;
        pub const @"-memoryBarrierWithResources:count:afterStages:beforeStages:" = fn ([*]const Resource, objc.UInteger, RenderStages, RenderStages) void;
        pub const @"-sampleCountersInBuffer:atSampleIndex:withBarrier:" = fn (objc.Object, objc.UInteger, bool) void;
        pub const @"-setColorAttachmentMap:" = fn (?objc.Object) void;
        pub const @"-tileWidth" = fn () objc.UInteger;
        pub const @"-tileHeight" = fn () objc.UInteger;
    };
};

/// An object conforming to `MTLComputeCommandEncoder`, which extends `MTLCommandEncoder`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const ComputeCommandEncoder = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = CommandEncoder;
    pub const protocol_name = "MTLComputeCommandEncoder";

    /// An object that came from elsewhere, taken to conform to `MTLComputeCommandEncoder`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLComputeCommandEncoder setComputePipelineState:]`
    pub fn setComputePipelineState(self: Self, state: ComputePipelineState) void {
        return self.object.msgSend(void, "setComputePipelineState:", .{state});
    }

    /// `-[MTLComputeCommandEncoder setBytes:length:atIndex:]`
    pub fn setBytesLengthAtIndex(self: Self, bytes: ?*const anyopaque, length: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setBytes:length:atIndex:", .{ bytes, length, index });
    }

    /// `-[MTLComputeCommandEncoder setBuffer:offset:atIndex:]`
    pub fn setBufferOffsetAtIndex(self: Self, buffer: ?Buffer, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setBuffer:offset:atIndex:", .{ buffer, offset, index });
    }

    /// `-[MTLComputeCommandEncoder setBufferOffset:atIndex:]`
    pub fn setBufferOffsetAtIndex_(self: Self, offset: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setBufferOffset:atIndex:", .{ offset, index });
    }

    /// `-[MTLComputeCommandEncoder setBuffers:offsets:withRange:]`
    pub fn setBuffersOffsetsWithRange(self: Self, buffers: [*]const objc.Nullable(Buffer), offsets: ?[*]const objc.UInteger, range: objc.Range) void {
        return self.object.msgSend(void, "setBuffers:offsets:withRange:", .{ buffers, offsets, range });
    }

    /// `-[MTLComputeCommandEncoder setBuffer:offset:attributeStride:atIndex:]`
    pub fn setBufferOffsetAttributeStrideAtIndex(self: Self, buffer: Buffer, offset: objc.UInteger, stride: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setBuffer:offset:attributeStride:atIndex:", .{ buffer, offset, stride, index });
    }

    /// `-[MTLComputeCommandEncoder setBuffers:offsets:attributeStrides:withRange:]`
    pub fn setBuffersOffsetsAttributeStridesWithRange(self: Self, buffers: [*]const objc.Nullable(Buffer), offsets: ?[*]const objc.UInteger, strides: ?[*]const objc.UInteger, range: objc.Range) void {
        return self.object.msgSend(void, "setBuffers:offsets:attributeStrides:withRange:", .{ buffers, offsets, strides, range });
    }

    /// `-[MTLComputeCommandEncoder setBufferOffset:attributeStride:atIndex:]`
    pub fn setBufferOffsetAttributeStrideAtIndex_(self: Self, offset: objc.UInteger, stride: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setBufferOffset:attributeStride:atIndex:", .{ offset, stride, index });
    }

    /// `-[MTLComputeCommandEncoder setBytes:length:attributeStride:atIndex:]`
    pub fn setBytesLengthAttributeStrideAtIndex(self: Self, bytes: ?*const anyopaque, length: objc.UInteger, stride: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setBytes:length:attributeStride:atIndex:", .{ bytes, length, stride, index });
    }

    /// `-[MTLComputeCommandEncoder setVisibleFunctionTable:atBufferIndex:]`
    pub fn setVisibleFunctionTableAtBufferIndex(self: Self, visible_function_table: ?objc.Object, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setVisibleFunctionTable:atBufferIndex:", .{ visible_function_table, buffer_index });
    }

    /// `-[MTLComputeCommandEncoder setVisibleFunctionTables:withBufferRange:]`
    pub fn setVisibleFunctionTablesWithBufferRange(self: Self, visible_function_tables: [*]const objc.Nullable(objc.Object), range: objc.Range) void {
        return self.object.msgSend(void, "setVisibleFunctionTables:withBufferRange:", .{ visible_function_tables, range });
    }

    /// `-[MTLComputeCommandEncoder setIntersectionFunctionTable:atBufferIndex:]`
    pub fn setIntersectionFunctionTableAtBufferIndex(self: Self, intersection_function_table: ?objc.Object, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setIntersectionFunctionTable:atBufferIndex:", .{ intersection_function_table, buffer_index });
    }

    /// `-[MTLComputeCommandEncoder setIntersectionFunctionTables:withBufferRange:]`
    pub fn setIntersectionFunctionTablesWithBufferRange(self: Self, intersection_function_tables: [*]const objc.Nullable(objc.Object), range: objc.Range) void {
        return self.object.msgSend(void, "setIntersectionFunctionTables:withBufferRange:", .{ intersection_function_tables, range });
    }

    /// `-[MTLComputeCommandEncoder setAccelerationStructure:atBufferIndex:]`
    pub fn setAccelerationStructureAtBufferIndex(self: Self, acceleration_structure: ?objc.Object, buffer_index: objc.UInteger) void {
        return self.object.msgSend(void, "setAccelerationStructure:atBufferIndex:", .{ acceleration_structure, buffer_index });
    }

    /// `-[MTLComputeCommandEncoder setTexture:atIndex:]`
    pub fn setTextureAtIndex(self: Self, texture: ?Texture, index: objc.UInteger) void {
        return self.object.msgSend(void, "setTexture:atIndex:", .{ texture, index });
    }

    /// `-[MTLComputeCommandEncoder setTextures:withRange:]`
    pub fn setTexturesWithRange(self: Self, textures: [*]const objc.Nullable(Texture), range: objc.Range) void {
        return self.object.msgSend(void, "setTextures:withRange:", .{ textures, range });
    }

    /// `-[MTLComputeCommandEncoder setSamplerState:atIndex:]`
    pub fn setSamplerStateAtIndex(self: Self, sampler: ?SamplerState, index: objc.UInteger) void {
        return self.object.msgSend(void, "setSamplerState:atIndex:", .{ sampler, index });
    }

    /// `-[MTLComputeCommandEncoder setSamplerStates:withRange:]`
    pub fn setSamplerStatesWithRange(self: Self, samplers: [*]const objc.Nullable(SamplerState), range: objc.Range) void {
        return self.object.msgSend(void, "setSamplerStates:withRange:", .{ samplers, range });
    }

    /// `-[MTLComputeCommandEncoder setSamplerState:lodMinClamp:lodMaxClamp:atIndex:]`
    pub fn setSamplerStateLodMinClampLodMaxClampAtIndex(self: Self, sampler: ?SamplerState, lod_min_clamp: f32, lod_max_clamp: f32, index: objc.UInteger) void {
        return self.object.msgSend(void, "setSamplerState:lodMinClamp:lodMaxClamp:atIndex:", .{ sampler, lod_min_clamp, lod_max_clamp, index });
    }

    /// `-[MTLComputeCommandEncoder setSamplerStates:lodMinClamps:lodMaxClamps:withRange:]`
    pub fn setSamplerStatesLodMinClampsLodMaxClampsWithRange(self: Self, samplers: [*]const objc.Nullable(SamplerState), lod_min_clamps: ?[*]const f32, lod_max_clamps: ?[*]const f32, range: objc.Range) void {
        return self.object.msgSend(void, "setSamplerStates:lodMinClamps:lodMaxClamps:withRange:", .{ samplers, lod_min_clamps, lod_max_clamps, range });
    }

    /// `-[MTLComputeCommandEncoder setThreadgroupMemoryLength:atIndex:]`
    pub fn setThreadgroupMemoryLengthAtIndex(self: Self, length: objc.UInteger, index: objc.UInteger) void {
        return self.object.msgSend(void, "setThreadgroupMemoryLength:atIndex:", .{ length, index });
    }

    /// `-[MTLComputeCommandEncoder setImageblockWidth:height:]`
    pub fn setImageblockWidthHeight(self: Self, width: objc.UInteger, height: objc.UInteger) void {
        return self.object.msgSend(void, "setImageblockWidth:height:", .{ width, height });
    }

    /// `-[MTLComputeCommandEncoder setStageInRegion:]`
    pub fn setStageInRegion(self: Self, region: Region) void {
        return self.object.msgSend(void, "setStageInRegion:", .{region});
    }

    /// `-[MTLComputeCommandEncoder setStageInRegionWithIndirectBuffer:indirectBufferOffset:]`
    pub fn setStageInRegionWithIndirectBufferIndirectBufferOffset(self: Self, indirect_buffer: Buffer, indirect_buffer_offset: objc.UInteger) void {
        return self.object.msgSend(void, "setStageInRegionWithIndirectBuffer:indirectBufferOffset:", .{ indirect_buffer, indirect_buffer_offset });
    }

    /// `-[MTLComputeCommandEncoder dispatchThreadgroups:threadsPerThreadgroup:]`
    pub fn dispatchThreadgroupsThreadsPerThreadgroup(self: Self, threadgroups_per_grid: Size, threads_per_threadgroup: Size) void {
        return self.object.msgSend(void, "dispatchThreadgroups:threadsPerThreadgroup:", .{ threadgroups_per_grid, threads_per_threadgroup });
    }

    /// `-[MTLComputeCommandEncoder dispatchThreadgroupsWithIndirectBuffer:indirectBufferOffset:threadsPerThreadgroup:]`
    pub fn dispatchThreadgroupsWithIndirectBufferIndirectBufferOffsetThreadsPerThreadgroup(self: Self, indirect_buffer: Buffer, indirect_buffer_offset: objc.UInteger, threads_per_threadgroup: Size) void {
        return self.object.msgSend(void, "dispatchThreadgroupsWithIndirectBuffer:indirectBufferOffset:threadsPerThreadgroup:", .{ indirect_buffer, indirect_buffer_offset, threads_per_threadgroup });
    }

    /// `-[MTLComputeCommandEncoder dispatchThreads:threadsPerThreadgroup:]`
    pub fn dispatchThreadsThreadsPerThreadgroup(self: Self, threads_per_grid: Size, threads_per_threadgroup: Size) void {
        return self.object.msgSend(void, "dispatchThreads:threadsPerThreadgroup:", .{ threads_per_grid, threads_per_threadgroup });
    }

    /// `-[MTLComputeCommandEncoder updateFence:]`
    pub fn updateFence(self: Self, fence: objc.Object) void {
        return self.object.msgSend(void, "updateFence:", .{fence});
    }

    /// `-[MTLComputeCommandEncoder waitForFence:]`
    pub fn waitForFence(self: Self, fence: objc.Object) void {
        return self.object.msgSend(void, "waitForFence:", .{fence});
    }

    /// `-[MTLComputeCommandEncoder useResource:usage:]`
    pub fn useResourceUsage(self: Self, resource: Resource, usage: ResourceUsage) void {
        return self.object.msgSend(void, "useResource:usage:", .{ resource, usage });
    }

    /// `-[MTLComputeCommandEncoder useResources:count:usage:]`
    pub fn useResourcesCountUsage(self: Self, resources: [*]const Resource, count: objc.UInteger, usage: ResourceUsage) void {
        return self.object.msgSend(void, "useResources:count:usage:", .{ resources, count, usage });
    }

    /// `-[MTLComputeCommandEncoder useHeap:]`
    pub fn useHeap(self: Self, heap: objc.Object) void {
        return self.object.msgSend(void, "useHeap:", .{heap});
    }

    /// `-[MTLComputeCommandEncoder useHeaps:count:]`
    pub fn useHeapsCount(self: Self, heaps: [*]const objc.Object, count: objc.UInteger) void {
        return self.object.msgSend(void, "useHeaps:count:", .{ heaps, count });
    }

    /// `-[MTLComputeCommandEncoder executeCommandsInBuffer:withRange:]`
    pub fn executeCommandsInBufferWithRange(self: Self, indirect_command_buffer: objc.Object, execution_range: objc.Range) void {
        return self.object.msgSend(void, "executeCommandsInBuffer:withRange:", .{ indirect_command_buffer, execution_range });
    }

    /// `-[MTLComputeCommandEncoder executeCommandsInBuffer:indirectBuffer:indirectBufferOffset:]`
    pub fn executeCommandsInBufferIndirectBufferIndirectBufferOffset(self: Self, indirect_commandbuffer: objc.Object, indirect_range_buffer: Buffer, indirect_buffer_offset: objc.UInteger) void {
        return self.object.msgSend(void, "executeCommandsInBuffer:indirectBuffer:indirectBufferOffset:", .{ indirect_commandbuffer, indirect_range_buffer, indirect_buffer_offset });
    }

    /// `-[MTLComputeCommandEncoder memoryBarrierWithScope:]`
    pub fn memoryBarrierWithScope(self: Self, scope: BarrierScope) void {
        return self.object.msgSend(void, "memoryBarrierWithScope:", .{scope});
    }

    /// `-[MTLComputeCommandEncoder memoryBarrierWithResources:count:]`
    pub fn memoryBarrierWithResourcesCount(self: Self, resources: [*]const Resource, count: objc.UInteger) void {
        return self.object.msgSend(void, "memoryBarrierWithResources:count:", .{ resources, count });
    }

    /// `-[MTLComputeCommandEncoder sampleCountersInBuffer:atSampleIndex:withBarrier:]`
    pub fn sampleCountersInBufferAtSampleIndexWithBarrier(self: Self, sample_buffer: objc.Object, sample_index: objc.UInteger, barrier: bool) void {
        return self.object.msgSend(void, "sampleCountersInBuffer:atSampleIndex:withBarrier:", .{ sample_buffer, sample_index, barrier });
    }

    /// `-[MTLComputeCommandEncoder dispatchType]`
    pub fn dispatchType(self: Self) DispatchType {
        return self.object.msgSend(DispatchType, "dispatchType", .{});
    }

    /// `-[MTLCommandEncoder endEncoding]`
    pub fn endEncoding(self: Self) void {
        return self.object.msgSend(void, "endEncoding", .{});
    }

    /// `-[MTLCommandEncoder barrierAfterQueueStages:beforeStages:]`
    pub fn barrierAfterQueueStagesBeforeStages(self: Self, after_queue_stages: Stages, before_stages: Stages) void {
        return self.object.msgSend(void, "barrierAfterQueueStages:beforeStages:", .{ after_queue_stages, before_stages });
    }

    /// `-[MTLCommandEncoder insertDebugSignpost:]`
    pub fn insertDebugSignpost(self: Self, string: foundation.String) void {
        return self.object.msgSend(void, "insertDebugSignpost:", .{string});
    }

    /// `-[MTLCommandEncoder pushDebugGroup:]`
    pub fn pushDebugGroup(self: Self, string: foundation.String) void {
        return self.object.msgSend(void, "pushDebugGroup:", .{string});
    }

    /// `-[MTLCommandEncoder popDebugGroup]`
    pub fn popDebugGroup(self: Self) void {
        return self.object.msgSend(void, "popDebugGroup", .{});
    }

    /// `-[MTLCommandEncoder device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLCommandEncoder label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLCommandEncoder setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-setComputePipelineState:" = fn (ComputePipelineState) void;
        pub const @"-setBytes:length:atIndex:" = fn (?*const anyopaque, objc.UInteger, objc.UInteger) void;
        pub const @"-setBuffer:offset:atIndex:" = fn (?Buffer, objc.UInteger, objc.UInteger) void;
        pub const @"-setBufferOffset:atIndex:" = fn (objc.UInteger, objc.UInteger) void;
        pub const @"-setBuffers:offsets:withRange:" = fn ([*]const objc.Nullable(Buffer), ?[*]const objc.UInteger, objc.Range) void;
        pub const @"-setBuffer:offset:attributeStride:atIndex:" = fn (Buffer, objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-setBuffers:offsets:attributeStrides:withRange:" = fn ([*]const objc.Nullable(Buffer), ?[*]const objc.UInteger, ?[*]const objc.UInteger, objc.Range) void;
        pub const @"-setBufferOffset:attributeStride:atIndex:" = fn (objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-setBytes:length:attributeStride:atIndex:" = fn (?*const anyopaque, objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-setVisibleFunctionTable:atBufferIndex:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-setVisibleFunctionTables:withBufferRange:" = fn ([*]const objc.Nullable(objc.Object), objc.Range) void;
        pub const @"-setIntersectionFunctionTable:atBufferIndex:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-setIntersectionFunctionTables:withBufferRange:" = fn ([*]const objc.Nullable(objc.Object), objc.Range) void;
        pub const @"-setAccelerationStructure:atBufferIndex:" = fn (?objc.Object, objc.UInteger) void;
        pub const @"-setTexture:atIndex:" = fn (?Texture, objc.UInteger) void;
        pub const @"-setTextures:withRange:" = fn ([*]const objc.Nullable(Texture), objc.Range) void;
        pub const @"-setSamplerState:atIndex:" = fn (?SamplerState, objc.UInteger) void;
        pub const @"-setSamplerStates:withRange:" = fn ([*]const objc.Nullable(SamplerState), objc.Range) void;
        pub const @"-setSamplerState:lodMinClamp:lodMaxClamp:atIndex:" = fn (?SamplerState, f32, f32, objc.UInteger) void;
        pub const @"-setSamplerStates:lodMinClamps:lodMaxClamps:withRange:" = fn ([*]const objc.Nullable(SamplerState), ?[*]const f32, ?[*]const f32, objc.Range) void;
        pub const @"-setThreadgroupMemoryLength:atIndex:" = fn (objc.UInteger, objc.UInteger) void;
        pub const @"-setImageblockWidth:height:" = fn (objc.UInteger, objc.UInteger) void;
        pub const @"-setStageInRegion:" = fn (Region) void;
        pub const @"-setStageInRegionWithIndirectBuffer:indirectBufferOffset:" = fn (Buffer, objc.UInteger) void;
        pub const @"-dispatchThreadgroups:threadsPerThreadgroup:" = fn (Size, Size) void;
        pub const @"-dispatchThreadgroupsWithIndirectBuffer:indirectBufferOffset:threadsPerThreadgroup:" = fn (Buffer, objc.UInteger, Size) void;
        pub const @"-dispatchThreads:threadsPerThreadgroup:" = fn (Size, Size) void;
        pub const @"-updateFence:" = fn (objc.Object) void;
        pub const @"-waitForFence:" = fn (objc.Object) void;
        pub const @"-useResource:usage:" = fn (Resource, ResourceUsage) void;
        pub const @"-useResources:count:usage:" = fn ([*]const Resource, objc.UInteger, ResourceUsage) void;
        pub const @"-useHeap:" = fn (objc.Object) void;
        pub const @"-useHeaps:count:" = fn ([*]const objc.Object, objc.UInteger) void;
        pub const @"-executeCommandsInBuffer:withRange:" = fn (objc.Object, objc.Range) void;
        pub const @"-executeCommandsInBuffer:indirectBuffer:indirectBufferOffset:" = fn (objc.Object, Buffer, objc.UInteger) void;
        pub const @"-memoryBarrierWithScope:" = fn (BarrierScope) void;
        pub const @"-memoryBarrierWithResources:count:" = fn ([*]const Resource, objc.UInteger) void;
        pub const @"-sampleCountersInBuffer:atSampleIndex:withBarrier:" = fn (objc.Object, objc.UInteger, bool) void;
        pub const @"-dispatchType" = fn () DispatchType;
    };
};

/// An object conforming to `MTLBlitCommandEncoder`, which extends `MTLCommandEncoder`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const BlitCommandEncoder = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = CommandEncoder;
    pub const protocol_name = "MTLBlitCommandEncoder";

    /// An object that came from elsewhere, taken to conform to `MTLBlitCommandEncoder`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLBlitCommandEncoder synchronizeResource:]`
    pub fn synchronizeResource(self: Self, resource: Resource) void {
        return self.object.msgSend(void, "synchronizeResource:", .{resource});
    }

    /// `-[MTLBlitCommandEncoder synchronizeTexture:slice:level:]`
    pub fn synchronizeTextureSliceLevel(self: Self, texture: Texture, slice: objc.UInteger, level: objc.UInteger) void {
        return self.object.msgSend(void, "synchronizeTexture:slice:level:", .{ texture, slice, level });
    }

    /// `-[MTLBlitCommandEncoder copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:]`
    pub fn copyFromTextureSourceSliceSourceLevelSourceOriginSourceSizeToTextureDestinationSliceDestinationLevelDestinationOrigin(self: Self, source_texture: Texture, source_slice: objc.UInteger, source_level: objc.UInteger, source_origin: Origin, source_size: Size, destination_texture: Texture, destination_slice: objc.UInteger, destination_level: objc.UInteger, destination_origin: Origin) void {
        return self.object.msgSend(void, "copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:", .{ source_texture, source_slice, source_level, source_origin, source_size, destination_texture, destination_slice, destination_level, destination_origin });
    }

    /// `-[MTLBlitCommandEncoder copyFromBuffer:sourceOffset:sourceBytesPerRow:sourceBytesPerImage:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:]`
    pub fn copyFromBufferSourceOffsetSourceBytesPerRowSourceBytesPerImageSourceSizeToTextureDestinationSliceDestinationLevelDestinationOrigin(self: Self, source_buffer: Buffer, source_offset: objc.UInteger, source_bytes_per_row: objc.UInteger, source_bytes_per_image: objc.UInteger, source_size: Size, destination_texture: Texture, destination_slice: objc.UInteger, destination_level: objc.UInteger, destination_origin: Origin) void {
        return self.object.msgSend(void, "copyFromBuffer:sourceOffset:sourceBytesPerRow:sourceBytesPerImage:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:", .{ source_buffer, source_offset, source_bytes_per_row, source_bytes_per_image, source_size, destination_texture, destination_slice, destination_level, destination_origin });
    }

    /// `-[MTLBlitCommandEncoder copyFromBuffer:sourceOffset:sourceBytesPerRow:sourceBytesPerImage:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:options:]`
    pub fn copyFromBufferSourceOffsetSourceBytesPerRowSourceBytesPerImageSourceSizeToTextureDestinationSliceDestinationLevelDestinationOriginOptions(self: Self, source_buffer: Buffer, source_offset: objc.UInteger, source_bytes_per_row: objc.UInteger, source_bytes_per_image: objc.UInteger, source_size: Size, destination_texture: Texture, destination_slice: objc.UInteger, destination_level: objc.UInteger, destination_origin: Origin, options: BlitOption) void {
        return self.object.msgSend(void, "copyFromBuffer:sourceOffset:sourceBytesPerRow:sourceBytesPerImage:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:options:", .{ source_buffer, source_offset, source_bytes_per_row, source_bytes_per_image, source_size, destination_texture, destination_slice, destination_level, destination_origin, options });
    }

    /// `-[MTLBlitCommandEncoder copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toBuffer:destinationOffset:destinationBytesPerRow:destinationBytesPerImage:]`
    pub fn copyFromTextureSourceSliceSourceLevelSourceOriginSourceSizeToBufferDestinationOffsetDestinationBytesPerRowDestinationBytesPerImage(self: Self, source_texture: Texture, source_slice: objc.UInteger, source_level: objc.UInteger, source_origin: Origin, source_size: Size, destination_buffer: Buffer, destination_offset: objc.UInteger, destination_bytes_per_row: objc.UInteger, destination_bytes_per_image: objc.UInteger) void {
        return self.object.msgSend(void, "copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toBuffer:destinationOffset:destinationBytesPerRow:destinationBytesPerImage:", .{ source_texture, source_slice, source_level, source_origin, source_size, destination_buffer, destination_offset, destination_bytes_per_row, destination_bytes_per_image });
    }

    /// `-[MTLBlitCommandEncoder copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toBuffer:destinationOffset:destinationBytesPerRow:destinationBytesPerImage:options:]`
    pub fn copyFromTextureSourceSliceSourceLevelSourceOriginSourceSizeToBufferDestinationOffsetDestinationBytesPerRowDestinationBytesPerImageOptions(self: Self, source_texture: Texture, source_slice: objc.UInteger, source_level: objc.UInteger, source_origin: Origin, source_size: Size, destination_buffer: Buffer, destination_offset: objc.UInteger, destination_bytes_per_row: objc.UInteger, destination_bytes_per_image: objc.UInteger, options: BlitOption) void {
        return self.object.msgSend(void, "copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toBuffer:destinationOffset:destinationBytesPerRow:destinationBytesPerImage:options:", .{ source_texture, source_slice, source_level, source_origin, source_size, destination_buffer, destination_offset, destination_bytes_per_row, destination_bytes_per_image, options });
    }

    /// `-[MTLBlitCommandEncoder generateMipmapsForTexture:]`
    pub fn generateMipmapsForTexture(self: Self, texture: Texture) void {
        return self.object.msgSend(void, "generateMipmapsForTexture:", .{texture});
    }

    /// `-[MTLBlitCommandEncoder fillBuffer:range:value:]`
    pub fn fillBufferRangeValue(self: Self, buffer: Buffer, range: objc.Range, value: u8) void {
        return self.object.msgSend(void, "fillBuffer:range:value:", .{ buffer, range, value });
    }

    /// `-[MTLBlitCommandEncoder copyFromTexture:sourceSlice:sourceLevel:toTexture:destinationSlice:destinationLevel:sliceCount:levelCount:]`
    pub fn copyFromTextureSourceSliceSourceLevelToTextureDestinationSliceDestinationLevelSliceCountLevelCount(self: Self, source_texture: Texture, source_slice: objc.UInteger, source_level: objc.UInteger, destination_texture: Texture, destination_slice: objc.UInteger, destination_level: objc.UInteger, slice_count: objc.UInteger, level_count: objc.UInteger) void {
        return self.object.msgSend(void, "copyFromTexture:sourceSlice:sourceLevel:toTexture:destinationSlice:destinationLevel:sliceCount:levelCount:", .{ source_texture, source_slice, source_level, destination_texture, destination_slice, destination_level, slice_count, level_count });
    }

    /// `-[MTLBlitCommandEncoder copyFromTexture:toTexture:]`
    pub fn copyFromTextureToTexture(self: Self, source_texture: Texture, destination_texture: Texture) void {
        return self.object.msgSend(void, "copyFromTexture:toTexture:", .{ source_texture, destination_texture });
    }

    /// `-[MTLBlitCommandEncoder copyFromBuffer:sourceOffset:toBuffer:destinationOffset:size:]`
    pub fn copyFromBufferSourceOffsetToBufferDestinationOffsetSize(self: Self, source_buffer: Buffer, source_offset: objc.UInteger, destination_buffer: Buffer, destination_offset: objc.UInteger, size: objc.UInteger) void {
        return self.object.msgSend(void, "copyFromBuffer:sourceOffset:toBuffer:destinationOffset:size:", .{ source_buffer, source_offset, destination_buffer, destination_offset, size });
    }

    /// `-[MTLBlitCommandEncoder updateFence:]`
    pub fn updateFence(self: Self, fence: objc.Object) void {
        return self.object.msgSend(void, "updateFence:", .{fence});
    }

    /// `-[MTLBlitCommandEncoder waitForFence:]`
    pub fn waitForFence(self: Self, fence: objc.Object) void {
        return self.object.msgSend(void, "waitForFence:", .{fence});
    }

    /// `-[MTLBlitCommandEncoder getTextureAccessCounters:region:mipLevel:slice:resetCounters:countersBuffer:countersBufferOffset:]`
    pub fn getTextureAccessCountersRegionMipLevelSliceResetCountersCountersBufferCountersBufferOffset(self: Self, texture: Texture, region: Region, mip_level: objc.UInteger, slice: objc.UInteger, reset_counters: bool, counters_buffer: Buffer, counters_buffer_offset: objc.UInteger) void {
        return self.object.msgSend(void, "getTextureAccessCounters:region:mipLevel:slice:resetCounters:countersBuffer:countersBufferOffset:", .{ texture, region, mip_level, slice, reset_counters, counters_buffer, counters_buffer_offset });
    }

    /// `-[MTLBlitCommandEncoder resetTextureAccessCounters:region:mipLevel:slice:]`
    pub fn resetTextureAccessCountersRegionMipLevelSlice(self: Self, texture: Texture, region: Region, mip_level: objc.UInteger, slice: objc.UInteger) void {
        return self.object.msgSend(void, "resetTextureAccessCounters:region:mipLevel:slice:", .{ texture, region, mip_level, slice });
    }

    /// `-[MTLBlitCommandEncoder optimizeContentsForGPUAccess:]`
    pub fn optimizeContentsForGPUAccess(self: Self, texture: Texture) void {
        return self.object.msgSend(void, "optimizeContentsForGPUAccess:", .{texture});
    }

    /// `-[MTLBlitCommandEncoder optimizeContentsForGPUAccess:slice:level:]`
    pub fn optimizeContentsForGPUAccessSliceLevel(self: Self, texture: Texture, slice: objc.UInteger, level: objc.UInteger) void {
        return self.object.msgSend(void, "optimizeContentsForGPUAccess:slice:level:", .{ texture, slice, level });
    }

    /// `-[MTLBlitCommandEncoder optimizeContentsForCPUAccess:]`
    pub fn optimizeContentsForCPUAccess(self: Self, texture: Texture) void {
        return self.object.msgSend(void, "optimizeContentsForCPUAccess:", .{texture});
    }

    /// `-[MTLBlitCommandEncoder optimizeContentsForCPUAccess:slice:level:]`
    pub fn optimizeContentsForCPUAccessSliceLevel(self: Self, texture: Texture, slice: objc.UInteger, level: objc.UInteger) void {
        return self.object.msgSend(void, "optimizeContentsForCPUAccess:slice:level:", .{ texture, slice, level });
    }

    /// `-[MTLBlitCommandEncoder resetCommandsInBuffer:withRange:]`
    pub fn resetCommandsInBufferWithRange(self: Self, buffer: objc.Object, range: objc.Range) void {
        return self.object.msgSend(void, "resetCommandsInBuffer:withRange:", .{ buffer, range });
    }

    /// `-[MTLBlitCommandEncoder copyIndirectCommandBuffer:sourceRange:destination:destinationIndex:]`
    pub fn copyIndirectCommandBufferSourceRangeDestinationDestinationIndex(self: Self, source: objc.Object, source_range: objc.Range, destination: objc.Object, destination_index: objc.UInteger) void {
        return self.object.msgSend(void, "copyIndirectCommandBuffer:sourceRange:destination:destinationIndex:", .{ source, source_range, destination, destination_index });
    }

    /// `-[MTLBlitCommandEncoder optimizeIndirectCommandBuffer:withRange:]`
    pub fn optimizeIndirectCommandBufferWithRange(self: Self, indirect_command_buffer: objc.Object, range: objc.Range) void {
        return self.object.msgSend(void, "optimizeIndirectCommandBuffer:withRange:", .{ indirect_command_buffer, range });
    }

    /// `-[MTLBlitCommandEncoder sampleCountersInBuffer:atSampleIndex:withBarrier:]`
    pub fn sampleCountersInBufferAtSampleIndexWithBarrier(self: Self, sample_buffer: objc.Object, sample_index: objc.UInteger, barrier: bool) void {
        return self.object.msgSend(void, "sampleCountersInBuffer:atSampleIndex:withBarrier:", .{ sample_buffer, sample_index, barrier });
    }

    /// `-[MTLBlitCommandEncoder resolveCounters:inRange:destinationBuffer:destinationOffset:]`
    pub fn resolveCountersInRangeDestinationBufferDestinationOffset(self: Self, sample_buffer: objc.Object, range: objc.Range, destination_buffer: Buffer, destination_offset: objc.UInteger) void {
        return self.object.msgSend(void, "resolveCounters:inRange:destinationBuffer:destinationOffset:", .{ sample_buffer, range, destination_buffer, destination_offset });
    }

    /// `-[MTLBlitCommandEncoder copyFromTensor:sourceOrigin:sourceDimensions:toTensor:destinationOrigin:destinationDimensions:]`
    pub fn copyFromTensorSourceOriginSourceDimensionsToTensorDestinationOriginDestinationDimensions(self: Self, source_tensor: objc.Object, source_origin: objc.Object, source_dimensions: objc.Object, destination_tensor: objc.Object, destination_origin: objc.Object, destination_dimensions: objc.Object) void {
        return self.object.msgSend(void, "copyFromTensor:sourceOrigin:sourceDimensions:toTensor:destinationOrigin:destinationDimensions:", .{ source_tensor, source_origin, source_dimensions, destination_tensor, destination_origin, destination_dimensions });
    }

    /// `-[MTLBlitCommandEncoder copyFromTensor:sourceOrigin:sourceDimensions:sourcePlane:toTensor:destinationOrigin:destinationDimensions:destinationPlane:]`
    pub fn copyFromTensorSourceOriginSourceDimensionsSourcePlaneToTensorDestinationOriginDestinationDimensionsDestinationPlane(self: Self, source_tensor: objc.Object, source_origin: objc.Object, source_dimensions: objc.Object, source_plane: TensorPlaneType, destination_tensor: objc.Object, destination_origin: objc.Object, destination_dimensions: objc.Object, destination_plane: TensorPlaneType) void {
        return self.object.msgSend(void, "copyFromTensor:sourceOrigin:sourceDimensions:sourcePlane:toTensor:destinationOrigin:destinationDimensions:destinationPlane:", .{ source_tensor, source_origin, source_dimensions, source_plane, destination_tensor, destination_origin, destination_dimensions, destination_plane });
    }

    /// `-[MTLCommandEncoder endEncoding]`
    pub fn endEncoding(self: Self) void {
        return self.object.msgSend(void, "endEncoding", .{});
    }

    /// `-[MTLCommandEncoder barrierAfterQueueStages:beforeStages:]`
    pub fn barrierAfterQueueStagesBeforeStages(self: Self, after_queue_stages: Stages, before_stages: Stages) void {
        return self.object.msgSend(void, "barrierAfterQueueStages:beforeStages:", .{ after_queue_stages, before_stages });
    }

    /// `-[MTLCommandEncoder insertDebugSignpost:]`
    pub fn insertDebugSignpost(self: Self, string: foundation.String) void {
        return self.object.msgSend(void, "insertDebugSignpost:", .{string});
    }

    /// `-[MTLCommandEncoder pushDebugGroup:]`
    pub fn pushDebugGroup(self: Self, string: foundation.String) void {
        return self.object.msgSend(void, "pushDebugGroup:", .{string});
    }

    /// `-[MTLCommandEncoder popDebugGroup]`
    pub fn popDebugGroup(self: Self) void {
        return self.object.msgSend(void, "popDebugGroup", .{});
    }

    /// `-[MTLCommandEncoder device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLCommandEncoder label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLCommandEncoder setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-synchronizeResource:" = fn (Resource) void;
        pub const @"-synchronizeTexture:slice:level:" = fn (Texture, objc.UInteger, objc.UInteger) void;
        pub const @"-copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:" = fn (Texture, objc.UInteger, objc.UInteger, Origin, Size, Texture, objc.UInteger, objc.UInteger, Origin) void;
        pub const @"-copyFromBuffer:sourceOffset:sourceBytesPerRow:sourceBytesPerImage:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:" = fn (Buffer, objc.UInteger, objc.UInteger, objc.UInteger, Size, Texture, objc.UInteger, objc.UInteger, Origin) void;
        pub const @"-copyFromBuffer:sourceOffset:sourceBytesPerRow:sourceBytesPerImage:sourceSize:toTexture:destinationSlice:destinationLevel:destinationOrigin:options:" = fn (Buffer, objc.UInteger, objc.UInteger, objc.UInteger, Size, Texture, objc.UInteger, objc.UInteger, Origin, BlitOption) void;
        pub const @"-copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toBuffer:destinationOffset:destinationBytesPerRow:destinationBytesPerImage:" = fn (Texture, objc.UInteger, objc.UInteger, Origin, Size, Buffer, objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-copyFromTexture:sourceSlice:sourceLevel:sourceOrigin:sourceSize:toBuffer:destinationOffset:destinationBytesPerRow:destinationBytesPerImage:options:" = fn (Texture, objc.UInteger, objc.UInteger, Origin, Size, Buffer, objc.UInteger, objc.UInteger, objc.UInteger, BlitOption) void;
        pub const @"-generateMipmapsForTexture:" = fn (Texture) void;
        pub const @"-fillBuffer:range:value:" = fn (Buffer, objc.Range, u8) void;
        pub const @"-copyFromTexture:sourceSlice:sourceLevel:toTexture:destinationSlice:destinationLevel:sliceCount:levelCount:" = fn (Texture, objc.UInteger, objc.UInteger, Texture, objc.UInteger, objc.UInteger, objc.UInteger, objc.UInteger) void;
        pub const @"-copyFromTexture:toTexture:" = fn (Texture, Texture) void;
        pub const @"-copyFromBuffer:sourceOffset:toBuffer:destinationOffset:size:" = fn (Buffer, objc.UInteger, Buffer, objc.UInteger, objc.UInteger) void;
        pub const @"-updateFence:" = fn (objc.Object) void;
        pub const @"-waitForFence:" = fn (objc.Object) void;
        pub const @"-getTextureAccessCounters:region:mipLevel:slice:resetCounters:countersBuffer:countersBufferOffset:" = fn (Texture, Region, objc.UInteger, objc.UInteger, bool, Buffer, objc.UInteger) void;
        pub const @"-resetTextureAccessCounters:region:mipLevel:slice:" = fn (Texture, Region, objc.UInteger, objc.UInteger) void;
        pub const @"-optimizeContentsForGPUAccess:" = fn (Texture) void;
        pub const @"-optimizeContentsForGPUAccess:slice:level:" = fn (Texture, objc.UInteger, objc.UInteger) void;
        pub const @"-optimizeContentsForCPUAccess:" = fn (Texture) void;
        pub const @"-optimizeContentsForCPUAccess:slice:level:" = fn (Texture, objc.UInteger, objc.UInteger) void;
        pub const @"-resetCommandsInBuffer:withRange:" = fn (objc.Object, objc.Range) void;
        pub const @"-copyIndirectCommandBuffer:sourceRange:destination:destinationIndex:" = fn (objc.Object, objc.Range, objc.Object, objc.UInteger) void;
        pub const @"-optimizeIndirectCommandBuffer:withRange:" = fn (objc.Object, objc.Range) void;
        pub const @"-sampleCountersInBuffer:atSampleIndex:withBarrier:" = fn (objc.Object, objc.UInteger, bool) void;
        pub const @"-resolveCounters:inRange:destinationBuffer:destinationOffset:" = fn (objc.Object, objc.Range, Buffer, objc.UInteger) void;
        pub const @"-copyFromTensor:sourceOrigin:sourceDimensions:toTensor:destinationOrigin:destinationDimensions:" = fn (objc.Object, objc.Object, objc.Object, objc.Object, objc.Object, objc.Object) void;
        pub const @"-copyFromTensor:sourceOrigin:sourceDimensions:sourcePlane:toTensor:destinationOrigin:destinationDimensions:destinationPlane:" = fn (objc.Object, objc.Object, objc.Object, TensorPlaneType, objc.Object, objc.Object, objc.Object, TensorPlaneType) void;
    };
};

/// An object conforming to `MTLResource`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const Resource = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "MTLResource";

    /// An object that came from elsewhere, taken to conform to `MTLResource`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLResource setPurgeableState:]`
    pub fn setPurgeableState(self: Self, state: PurgeableState) PurgeableState {
        return self.object.msgSend(PurgeableState, "setPurgeableState:", .{state});
    }

    /// `-[MTLResource makeAliasable]`
    pub fn makeAliasable(self: Self) void {
        return self.object.msgSend(void, "makeAliasable", .{});
    }

    /// `-[MTLResource isAliasable]`
    pub fn isAliasable(self: Self) bool {
        return self.object.msgSend(bool, "isAliasable", .{});
    }

    /// `-[MTLResource setOwnerWithIdentity:]`
    pub fn setOwnerWithIdentity(self: Self, task_id_token: c_uint) c_int {
        return self.object.msgSend(c_int, "setOwnerWithIdentity:", .{task_id_token});
    }

    /// `-[MTLResource label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLResource setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// `-[MTLResource device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLResource cpuCacheMode]`
    pub fn cpuCacheMode(self: Self) CPUCacheMode {
        return self.object.msgSend(CPUCacheMode, "cpuCacheMode", .{});
    }

    /// `-[MTLResource storageMode]`
    pub fn storageMode(self: Self) StorageMode {
        return self.object.msgSend(StorageMode, "storageMode", .{});
    }

    /// `-[MTLResource hazardTrackingMode]`
    pub fn hazardTrackingMode(self: Self) HazardTrackingMode {
        return self.object.msgSend(HazardTrackingMode, "hazardTrackingMode", .{});
    }

    /// `-[MTLResource resourceOptions]`
    pub fn resourceOptions(self: Self) ResourceOptions {
        return self.object.msgSend(ResourceOptions, "resourceOptions", .{});
    }

    /// `-[MTLResource heap]`
    pub fn heap(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "heap", .{});
    }

    /// `-[MTLResource heapOffset]`
    pub fn heapOffset(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "heapOffset", .{});
    }

    /// `-[MTLResource allocatedSize]`
    pub fn allocatedSize(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "allocatedSize", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-setPurgeableState:" = fn (PurgeableState) PurgeableState;
        pub const @"-makeAliasable" = fn () void;
        pub const @"-isAliasable" = fn () bool;
        pub const @"-setOwnerWithIdentity:" = fn (c_uint) c_int;
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-setLabel:" = fn (?foundation.String) void;
        pub const @"-device" = fn () Device;
        pub const @"-cpuCacheMode" = fn () CPUCacheMode;
        pub const @"-storageMode" = fn () StorageMode;
        pub const @"-hazardTrackingMode" = fn () HazardTrackingMode;
        pub const @"-resourceOptions" = fn () ResourceOptions;
        pub const @"-heap" = fn () ?objc.Object;
        pub const @"-heapOffset" = fn () objc.UInteger;
        pub const @"-allocatedSize" = fn () objc.UInteger;
    };
};

/// An object conforming to `MTLBuffer`, which extends `MTLResource`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const Buffer = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = Resource;
    pub const protocol_name = "MTLBuffer";

    /// An object that came from elsewhere, taken to conform to `MTLBuffer`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLBuffer contents]`
    pub fn contents(self: Self) ?*anyopaque {
        return self.object.msgSend(?*anyopaque, "contents", .{});
    }

    /// `-[MTLBuffer didModifyRange:]`
    pub fn didModifyRange(self: Self, range: objc.Range) void {
        return self.object.msgSend(void, "didModifyRange:", .{range});
    }

    /// `-[MTLBuffer newTextureWithDescriptor:offset:bytesPerRow:]`
    pub fn newTextureWithDescriptorOffsetBytesPerRow(self: Self, descriptor: TextureDescriptor, offset: objc.UInteger, bytes_per_row: objc.UInteger) ?Texture {
        return self.object.msgSend(?Texture, "newTextureWithDescriptor:offset:bytesPerRow:", .{ descriptor, offset, bytes_per_row });
    }

    /// `-[MTLBuffer newTensorWithDescriptor:offset:error:]`
    pub fn newTensorWithDescriptorOffsetError(self: Self, descriptor: objc.Object, offset: objc.UInteger, @"error": ?*objc.abi.Id) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newTensorWithDescriptor:offset:error:", .{ descriptor, offset, @"error" });
    }

    /// `-[MTLBuffer addDebugMarker:range:]`
    pub fn addDebugMarkerRange(self: Self, marker: foundation.String, range: objc.Range) void {
        return self.object.msgSend(void, "addDebugMarker:range:", .{ marker, range });
    }

    /// `-[MTLBuffer removeAllDebugMarkers]`
    pub fn removeAllDebugMarkers(self: Self) void {
        return self.object.msgSend(void, "removeAllDebugMarkers", .{});
    }

    /// `-[MTLBuffer newRemoteBufferViewForDevice:]`
    pub fn newRemoteBufferViewForDevice(self: Self, device_: Device) ?Buffer {
        return self.object.msgSend(?Buffer, "newRemoteBufferViewForDevice:", .{device_});
    }

    /// `-[MTLBuffer length]`
    pub fn length(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "length", .{});
    }

    /// `-[MTLBuffer remoteStorageBuffer]`
    pub fn remoteStorageBuffer(self: Self) ?Buffer {
        return self.object.msgSend(?Buffer, "remoteStorageBuffer", .{});
    }

    /// `-[MTLBuffer gpuAddress]`
    pub fn gpuAddress(self: Self) c_ulonglong {
        return self.object.msgSend(c_ulonglong, "gpuAddress", .{});
    }

    /// `-[MTLBuffer sparseBufferTier]`
    pub fn sparseBufferTier(self: Self) BufferSparseTier {
        return self.object.msgSend(BufferSparseTier, "sparseBufferTier", .{});
    }

    /// `-[MTLResource setPurgeableState:]`
    pub fn setPurgeableState(self: Self, state: PurgeableState) PurgeableState {
        return self.object.msgSend(PurgeableState, "setPurgeableState:", .{state});
    }

    /// `-[MTLResource makeAliasable]`
    pub fn makeAliasable(self: Self) void {
        return self.object.msgSend(void, "makeAliasable", .{});
    }

    /// `-[MTLResource isAliasable]`
    pub fn isAliasable(self: Self) bool {
        return self.object.msgSend(bool, "isAliasable", .{});
    }

    /// `-[MTLResource setOwnerWithIdentity:]`
    pub fn setOwnerWithIdentity(self: Self, task_id_token: c_uint) c_int {
        return self.object.msgSend(c_int, "setOwnerWithIdentity:", .{task_id_token});
    }

    /// `-[MTLResource label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLResource setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// `-[MTLResource device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLResource cpuCacheMode]`
    pub fn cpuCacheMode(self: Self) CPUCacheMode {
        return self.object.msgSend(CPUCacheMode, "cpuCacheMode", .{});
    }

    /// `-[MTLResource storageMode]`
    pub fn storageMode(self: Self) StorageMode {
        return self.object.msgSend(StorageMode, "storageMode", .{});
    }

    /// `-[MTLResource hazardTrackingMode]`
    pub fn hazardTrackingMode(self: Self) HazardTrackingMode {
        return self.object.msgSend(HazardTrackingMode, "hazardTrackingMode", .{});
    }

    /// `-[MTLResource resourceOptions]`
    pub fn resourceOptions(self: Self) ResourceOptions {
        return self.object.msgSend(ResourceOptions, "resourceOptions", .{});
    }

    /// `-[MTLResource heap]`
    pub fn heap(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "heap", .{});
    }

    /// `-[MTLResource heapOffset]`
    pub fn heapOffset(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "heapOffset", .{});
    }

    /// `-[MTLResource allocatedSize]`
    pub fn allocatedSize(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "allocatedSize", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-contents" = fn () ?*anyopaque;
        pub const @"-didModifyRange:" = fn (objc.Range) void;
        pub const @"-newTextureWithDescriptor:offset:bytesPerRow:" = fn (TextureDescriptor, objc.UInteger, objc.UInteger) ?Texture;
        pub const @"-newTensorWithDescriptor:offset:error:" = fn (objc.Object, objc.UInteger, ?*objc.abi.Id) ?objc.Object;
        pub const @"-addDebugMarker:range:" = fn (foundation.String, objc.Range) void;
        pub const @"-removeAllDebugMarkers" = fn () void;
        pub const @"-newRemoteBufferViewForDevice:" = fn (Device) ?Buffer;
        pub const @"-length" = fn () objc.UInteger;
        pub const @"-remoteStorageBuffer" = fn () ?Buffer;
        pub const @"-gpuAddress" = fn () c_ulonglong;
        pub const @"-sparseBufferTier" = fn () BufferSparseTier;
    };
};

/// An object conforming to `MTLTexture`, which extends `MTLResource`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const Texture = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = Resource;
    pub const protocol_name = "MTLTexture";

    /// An object that came from elsewhere, taken to conform to `MTLTexture`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLTexture getBytes:bytesPerRow:bytesPerImage:fromRegion:mipmapLevel:slice:]`
    pub fn getBytesBytesPerRowBytesPerImageFromRegionMipmapLevelSlice(self: Self, pixel_bytes: ?*anyopaque, bytes_per_row: objc.UInteger, bytes_per_image: objc.UInteger, region: Region, level: objc.UInteger, slice: objc.UInteger) void {
        return self.object.msgSend(void, "getBytes:bytesPerRow:bytesPerImage:fromRegion:mipmapLevel:slice:", .{ pixel_bytes, bytes_per_row, bytes_per_image, region, level, slice });
    }

    /// `-[MTLTexture replaceRegion:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:]`
    pub fn replaceRegionMipmapLevelSliceWithBytesBytesPerRowBytesPerImage(self: Self, region: Region, level: objc.UInteger, slice: objc.UInteger, pixel_bytes: ?*const anyopaque, bytes_per_row: objc.UInteger, bytes_per_image: objc.UInteger) void {
        return self.object.msgSend(void, "replaceRegion:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:", .{ region, level, slice, pixel_bytes, bytes_per_row, bytes_per_image });
    }

    /// `-[MTLTexture getBytes:bytesPerRow:fromRegion:mipmapLevel:]`
    pub fn getBytesBytesPerRowFromRegionMipmapLevel(self: Self, pixel_bytes: ?*anyopaque, bytes_per_row: objc.UInteger, region: Region, level: objc.UInteger) void {
        return self.object.msgSend(void, "getBytes:bytesPerRow:fromRegion:mipmapLevel:", .{ pixel_bytes, bytes_per_row, region, level });
    }

    /// `-[MTLTexture replaceRegion:mipmapLevel:withBytes:bytesPerRow:]`
    pub fn replaceRegionMipmapLevelWithBytesBytesPerRow(self: Self, region: Region, level: objc.UInteger, pixel_bytes: ?*const anyopaque, bytes_per_row: objc.UInteger) void {
        return self.object.msgSend(void, "replaceRegion:mipmapLevel:withBytes:bytesPerRow:", .{ region, level, pixel_bytes, bytes_per_row });
    }

    /// `-[MTLTexture newTextureViewWithPixelFormat:]`
    pub fn newTextureViewWithPixelFormat(self: Self, pixel_format: PixelFormat) ?Texture {
        return self.object.msgSend(?Texture, "newTextureViewWithPixelFormat:", .{pixel_format});
    }

    /// `-[MTLTexture newTextureViewWithPixelFormat:textureType:levels:slices:]`
    pub fn newTextureViewWithPixelFormatTextureTypeLevelsSlices(self: Self, pixel_format: PixelFormat, texture_type: TextureType, level_range: objc.Range, slice_range: objc.Range) ?Texture {
        return self.object.msgSend(?Texture, "newTextureViewWithPixelFormat:textureType:levels:slices:", .{ pixel_format, texture_type, level_range, slice_range });
    }

    /// `-[MTLTexture newSharedTextureHandle]`
    pub fn newSharedTextureHandle(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newSharedTextureHandle", .{});
    }

    /// `-[MTLTexture newTextureViewWithDescriptor:]`
    pub fn newTextureViewWithDescriptor(self: Self, descriptor: objc.Object) ?Texture {
        return self.object.msgSend(?Texture, "newTextureViewWithDescriptor:", .{descriptor});
    }

    /// `-[MTLTexture newRemoteTextureViewForDevice:]`
    pub fn newRemoteTextureViewForDevice(self: Self, device_: Device) ?Texture {
        return self.object.msgSend(?Texture, "newRemoteTextureViewForDevice:", .{device_});
    }

    /// `-[MTLTexture newTextureViewWithPixelFormat:textureType:levels:slices:swizzle:]`
    pub fn newTextureViewWithPixelFormatTextureTypeLevelsSlicesSwizzle(self: Self, pixel_format: PixelFormat, texture_type: TextureType, level_range: objc.Range, slice_range: objc.Range, swizzle_: TextureSwizzleChannels) ?Texture {
        return self.object.msgSend(?Texture, "newTextureViewWithPixelFormat:textureType:levels:slices:swizzle:", .{ pixel_format, texture_type, level_range, slice_range, swizzle_ });
    }

    /// `-[MTLTexture rootResource]`
    pub fn rootResource(self: Self) ?Resource {
        return self.object.msgSend(?Resource, "rootResource", .{});
    }

    /// `-[MTLTexture parentTexture]`
    pub fn parentTexture(self: Self) ?Texture {
        return self.object.msgSend(?Texture, "parentTexture", .{});
    }

    /// `-[MTLTexture parentRelativeLevel]`
    pub fn parentRelativeLevel(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "parentRelativeLevel", .{});
    }

    /// `-[MTLTexture parentRelativeSlice]`
    pub fn parentRelativeSlice(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "parentRelativeSlice", .{});
    }

    /// `-[MTLTexture buffer]`
    pub fn buffer(self: Self) ?Buffer {
        return self.object.msgSend(?Buffer, "buffer", .{});
    }

    /// `-[MTLTexture bufferOffset]`
    pub fn bufferOffset(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "bufferOffset", .{});
    }

    /// `-[MTLTexture bufferBytesPerRow]`
    pub fn bufferBytesPerRow(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "bufferBytesPerRow", .{});
    }

    /// `-[MTLTexture iosurface]`
    pub fn iosurface(self: Self) ?io_surface.Surface {
        return self.object.msgSend(?io_surface.Surface, "iosurface", .{});
    }

    /// `-[MTLTexture iosurfacePlane]`
    pub fn iosurfacePlane(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "iosurfacePlane", .{});
    }

    /// `-[MTLTexture textureType]`
    pub fn textureType(self: Self) TextureType {
        return self.object.msgSend(TextureType, "textureType", .{});
    }

    /// `-[MTLTexture pixelFormat]`
    pub fn pixelFormat(self: Self) PixelFormat {
        return self.object.msgSend(PixelFormat, "pixelFormat", .{});
    }

    /// `-[MTLTexture width]`
    pub fn width(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "width", .{});
    }

    /// `-[MTLTexture height]`
    pub fn height(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "height", .{});
    }

    /// `-[MTLTexture depth]`
    pub fn depth(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "depth", .{});
    }

    /// `-[MTLTexture mipmapLevelCount]`
    pub fn mipmapLevelCount(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "mipmapLevelCount", .{});
    }

    /// `-[MTLTexture sampleCount]`
    pub fn sampleCount(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "sampleCount", .{});
    }

    /// `-[MTLTexture arrayLength]`
    pub fn arrayLength(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "arrayLength", .{});
    }

    /// `-[MTLTexture usage]`
    pub fn usage(self: Self) TextureUsage {
        return self.object.msgSend(TextureUsage, "usage", .{});
    }

    /// `-[MTLTexture isShareable]`
    pub fn isShareable(self: Self) bool {
        return self.object.msgSend(bool, "isShareable", .{});
    }

    /// `-[MTLTexture isFramebufferOnly]`
    pub fn isFramebufferOnly(self: Self) bool {
        return self.object.msgSend(bool, "isFramebufferOnly", .{});
    }

    /// `-[MTLTexture firstMipmapInTail]`
    pub fn firstMipmapInTail(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "firstMipmapInTail", .{});
    }

    /// `-[MTLTexture tailSizeInBytes]`
    pub fn tailSizeInBytes(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "tailSizeInBytes", .{});
    }

    /// `-[MTLTexture isSparse]`
    pub fn isSparse(self: Self) bool {
        return self.object.msgSend(bool, "isSparse", .{});
    }

    /// `-[MTLTexture allowGPUOptimizedContents]`
    pub fn allowGPUOptimizedContents(self: Self) bool {
        return self.object.msgSend(bool, "allowGPUOptimizedContents", .{});
    }

    /// `-[MTLTexture compressionType]`
    pub fn compressionType(self: Self) TextureCompressionType {
        return self.object.msgSend(TextureCompressionType, "compressionType", .{});
    }

    /// `-[MTLTexture gpuResourceID]`
    pub fn gpuResourceID(self: Self) ResourceID {
        return self.object.msgSend(ResourceID, "gpuResourceID", .{});
    }

    /// `-[MTLTexture remoteStorageTexture]`
    pub fn remoteStorageTexture(self: Self) ?Texture {
        return self.object.msgSend(?Texture, "remoteStorageTexture", .{});
    }

    /// `-[MTLTexture swizzle]`
    pub fn swizzle(self: Self) TextureSwizzleChannels {
        return self.object.msgSend(TextureSwizzleChannels, "swizzle", .{});
    }

    /// `-[MTLTexture sparseTextureTier]`
    pub fn sparseTextureTier(self: Self) TextureSparseTier {
        return self.object.msgSend(TextureSparseTier, "sparseTextureTier", .{});
    }

    /// `-[MTLTexture minLOD]`
    pub fn minLOD(self: Self) f32 {
        return self.object.msgSend(f32, "minLOD", .{});
    }

    /// `-[MTLResource setPurgeableState:]`
    pub fn setPurgeableState(self: Self, state: PurgeableState) PurgeableState {
        return self.object.msgSend(PurgeableState, "setPurgeableState:", .{state});
    }

    /// `-[MTLResource makeAliasable]`
    pub fn makeAliasable(self: Self) void {
        return self.object.msgSend(void, "makeAliasable", .{});
    }

    /// `-[MTLResource isAliasable]`
    pub fn isAliasable(self: Self) bool {
        return self.object.msgSend(bool, "isAliasable", .{});
    }

    /// `-[MTLResource setOwnerWithIdentity:]`
    pub fn setOwnerWithIdentity(self: Self, task_id_token: c_uint) c_int {
        return self.object.msgSend(c_int, "setOwnerWithIdentity:", .{task_id_token});
    }

    /// `-[MTLResource label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLResource setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// `-[MTLResource device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLResource cpuCacheMode]`
    pub fn cpuCacheMode(self: Self) CPUCacheMode {
        return self.object.msgSend(CPUCacheMode, "cpuCacheMode", .{});
    }

    /// `-[MTLResource storageMode]`
    pub fn storageMode(self: Self) StorageMode {
        return self.object.msgSend(StorageMode, "storageMode", .{});
    }

    /// `-[MTLResource hazardTrackingMode]`
    pub fn hazardTrackingMode(self: Self) HazardTrackingMode {
        return self.object.msgSend(HazardTrackingMode, "hazardTrackingMode", .{});
    }

    /// `-[MTLResource resourceOptions]`
    pub fn resourceOptions(self: Self) ResourceOptions {
        return self.object.msgSend(ResourceOptions, "resourceOptions", .{});
    }

    /// `-[MTLResource heap]`
    pub fn heap(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "heap", .{});
    }

    /// `-[MTLResource heapOffset]`
    pub fn heapOffset(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "heapOffset", .{});
    }

    /// `-[MTLResource allocatedSize]`
    pub fn allocatedSize(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "allocatedSize", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-getBytes:bytesPerRow:bytesPerImage:fromRegion:mipmapLevel:slice:" = fn (?*anyopaque, objc.UInteger, objc.UInteger, Region, objc.UInteger, objc.UInteger) void;
        pub const @"-replaceRegion:mipmapLevel:slice:withBytes:bytesPerRow:bytesPerImage:" = fn (Region, objc.UInteger, objc.UInteger, ?*const anyopaque, objc.UInteger, objc.UInteger) void;
        pub const @"-getBytes:bytesPerRow:fromRegion:mipmapLevel:" = fn (?*anyopaque, objc.UInteger, Region, objc.UInteger) void;
        pub const @"-replaceRegion:mipmapLevel:withBytes:bytesPerRow:" = fn (Region, objc.UInteger, ?*const anyopaque, objc.UInteger) void;
        pub const @"-newTextureViewWithPixelFormat:" = fn (PixelFormat) ?Texture;
        pub const @"-newTextureViewWithPixelFormat:textureType:levels:slices:" = fn (PixelFormat, TextureType, objc.Range, objc.Range) ?Texture;
        pub const @"-newSharedTextureHandle" = fn () ?objc.Object;
        pub const @"-newTextureViewWithDescriptor:" = fn (objc.Object) ?Texture;
        pub const @"-newRemoteTextureViewForDevice:" = fn (Device) ?Texture;
        pub const @"-newTextureViewWithPixelFormat:textureType:levels:slices:swizzle:" = fn (PixelFormat, TextureType, objc.Range, objc.Range, TextureSwizzleChannels) ?Texture;
        pub const @"-rootResource" = fn () ?Resource;
        pub const @"-parentTexture" = fn () ?Texture;
        pub const @"-parentRelativeLevel" = fn () objc.UInteger;
        pub const @"-parentRelativeSlice" = fn () objc.UInteger;
        pub const @"-buffer" = fn () ?Buffer;
        pub const @"-bufferOffset" = fn () objc.UInteger;
        pub const @"-bufferBytesPerRow" = fn () objc.UInteger;
        pub const @"-iosurface" = fn () ?io_surface.Surface;
        pub const @"-iosurfacePlane" = fn () objc.UInteger;
        pub const @"-textureType" = fn () TextureType;
        pub const @"-pixelFormat" = fn () PixelFormat;
        pub const @"-width" = fn () objc.UInteger;
        pub const @"-height" = fn () objc.UInteger;
        pub const @"-depth" = fn () objc.UInteger;
        pub const @"-mipmapLevelCount" = fn () objc.UInteger;
        pub const @"-sampleCount" = fn () objc.UInteger;
        pub const @"-arrayLength" = fn () objc.UInteger;
        pub const @"-usage" = fn () TextureUsage;
        pub const @"-isShareable" = fn () bool;
        pub const @"-isFramebufferOnly" = fn () bool;
        pub const @"-firstMipmapInTail" = fn () objc.UInteger;
        pub const @"-tailSizeInBytes" = fn () objc.UInteger;
        pub const @"-isSparse" = fn () bool;
        pub const @"-allowGPUOptimizedContents" = fn () bool;
        pub const @"-compressionType" = fn () TextureCompressionType;
        pub const @"-gpuResourceID" = fn () ResourceID;
        pub const @"-remoteStorageTexture" = fn () ?Texture;
        pub const @"-swizzle" = fn () TextureSwizzleChannels;
        pub const @"-sparseTextureTier" = fn () TextureSparseTier;
        pub const @"-minLOD" = fn () f32;
    };
};

/// An object conforming to `MTLLibrary`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const Library = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "MTLLibrary";

    /// An object that came from elsewhere, taken to conform to `MTLLibrary`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLLibrary newFunctionWithName:]`
    pub fn newFunctionWithName(self: Self, function_name: foundation.String) ?Function {
        return self.object.msgSend(?Function, "newFunctionWithName:", .{function_name});
    }

    /// `-[MTLLibrary newFunctionWithName:constantValues:error:]`
    pub fn newFunctionWithNameConstantValuesError(self: Self, name: foundation.String, constant_values: objc.Object, @"error": ?*objc.abi.Id) ?Function {
        return self.object.msgSend(?Function, "newFunctionWithName:constantValues:error:", .{ name, constant_values, @"error" });
    }

    /// `-[MTLLibrary newFunctionWithName:constantValues:completionHandler:]`
    pub fn newFunctionWithNameConstantValuesCompletionHandler(self: Self, name: foundation.String, constant_values: objc.Object, completion_handler: objc.BlockRef(fn (?Function, ?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "newFunctionWithName:constantValues:completionHandler:", .{ name, constant_values, completion_handler });
    }

    /// `-[MTLLibrary reflectionForFunctionWithName:]`
    pub fn reflectionForFunctionWithName(self: Self, function_name: foundation.String) ?objc.Object {
        return self.object.msgSend(?objc.Object, "reflectionForFunctionWithName:", .{function_name});
    }

    /// `-[MTLLibrary newFunctionWithDescriptor:completionHandler:]`
    pub fn newFunctionWithDescriptorCompletionHandler(self: Self, descriptor: objc.Object, completion_handler: objc.BlockRef(fn (?Function, ?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "newFunctionWithDescriptor:completionHandler:", .{ descriptor, completion_handler });
    }

    /// `-[MTLLibrary newFunctionWithDescriptor:error:]`
    pub fn newFunctionWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?Function {
        return self.object.msgSend(?Function, "newFunctionWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLLibrary newIntersectionFunctionWithDescriptor:completionHandler:]`
    pub fn newIntersectionFunctionWithDescriptorCompletionHandler(self: Self, descriptor: objc.Object, completion_handler: objc.BlockRef(fn (?Function, ?foundation.ErrorObject) void)) void {
        return self.object.msgSend(void, "newIntersectionFunctionWithDescriptor:completionHandler:", .{ descriptor, completion_handler });
    }

    /// `-[MTLLibrary newIntersectionFunctionWithDescriptor:error:]`
    pub fn newIntersectionFunctionWithDescriptorError(self: Self, descriptor: objc.Object, @"error": ?*objc.abi.Id) ?Function {
        return self.object.msgSend(?Function, "newIntersectionFunctionWithDescriptor:error:", .{ descriptor, @"error" });
    }

    /// `-[MTLLibrary label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLLibrary setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// `-[MTLLibrary device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLLibrary functionNames]`
    pub fn functionNames(self: Self) foundation.Array(foundation.String) {
        return self.object.msgSend(foundation.Array(foundation.String), "functionNames", .{});
    }

    /// `-[MTLLibrary type]`
    pub fn @"type"(self: Self) LibraryType {
        return self.object.msgSend(LibraryType, "type", .{});
    }

    /// `-[MTLLibrary installName]`
    pub fn installName(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "installName", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-newFunctionWithName:" = fn (foundation.String) ?Function;
        pub const @"-newFunctionWithName:constantValues:error:" = fn (foundation.String, objc.Object, ?*objc.abi.Id) ?Function;
        pub const @"-newFunctionWithName:constantValues:completionHandler:" = fn (foundation.String, objc.Object, objc.BlockRef(fn (?Function, ?foundation.ErrorObject) void)) void;
        pub const @"-reflectionForFunctionWithName:" = fn (foundation.String) ?objc.Object;
        pub const @"-newFunctionWithDescriptor:completionHandler:" = fn (objc.Object, objc.BlockRef(fn (?Function, ?foundation.ErrorObject) void)) void;
        pub const @"-newFunctionWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?Function;
        pub const @"-newIntersectionFunctionWithDescriptor:completionHandler:" = fn (objc.Object, objc.BlockRef(fn (?Function, ?foundation.ErrorObject) void)) void;
        pub const @"-newIntersectionFunctionWithDescriptor:error:" = fn (objc.Object, ?*objc.abi.Id) ?Function;
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-setLabel:" = fn (?foundation.String) void;
        pub const @"-device" = fn () Device;
        pub const @"-functionNames" = fn () foundation.Array(foundation.String);
        pub const @"-type" = fn () LibraryType;
        pub const @"-installName" = fn () ?foundation.String;
    };
};

/// An object conforming to `MTLFunction`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const Function = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "MTLFunction";

    /// An object that came from elsewhere, taken to conform to `MTLFunction`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLFunction newArgumentEncoderWithBufferIndex:]`
    pub fn newArgumentEncoderWithBufferIndex(self: Self, buffer_index: objc.UInteger) objc.Object {
        return self.object.msgSend(objc.Object, "newArgumentEncoderWithBufferIndex:", .{buffer_index});
    }

    /// `-[MTLFunction newArgumentEncoderWithBufferIndex:reflection:]`
    pub fn newArgumentEncoderWithBufferIndexReflection(self: Self, buffer_index: objc.UInteger, reflection: ?objc.Object) objc.Object {
        return self.object.msgSend(objc.Object, "newArgumentEncoderWithBufferIndex:reflection:", .{ buffer_index, reflection });
    }

    /// `-[MTLFunction label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLFunction setLabel:]`
    pub fn setLabel(self: Self, label_: ?foundation.String) void {
        return self.object.msgSend(void, "setLabel:", .{label_});
    }

    /// `-[MTLFunction device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLFunction functionType]`
    pub fn functionType(self: Self) FunctionType {
        return self.object.msgSend(FunctionType, "functionType", .{});
    }

    /// `-[MTLFunction patchType]`
    pub fn patchType(self: Self) PatchType {
        return self.object.msgSend(PatchType, "patchType", .{});
    }

    /// `-[MTLFunction patchControlPointCount]`
    pub fn patchControlPointCount(self: Self) objc.Integer {
        return self.object.msgSend(objc.Integer, "patchControlPointCount", .{});
    }

    /// `-[MTLFunction vertexAttributes]`
    pub fn vertexAttributes(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "vertexAttributes", .{});
    }

    /// `-[MTLFunction stageInputAttributes]`
    pub fn stageInputAttributes(self: Self) ?foundation.Array(objc.Object) {
        return self.object.msgSend(?foundation.Array(objc.Object), "stageInputAttributes", .{});
    }

    /// `-[MTLFunction name]`
    pub fn name(self: Self) foundation.String {
        return self.object.msgSend(foundation.String, "name", .{});
    }

    /// `-[MTLFunction functionConstantsDictionary]`
    pub fn functionConstantsDictionary(self: Self) foundation.Dictionary(foundation.String, objc.Object) {
        return self.object.msgSend(foundation.Dictionary(foundation.String, objc.Object), "functionConstantsDictionary", .{});
    }

    /// `-[MTLFunction options]`
    pub fn options(self: Self) FunctionOptions {
        return self.object.msgSend(FunctionOptions, "options", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-newArgumentEncoderWithBufferIndex:" = fn (objc.UInteger) objc.Object;
        pub const @"-newArgumentEncoderWithBufferIndex:reflection:" = fn (objc.UInteger, ?objc.Object) objc.Object;
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-setLabel:" = fn (?foundation.String) void;
        pub const @"-device" = fn () Device;
        pub const @"-functionType" = fn () FunctionType;
        pub const @"-patchType" = fn () PatchType;
        pub const @"-patchControlPointCount" = fn () objc.Integer;
        pub const @"-vertexAttributes" = fn () ?foundation.Array(objc.Object);
        pub const @"-stageInputAttributes" = fn () ?foundation.Array(objc.Object);
        pub const @"-name" = fn () foundation.String;
        pub const @"-functionConstantsDictionary" = fn () foundation.Dictionary(foundation.String, objc.Object);
        pub const @"-options" = fn () FunctionOptions;
    };
};

/// An object conforming to `MTLRenderPipelineState`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const RenderPipelineState = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "MTLRenderPipelineState";

    /// An object that came from elsewhere, taken to conform to `MTLRenderPipelineState`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLRenderPipelineState functionHandleWithName:stage:]`
    pub fn functionHandleWithNameStage(self: Self, name: foundation.String, stage: RenderStages) ?objc.Object {
        return self.object.msgSend(?objc.Object, "functionHandleWithName:stage:", .{ name, stage });
    }

    /// `-[MTLRenderPipelineState functionHandleWithBinaryFunction:stage:]`
    pub fn functionHandleWithBinaryFunctionStage(self: Self, function: objc.Object, stage: RenderStages) ?objc.Object {
        return self.object.msgSend(?objc.Object, "functionHandleWithBinaryFunction:stage:", .{ function, stage });
    }

    /// `-[MTLRenderPipelineState newRenderPipelineStateWithBinaryFunctions:error:]`
    pub fn newRenderPipelineStateWithBinaryFunctionsError(self: Self, binary_functions_descriptor: objc.Object, @"error": ?*objc.abi.Id) ?RenderPipelineState {
        return self.object.msgSend(?RenderPipelineState, "newRenderPipelineStateWithBinaryFunctions:error:", .{ binary_functions_descriptor, @"error" });
    }

    /// `-[MTLRenderPipelineState newRenderPipelineDescriptorForSpecialization]`
    pub fn newRenderPipelineDescriptorForSpecialization(self: Self) objc.Object {
        return self.object.msgSend(objc.Object, "newRenderPipelineDescriptorForSpecialization", .{});
    }

    /// `-[MTLRenderPipelineState imageblockMemoryLengthForDimensions:]`
    pub fn imageblockMemoryLengthForDimensions(self: Self, imageblock_dimensions: Size) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "imageblockMemoryLengthForDimensions:", .{imageblock_dimensions});
    }

    /// `-[MTLRenderPipelineState functionHandleWithFunction:stage:]`
    pub fn functionHandleWithFunctionStage(self: Self, function: Function, stage: RenderStages) ?objc.Object {
        return self.object.msgSend(?objc.Object, "functionHandleWithFunction:stage:", .{ function, stage });
    }

    /// `-[MTLRenderPipelineState newVisibleFunctionTableWithDescriptor:stage:]`
    pub fn newVisibleFunctionTableWithDescriptorStage(self: Self, descriptor: objc.Object, stage: RenderStages) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newVisibleFunctionTableWithDescriptor:stage:", .{ descriptor, stage });
    }

    /// `-[MTLRenderPipelineState newIntersectionFunctionTableWithDescriptor:stage:]`
    pub fn newIntersectionFunctionTableWithDescriptorStage(self: Self, descriptor: objc.Object, stage: RenderStages) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newIntersectionFunctionTableWithDescriptor:stage:", .{ descriptor, stage });
    }

    /// `-[MTLRenderPipelineState newRenderPipelineStateWithAdditionalBinaryFunctions:error:]`
    pub fn newRenderPipelineStateWithAdditionalBinaryFunctionsError(self: Self, additional_binary_functions: objc.Object, @"error": ?*objc.abi.Id) ?RenderPipelineState {
        return self.object.msgSend(?RenderPipelineState, "newRenderPipelineStateWithAdditionalBinaryFunctions:error:", .{ additional_binary_functions, @"error" });
    }

    /// `-[MTLRenderPipelineState label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLRenderPipelineState device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLRenderPipelineState reflection]`
    pub fn reflection(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "reflection", .{});
    }

    /// `-[MTLRenderPipelineState maxTotalThreadsPerThreadgroup]`
    pub fn maxTotalThreadsPerThreadgroup(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxTotalThreadsPerThreadgroup", .{});
    }

    /// `-[MTLRenderPipelineState threadgroupSizeMatchesTileSize]`
    pub fn threadgroupSizeMatchesTileSize(self: Self) bool {
        return self.object.msgSend(bool, "threadgroupSizeMatchesTileSize", .{});
    }

    /// `-[MTLRenderPipelineState imageblockSampleLength]`
    pub fn imageblockSampleLength(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "imageblockSampleLength", .{});
    }

    /// `-[MTLRenderPipelineState supportIndirectCommandBuffers]`
    pub fn supportIndirectCommandBuffers(self: Self) bool {
        return self.object.msgSend(bool, "supportIndirectCommandBuffers", .{});
    }

    /// `-[MTLRenderPipelineState maxTotalThreadsPerObjectThreadgroup]`
    pub fn maxTotalThreadsPerObjectThreadgroup(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxTotalThreadsPerObjectThreadgroup", .{});
    }

    /// `-[MTLRenderPipelineState maxTotalThreadsPerMeshThreadgroup]`
    pub fn maxTotalThreadsPerMeshThreadgroup(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxTotalThreadsPerMeshThreadgroup", .{});
    }

    /// `-[MTLRenderPipelineState objectThreadExecutionWidth]`
    pub fn objectThreadExecutionWidth(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "objectThreadExecutionWidth", .{});
    }

    /// `-[MTLRenderPipelineState meshThreadExecutionWidth]`
    pub fn meshThreadExecutionWidth(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "meshThreadExecutionWidth", .{});
    }

    /// `-[MTLRenderPipelineState maxTotalThreadgroupsPerMeshGrid]`
    pub fn maxTotalThreadgroupsPerMeshGrid(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxTotalThreadgroupsPerMeshGrid", .{});
    }

    /// `-[MTLRenderPipelineState gpuResourceID]`
    pub fn gpuResourceID(self: Self) ResourceID {
        return self.object.msgSend(ResourceID, "gpuResourceID", .{});
    }

    /// `-[MTLRenderPipelineState shaderValidation]`
    pub fn shaderValidation(self: Self) ShaderValidation {
        return self.object.msgSend(ShaderValidation, "shaderValidation", .{});
    }

    /// `-[MTLRenderPipelineState requiredThreadsPerTileThreadgroup]`
    pub fn requiredThreadsPerTileThreadgroup(self: Self) Size {
        return self.object.msgSend(Size, "requiredThreadsPerTileThreadgroup", .{});
    }

    /// `-[MTLRenderPipelineState requiredThreadsPerObjectThreadgroup]`
    pub fn requiredThreadsPerObjectThreadgroup(self: Self) Size {
        return self.object.msgSend(Size, "requiredThreadsPerObjectThreadgroup", .{});
    }

    /// `-[MTLRenderPipelineState requiredThreadsPerMeshThreadgroup]`
    pub fn requiredThreadsPerMeshThreadgroup(self: Self) Size {
        return self.object.msgSend(Size, "requiredThreadsPerMeshThreadgroup", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-functionHandleWithName:stage:" = fn (foundation.String, RenderStages) ?objc.Object;
        pub const @"-functionHandleWithBinaryFunction:stage:" = fn (objc.Object, RenderStages) ?objc.Object;
        pub const @"-newRenderPipelineStateWithBinaryFunctions:error:" = fn (objc.Object, ?*objc.abi.Id) ?RenderPipelineState;
        pub const @"-newRenderPipelineDescriptorForSpecialization" = fn () objc.Object;
        pub const @"-imageblockMemoryLengthForDimensions:" = fn (Size) objc.UInteger;
        pub const @"-functionHandleWithFunction:stage:" = fn (Function, RenderStages) ?objc.Object;
        pub const @"-newVisibleFunctionTableWithDescriptor:stage:" = fn (objc.Object, RenderStages) ?objc.Object;
        pub const @"-newIntersectionFunctionTableWithDescriptor:stage:" = fn (objc.Object, RenderStages) ?objc.Object;
        pub const @"-newRenderPipelineStateWithAdditionalBinaryFunctions:error:" = fn (objc.Object, ?*objc.abi.Id) ?RenderPipelineState;
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-device" = fn () Device;
        pub const @"-reflection" = fn () ?objc.Object;
        pub const @"-maxTotalThreadsPerThreadgroup" = fn () objc.UInteger;
        pub const @"-threadgroupSizeMatchesTileSize" = fn () bool;
        pub const @"-imageblockSampleLength" = fn () objc.UInteger;
        pub const @"-supportIndirectCommandBuffers" = fn () bool;
        pub const @"-maxTotalThreadsPerObjectThreadgroup" = fn () objc.UInteger;
        pub const @"-maxTotalThreadsPerMeshThreadgroup" = fn () objc.UInteger;
        pub const @"-objectThreadExecutionWidth" = fn () objc.UInteger;
        pub const @"-meshThreadExecutionWidth" = fn () objc.UInteger;
        pub const @"-maxTotalThreadgroupsPerMeshGrid" = fn () objc.UInteger;
        pub const @"-gpuResourceID" = fn () ResourceID;
        pub const @"-shaderValidation" = fn () ShaderValidation;
        pub const @"-requiredThreadsPerTileThreadgroup" = fn () Size;
        pub const @"-requiredThreadsPerObjectThreadgroup" = fn () Size;
        pub const @"-requiredThreadsPerMeshThreadgroup" = fn () Size;
    };
};

/// An object conforming to `MTLComputePipelineState`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const ComputePipelineState = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "MTLComputePipelineState";

    /// An object that came from elsewhere, taken to conform to `MTLComputePipelineState`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLComputePipelineState functionHandleWithName:]`
    pub fn functionHandleWithName(self: Self, name: foundation.String) ?objc.Object {
        return self.object.msgSend(?objc.Object, "functionHandleWithName:", .{name});
    }

    /// `-[MTLComputePipelineState functionHandleWithBinaryFunction:]`
    pub fn functionHandleWithBinaryFunction(self: Self, function: objc.Object) ?objc.Object {
        return self.object.msgSend(?objc.Object, "functionHandleWithBinaryFunction:", .{function});
    }

    /// `-[MTLComputePipelineState newComputePipelineStateWithBinaryFunctions:error:]`
    pub fn newComputePipelineStateWithBinaryFunctionsError(self: Self, additional_binary_functions: foundation.Array(objc.Object), @"error": ?*objc.abi.Id) ?ComputePipelineState {
        return self.object.msgSend(?ComputePipelineState, "newComputePipelineStateWithBinaryFunctions:error:", .{ additional_binary_functions, @"error" });
    }

    /// `-[MTLComputePipelineState imageblockMemoryLengthForDimensions:]`
    pub fn imageblockMemoryLengthForDimensions(self: Self, imageblock_dimensions: Size) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "imageblockMemoryLengthForDimensions:", .{imageblock_dimensions});
    }

    /// `-[MTLComputePipelineState functionHandleWithFunction:]`
    pub fn functionHandleWithFunction(self: Self, function: Function) ?objc.Object {
        return self.object.msgSend(?objc.Object, "functionHandleWithFunction:", .{function});
    }

    /// `-[MTLComputePipelineState newComputePipelineStateWithAdditionalBinaryFunctions:error:]`
    pub fn newComputePipelineStateWithAdditionalBinaryFunctionsError(self: Self, functions: foundation.Array(Function), @"error": ?*objc.abi.Id) ?ComputePipelineState {
        return self.object.msgSend(?ComputePipelineState, "newComputePipelineStateWithAdditionalBinaryFunctions:error:", .{ functions, @"error" });
    }

    /// `-[MTLComputePipelineState newVisibleFunctionTableWithDescriptor:]`
    pub fn newVisibleFunctionTableWithDescriptor(self: Self, descriptor: objc.Object) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newVisibleFunctionTableWithDescriptor:", .{descriptor});
    }

    /// `-[MTLComputePipelineState newIntersectionFunctionTableWithDescriptor:]`
    pub fn newIntersectionFunctionTableWithDescriptor(self: Self, descriptor: objc.Object) ?objc.Object {
        return self.object.msgSend(?objc.Object, "newIntersectionFunctionTableWithDescriptor:", .{descriptor});
    }

    /// `-[MTLComputePipelineState recommendedPersistentThreadgroupsPerGridForThreadsPerThreadgroup:]`
    pub fn recommendedPersistentThreadgroupsPerGridForThreadsPerThreadgroup(self: Self, threads_per_threadgroup: Size) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "recommendedPersistentThreadgroupsPerGridForThreadsPerThreadgroup:", .{threads_per_threadgroup});
    }

    /// `-[MTLComputePipelineState label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLComputePipelineState reflection]`
    pub fn reflection(self: Self) ?objc.Object {
        return self.object.msgSend(?objc.Object, "reflection", .{});
    }

    /// `-[MTLComputePipelineState device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLComputePipelineState maxTotalThreadsPerThreadgroup]`
    pub fn maxTotalThreadsPerThreadgroup(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "maxTotalThreadsPerThreadgroup", .{});
    }

    /// `-[MTLComputePipelineState threadExecutionWidth]`
    pub fn threadExecutionWidth(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "threadExecutionWidth", .{});
    }

    /// `-[MTLComputePipelineState staticThreadgroupMemoryLength]`
    pub fn staticThreadgroupMemoryLength(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "staticThreadgroupMemoryLength", .{});
    }

    /// `-[MTLComputePipelineState supportIndirectCommandBuffers]`
    pub fn supportIndirectCommandBuffers(self: Self) bool {
        return self.object.msgSend(bool, "supportIndirectCommandBuffers", .{});
    }

    /// `-[MTLComputePipelineState gpuResourceID]`
    pub fn gpuResourceID(self: Self) ResourceID {
        return self.object.msgSend(ResourceID, "gpuResourceID", .{});
    }

    /// `-[MTLComputePipelineState shaderValidation]`
    pub fn shaderValidation(self: Self) ShaderValidation {
        return self.object.msgSend(ShaderValidation, "shaderValidation", .{});
    }

    /// `-[MTLComputePipelineState requiredThreadsPerThreadgroup]`
    pub fn requiredThreadsPerThreadgroup(self: Self) Size {
        return self.object.msgSend(Size, "requiredThreadsPerThreadgroup", .{});
    }

    /// `-[MTLComputePipelineState forwardProgressUsage]`
    pub fn forwardProgressUsage(self: Self) ForwardProgressUsage {
        return self.object.msgSend(ForwardProgressUsage, "forwardProgressUsage", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-functionHandleWithName:" = fn (foundation.String) ?objc.Object;
        pub const @"-functionHandleWithBinaryFunction:" = fn (objc.Object) ?objc.Object;
        pub const @"-newComputePipelineStateWithBinaryFunctions:error:" = fn (foundation.Array(objc.Object), ?*objc.abi.Id) ?ComputePipelineState;
        pub const @"-imageblockMemoryLengthForDimensions:" = fn (Size) objc.UInteger;
        pub const @"-functionHandleWithFunction:" = fn (Function) ?objc.Object;
        pub const @"-newComputePipelineStateWithAdditionalBinaryFunctions:error:" = fn (foundation.Array(Function), ?*objc.abi.Id) ?ComputePipelineState;
        pub const @"-newVisibleFunctionTableWithDescriptor:" = fn (objc.Object) ?objc.Object;
        pub const @"-newIntersectionFunctionTableWithDescriptor:" = fn (objc.Object) ?objc.Object;
        pub const @"-recommendedPersistentThreadgroupsPerGridForThreadsPerThreadgroup:" = fn (Size) objc.UInteger;
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-reflection" = fn () ?objc.Object;
        pub const @"-device" = fn () Device;
        pub const @"-maxTotalThreadsPerThreadgroup" = fn () objc.UInteger;
        pub const @"-threadExecutionWidth" = fn () objc.UInteger;
        pub const @"-staticThreadgroupMemoryLength" = fn () objc.UInteger;
        pub const @"-supportIndirectCommandBuffers" = fn () bool;
        pub const @"-gpuResourceID" = fn () ResourceID;
        pub const @"-shaderValidation" = fn () ShaderValidation;
        pub const @"-requiredThreadsPerThreadgroup" = fn () Size;
        pub const @"-forwardProgressUsage" = fn () ForwardProgressUsage;
    };
};

/// An object conforming to `MTLDepthStencilState`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const DepthStencilState = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "MTLDepthStencilState";

    /// An object that came from elsewhere, taken to conform to `MTLDepthStencilState`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLDepthStencilState label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLDepthStencilState device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLDepthStencilState gpuResourceID]`
    pub fn gpuResourceID(self: Self) ResourceID {
        return self.object.msgSend(ResourceID, "gpuResourceID", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-device" = fn () Device;
        pub const @"-gpuResourceID" = fn () ResourceID;
    };
};

/// An object conforming to `MTLSamplerState`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const SamplerState = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "MTLSamplerState";

    /// An object that came from elsewhere, taken to conform to `MTLSamplerState`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLSamplerState label]`
    pub fn label(self: Self) ?foundation.String {
        return self.object.msgSend(?foundation.String, "label", .{});
    }

    /// `-[MTLSamplerState device]`
    pub fn device(self: Self) Device {
        return self.object.msgSend(Device, "device", .{});
    }

    /// `-[MTLSamplerState gpuResourceID]`
    pub fn gpuResourceID(self: Self) ResourceID {
        return self.object.msgSend(ResourceID, "gpuResourceID", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-label" = fn () ?foundation.String;
        pub const @"-device" = fn () Device;
        pub const @"-gpuResourceID" = fn () ResourceID;
    };
};

/// An object conforming to `MTLDrawable`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const Drawable = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = objc.Object;
    pub const protocol_name = "MTLDrawable";

    /// An object that came from elsewhere, taken to conform to `MTLDrawable`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[MTLDrawable present]`
    pub fn present(self: Self) void {
        return self.object.msgSend(void, "present", .{});
    }

    /// `-[MTLDrawable presentAtTime:]`
    pub fn presentAtTime(self: Self, presentation_time: f64) void {
        return self.object.msgSend(void, "presentAtTime:", .{presentation_time});
    }

    /// `-[MTLDrawable presentAfterMinimumDuration:]`
    pub fn presentAfterMinimumDuration(self: Self, duration: f64) void {
        return self.object.msgSend(void, "presentAfterMinimumDuration:", .{duration});
    }

    /// `-[MTLDrawable addPresentedHandler:]`
    pub fn addPresentedHandler(self: Self, block: ?objc.BlockRef(fn (Drawable) void)) void {
        return self.object.msgSend(void, "addPresentedHandler:", .{block});
    }

    /// `-[MTLDrawable presentedTime]`
    pub fn presentedTime(self: Self) f64 {
        return self.object.msgSend(f64, "presentedTime", .{});
    }

    /// `-[MTLDrawable drawableID]`
    pub fn drawableID(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "drawableID", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-present" = fn () void;
        pub const @"-presentAtTime:" = fn (f64) void;
        pub const @"-presentAfterMinimumDuration:" = fn (f64) void;
        pub const @"-addPresentedHandler:" = fn (?objc.BlockRef(fn (Drawable) void)) void;
        pub const @"-presentedTime" = fn () f64;
        pub const @"-drawableID" = fn () objc.UInteger;
    };
};

/// An object conforming to `CAMetalDrawable`, which extends `MTLDrawable`. As an `objc.Subclass`
/// protocol, each method the class implements is checked against it.
pub const MetalDrawable = extern struct {
    object: objc.Object,

    const Self = @This();
    pub const Super = Drawable;
    pub const protocol_name = "CAMetalDrawable";

    /// An object that came from elsewhere, taken to conform to `CAMetalDrawable`.
    pub fn from(object: objc.Object) Self {
        return .{ .object = object };
    }

    /// This object as a parent protocol's wrapper, or `objc.Object`.
    pub fn into(self: Self, comptime T: type) T {
        if (!comptime inherits(Self, T)) @compileError(protocol_name ++ " does not inherit from " ++ @typeName(T));
        return objc.abi.wrap(T, self.object);
    }

    pub fn retain(self: Self) Self {
        return .{ .object = self.object.retain() };
    }

    pub fn release(self: Self) void {
        self.object.release();
    }

    pub fn autorelease(self: Self) Self {
        return .{ .object = self.object.autorelease() };
    }

    /// `-[CAMetalDrawable texture]`
    pub fn texture(self: Self) Texture {
        return self.object.msgSend(Texture, "texture", .{});
    }

    /// `-[CAMetalDrawable layer]`
    pub fn layer(self: Self) MetalLayer {
        return self.object.msgSend(MetalLayer, "layer", .{});
    }

    /// `-[MTLDrawable present]`
    pub fn present(self: Self) void {
        return self.object.msgSend(void, "present", .{});
    }

    /// `-[MTLDrawable presentAtTime:]`
    pub fn presentAtTime(self: Self, presentation_time: f64) void {
        return self.object.msgSend(void, "presentAtTime:", .{presentation_time});
    }

    /// `-[MTLDrawable presentAfterMinimumDuration:]`
    pub fn presentAfterMinimumDuration(self: Self, duration: f64) void {
        return self.object.msgSend(void, "presentAfterMinimumDuration:", .{duration});
    }

    /// `-[MTLDrawable addPresentedHandler:]`
    pub fn addPresentedHandler(self: Self, block: ?objc.BlockRef(fn (Drawable) void)) void {
        return self.object.msgSend(void, "addPresentedHandler:", .{block});
    }

    /// `-[MTLDrawable presentedTime]`
    pub fn presentedTime(self: Self) f64 {
        return self.object.msgSend(f64, "presentedTime", .{});
    }

    /// `-[MTLDrawable drawableID]`
    pub fn drawableID(self: Self) objc.UInteger {
        return self.object.msgSend(objc.UInteger, "drawableID", .{});
    }

    /// Each method's signature, for `objc.Subclass` to check overrides against.
    pub const signatures = struct {
        pub const @"-texture" = fn () Texture;
        pub const @"-layer" = fn () MetalLayer;
    };
};

// -- constants and functions -----------------------------------------------

/// `MTLTensorDomain`.
pub fn tensorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLTensorDomain", .linkage = .weak }) orelse missing("MTLTensorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLLibraryErrorDomain`.
pub fn libraryErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLLibraryErrorDomain", .linkage = .weak }) orelse missing("MTLLibraryErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterTimestamp`.
pub fn commonCounterTimestamp() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterTimestamp", .linkage = .weak }) orelse missing("MTLCommonCounterTimestamp");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterTessellationInputPatches`.
pub fn commonCounterTessellationInputPatches() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterTessellationInputPatches", .linkage = .weak }) orelse missing("MTLCommonCounterTessellationInputPatches");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterVertexInvocations`.
pub fn commonCounterVertexInvocations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterVertexInvocations", .linkage = .weak }) orelse missing("MTLCommonCounterVertexInvocations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterPostTessellationVertexInvocations`.
pub fn commonCounterPostTessellationVertexInvocations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterPostTessellationVertexInvocations", .linkage = .weak }) orelse missing("MTLCommonCounterPostTessellationVertexInvocations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterClipperInvocations`.
pub fn commonCounterClipperInvocations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterClipperInvocations", .linkage = .weak }) orelse missing("MTLCommonCounterClipperInvocations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterClipperPrimitivesOut`.
pub fn commonCounterClipperPrimitivesOut() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterClipperPrimitivesOut", .linkage = .weak }) orelse missing("MTLCommonCounterClipperPrimitivesOut");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterFragmentInvocations`.
pub fn commonCounterFragmentInvocations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterFragmentInvocations", .linkage = .weak }) orelse missing("MTLCommonCounterFragmentInvocations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterFragmentsPassed`.
pub fn commonCounterFragmentsPassed() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterFragmentsPassed", .linkage = .weak }) orelse missing("MTLCommonCounterFragmentsPassed");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterComputeKernelInvocations`.
pub fn commonCounterComputeKernelInvocations() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterComputeKernelInvocations", .linkage = .weak }) orelse missing("MTLCommonCounterComputeKernelInvocations");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterTotalCycles`.
pub fn commonCounterTotalCycles() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterTotalCycles", .linkage = .weak }) orelse missing("MTLCommonCounterTotalCycles");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterVertexCycles`.
pub fn commonCounterVertexCycles() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterVertexCycles", .linkage = .weak }) orelse missing("MTLCommonCounterVertexCycles");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterTessellationCycles`.
pub fn commonCounterTessellationCycles() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterTessellationCycles", .linkage = .weak }) orelse missing("MTLCommonCounterTessellationCycles");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterPostTessellationVertexCycles`.
pub fn commonCounterPostTessellationVertexCycles() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterPostTessellationVertexCycles", .linkage = .weak }) orelse missing("MTLCommonCounterPostTessellationVertexCycles");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterFragmentCycles`.
pub fn commonCounterFragmentCycles() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterFragmentCycles", .linkage = .weak }) orelse missing("MTLCommonCounterFragmentCycles");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterRenderTargetWriteCycles`.
pub fn commonCounterRenderTargetWriteCycles() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterRenderTargetWriteCycles", .linkage = .weak }) orelse missing("MTLCommonCounterRenderTargetWriteCycles");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterSetTimestamp`.
pub fn commonCounterSetTimestamp() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterSetTimestamp", .linkage = .weak }) orelse missing("MTLCommonCounterSetTimestamp");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterSetStageUtilization`.
pub fn commonCounterSetStageUtilization() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterSetStageUtilization", .linkage = .weak }) orelse missing("MTLCommonCounterSetStageUtilization");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommonCounterSetStatistic`.
pub fn commonCounterSetStatistic() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommonCounterSetStatistic", .linkage = .weak }) orelse missing("MTLCommonCounterSetStatistic");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCounterErrorDomain`.
pub fn counterErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCounterErrorDomain", .linkage = .weak }) orelse missing("MTLCounterErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCreateSystemDefaultDevice`. What it returns is yours to release.
pub fn createSystemDefaultDevice() ?Device {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(?Device), .{ .name = "MTLCreateSystemDefaultDevice", .linkage = .weak }) orelse missing("MTLCreateSystemDefaultDevice");
    return objc.abi.fromAbi(?Device, function());
}

/// `MTLCopyAllDevices`. What it returns is yours to release.
pub fn copyAllDevices() foundation.Array(Device) {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(foundation.Array(Device)), .{ .name = "MTLCopyAllDevices", .linkage = .weak }) orelse missing("MTLCopyAllDevices");
    return objc.abi.fromAbi(foundation.Array(Device), function());
}

/// `MTLDeviceWasAddedNotification`.
pub fn deviceWasAddedNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLDeviceWasAddedNotification", .linkage = .weak }) orelse missing("MTLDeviceWasAddedNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLDeviceRemovalRequestedNotification`.
pub fn deviceRemovalRequestedNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLDeviceRemovalRequestedNotification", .linkage = .weak }) orelse missing("MTLDeviceRemovalRequestedNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLDeviceWasRemovedNotification`.
pub fn deviceWasRemovedNotification() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLDeviceWasRemovedNotification", .linkage = .weak }) orelse missing("MTLDeviceWasRemovedNotification");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCopyAllDevicesWithObserver`. What it returns is yours to release.
pub fn copyAllDevicesWithObserver(observer: [*]objc.Nullable(objc.Object), handler: ?objc.BlockRef(fn (Device, foundation.String) void)) foundation.Array(Device) {
    const function = @extern(?*const fn (objc.abi.Abi([*]objc.Nullable(objc.Object)), objc.abi.Abi(?objc.BlockRef(fn (Device, foundation.String) void))) callconv(.c) objc.abi.Abi(foundation.Array(Device)), .{ .name = "MTLCopyAllDevicesWithObserver", .linkage = .weak }) orelse missing("MTLCopyAllDevicesWithObserver");
    return objc.abi.fromAbi(foundation.Array(Device), function(objc.abi.toAbi([*]objc.Nullable(objc.Object), observer), objc.abi.toAbi(?objc.BlockRef(fn (Device, foundation.String) void), handler)));
}

/// `MTLRemoveDeviceObserver`.
pub fn removeDeviceObserver(observer: objc.Object) void {
    const function = @extern(?*const fn (objc.abi.Abi(objc.Object)) callconv(.c) objc.abi.Abi(void), .{ .name = "MTLRemoveDeviceObserver", .linkage = .weak }) orelse missing("MTLRemoveDeviceObserver");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(objc.Object, observer)));
}

/// `MTLDeviceErrorDomain`.
pub fn deviceErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLDeviceErrorDomain", .linkage = .weak }) orelse missing("MTLDeviceErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommandBufferErrorDomain`.
pub fn commandBufferErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommandBufferErrorDomain", .linkage = .weak }) orelse missing("MTLCommandBufferErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCommandBufferEncoderInfoErrorKey`.
pub fn commandBufferEncoderInfoErrorKey() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCommandBufferEncoderInfoErrorKey", .linkage = .weak }) orelse missing("MTLCommandBufferEncoderInfoErrorKey");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTL4CommandQueueErrorDomain`.
pub fn mtl4CommandQueueErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTL4CommandQueueErrorDomain", .linkage = .weak }) orelse missing("MTL4CommandQueueErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLCaptureErrorDomain`.
pub fn captureErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLCaptureErrorDomain", .linkage = .weak }) orelse missing("MTLCaptureErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLDynamicLibraryDomain`.
pub fn dynamicLibraryDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLDynamicLibraryDomain", .linkage = .weak }) orelse missing("MTLDynamicLibraryDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLLogStateErrorDomain`.
pub fn logStateErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLLogStateErrorDomain", .linkage = .weak }) orelse missing("MTLLogStateErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLBinaryArchiveDomain`.
pub fn binaryArchiveDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLBinaryArchiveDomain", .linkage = .weak }) orelse missing("MTLBinaryArchiveDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLIOErrorDomain`.
pub fn ioErrorDomain() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "MTLIOErrorDomain", .linkage = .weak }) orelse missing("MTLIOErrorDomain");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `MTLIOCompressionContextDefaultChunkSize`.
pub fn ioCompressionContextDefaultChunkSize() usize {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(usize), .{ .name = "MTLIOCompressionContextDefaultChunkSize", .linkage = .weak }) orelse missing("MTLIOCompressionContextDefaultChunkSize");
    return objc.abi.fromAbi(usize, function());
}

/// `MTLIOCreateCompressionContext`. What it returns is yours to release.
pub fn ioCreateCompressionContext(path: [*:0]const u8, @"type": IOCompressionMethod, chunk_size: usize) ?*anyopaque {
    const function = @extern(?*const fn (objc.abi.Abi([*:0]const u8), objc.abi.Abi(IOCompressionMethod), objc.abi.Abi(usize)) callconv(.c) objc.abi.Abi(?*anyopaque), .{ .name = "MTLIOCreateCompressionContext", .linkage = .weak }) orelse missing("MTLIOCreateCompressionContext");
    return objc.abi.fromAbi(?*anyopaque, function(objc.abi.toAbi([*:0]const u8, path), objc.abi.toAbi(IOCompressionMethod, @"type"), objc.abi.toAbi(usize, chunk_size)));
}

/// `MTLIOCompressionContextAppendData`.
pub fn ioCompressionContextAppendData(context: ?*anyopaque, data: ?*const anyopaque, size: usize) void {
    const function = @extern(?*const fn (objc.abi.Abi(?*anyopaque), objc.abi.Abi(?*const anyopaque), objc.abi.Abi(usize)) callconv(.c) objc.abi.Abi(void), .{ .name = "MTLIOCompressionContextAppendData", .linkage = .weak }) orelse missing("MTLIOCompressionContextAppendData");
    return objc.abi.fromAbi(void, function(objc.abi.toAbi(?*anyopaque, context), objc.abi.toAbi(?*const anyopaque, data), objc.abi.toAbi(usize, size)));
}

/// `CACurrentMediaTime`.
pub fn currentMediaTime() f64 {
    const function = @extern(?*const fn () callconv(.c) objc.abi.Abi(f64), .{ .name = "CACurrentMediaTime", .linkage = .weak }) orelse missing("CACurrentMediaTime");
    return objc.abi.fromAbi(f64, function());
}

/// `CATransform3DIdentity`.
pub fn transform3DIdentity() Transform3D {
    const symbol = @extern(?*const objc.abi.Abi(Transform3D), .{ .name = "CATransform3DIdentity", .linkage = .weak }) orelse missing("CATransform3DIdentity");
    return objc.abi.fromAbi(Transform3D, symbol.*);
}

/// `CATransform3DIsIdentity`.
pub fn transform3DIsIdentity(t: Transform3D) bool {
    const function = @extern(?*const fn (objc.abi.Abi(Transform3D)) callconv(.c) objc.abi.Abi(bool), .{ .name = "CATransform3DIsIdentity", .linkage = .weak }) orelse missing("CATransform3DIsIdentity");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(Transform3D, t)));
}

/// `CATransform3DEqualToTransform`.
pub fn transform3DEqualToTransform(a: Transform3D, b: Transform3D) bool {
    const function = @extern(?*const fn (objc.abi.Abi(Transform3D), objc.abi.Abi(Transform3D)) callconv(.c) objc.abi.Abi(bool), .{ .name = "CATransform3DEqualToTransform", .linkage = .weak }) orelse missing("CATransform3DEqualToTransform");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(Transform3D, a), objc.abi.toAbi(Transform3D, b)));
}

/// `CATransform3DMakeTranslation`.
pub fn transform3DMakeTranslation(tx: cg.Float, ty: cg.Float, tz: cg.Float) Transform3D {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float)) callconv(.c) objc.abi.Abi(Transform3D), .{ .name = "CATransform3DMakeTranslation", .linkage = .weak }) orelse missing("CATransform3DMakeTranslation");
    return objc.abi.fromAbi(Transform3D, function(objc.abi.toAbi(cg.Float, tx), objc.abi.toAbi(cg.Float, ty), objc.abi.toAbi(cg.Float, tz)));
}

/// `CATransform3DMakeScale`.
pub fn transform3DMakeScale(sx: cg.Float, sy: cg.Float, sz: cg.Float) Transform3D {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float)) callconv(.c) objc.abi.Abi(Transform3D), .{ .name = "CATransform3DMakeScale", .linkage = .weak }) orelse missing("CATransform3DMakeScale");
    return objc.abi.fromAbi(Transform3D, function(objc.abi.toAbi(cg.Float, sx), objc.abi.toAbi(cg.Float, sy), objc.abi.toAbi(cg.Float, sz)));
}

/// `CATransform3DMakeRotation`.
pub fn transform3DMakeRotation(angle: cg.Float, x: cg.Float, y: cg.Float, z: cg.Float) Transform3D {
    const function = @extern(?*const fn (objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float)) callconv(.c) objc.abi.Abi(Transform3D), .{ .name = "CATransform3DMakeRotation", .linkage = .weak }) orelse missing("CATransform3DMakeRotation");
    return objc.abi.fromAbi(Transform3D, function(objc.abi.toAbi(cg.Float, angle), objc.abi.toAbi(cg.Float, x), objc.abi.toAbi(cg.Float, y), objc.abi.toAbi(cg.Float, z)));
}

/// `CATransform3DTranslate`.
pub fn transform3DTranslate(t: Transform3D, tx: cg.Float, ty: cg.Float, tz: cg.Float) Transform3D {
    const function = @extern(?*const fn (objc.abi.Abi(Transform3D), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float)) callconv(.c) objc.abi.Abi(Transform3D), .{ .name = "CATransform3DTranslate", .linkage = .weak }) orelse missing("CATransform3DTranslate");
    return objc.abi.fromAbi(Transform3D, function(objc.abi.toAbi(Transform3D, t), objc.abi.toAbi(cg.Float, tx), objc.abi.toAbi(cg.Float, ty), objc.abi.toAbi(cg.Float, tz)));
}

/// `CATransform3DScale`.
pub fn transform3DScale(t: Transform3D, sx: cg.Float, sy: cg.Float, sz: cg.Float) Transform3D {
    const function = @extern(?*const fn (objc.abi.Abi(Transform3D), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float)) callconv(.c) objc.abi.Abi(Transform3D), .{ .name = "CATransform3DScale", .linkage = .weak }) orelse missing("CATransform3DScale");
    return objc.abi.fromAbi(Transform3D, function(objc.abi.toAbi(Transform3D, t), objc.abi.toAbi(cg.Float, sx), objc.abi.toAbi(cg.Float, sy), objc.abi.toAbi(cg.Float, sz)));
}

/// `CATransform3DRotate`.
pub fn transform3DRotate(t: Transform3D, angle: cg.Float, x: cg.Float, y: cg.Float, z: cg.Float) Transform3D {
    const function = @extern(?*const fn (objc.abi.Abi(Transform3D), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float), objc.abi.Abi(cg.Float)) callconv(.c) objc.abi.Abi(Transform3D), .{ .name = "CATransform3DRotate", .linkage = .weak }) orelse missing("CATransform3DRotate");
    return objc.abi.fromAbi(Transform3D, function(objc.abi.toAbi(Transform3D, t), objc.abi.toAbi(cg.Float, angle), objc.abi.toAbi(cg.Float, x), objc.abi.toAbi(cg.Float, y), objc.abi.toAbi(cg.Float, z)));
}

/// `CATransform3DConcat`.
pub fn transform3DConcat(a: Transform3D, b: Transform3D) Transform3D {
    const function = @extern(?*const fn (objc.abi.Abi(Transform3D), objc.abi.Abi(Transform3D)) callconv(.c) objc.abi.Abi(Transform3D), .{ .name = "CATransform3DConcat", .linkage = .weak }) orelse missing("CATransform3DConcat");
    return objc.abi.fromAbi(Transform3D, function(objc.abi.toAbi(Transform3D, a), objc.abi.toAbi(Transform3D, b)));
}

/// `CATransform3DInvert`.
pub fn transform3DInvert(t: Transform3D) Transform3D {
    const function = @extern(?*const fn (objc.abi.Abi(Transform3D)) callconv(.c) objc.abi.Abi(Transform3D), .{ .name = "CATransform3DInvert", .linkage = .weak }) orelse missing("CATransform3DInvert");
    return objc.abi.fromAbi(Transform3D, function(objc.abi.toAbi(Transform3D, t)));
}

/// `CATransform3DMakeAffineTransform`.
pub fn transform3DMakeAffineTransform(m: cg.AffineTransform) Transform3D {
    const function = @extern(?*const fn (objc.abi.Abi(cg.AffineTransform)) callconv(.c) objc.abi.Abi(Transform3D), .{ .name = "CATransform3DMakeAffineTransform", .linkage = .weak }) orelse missing("CATransform3DMakeAffineTransform");
    return objc.abi.fromAbi(Transform3D, function(objc.abi.toAbi(cg.AffineTransform, m)));
}

/// `CATransform3DIsAffine`.
pub fn transform3DIsAffine(t: Transform3D) bool {
    const function = @extern(?*const fn (objc.abi.Abi(Transform3D)) callconv(.c) objc.abi.Abi(bool), .{ .name = "CATransform3DIsAffine", .linkage = .weak }) orelse missing("CATransform3DIsAffine");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(Transform3D, t)));
}

/// `CATransform3DGetAffineTransform`.
pub fn transform3DGetAffineTransform(t: Transform3D) cg.AffineTransform {
    const function = @extern(?*const fn (objc.abi.Abi(Transform3D)) callconv(.c) objc.abi.Abi(cg.AffineTransform), .{ .name = "CATransform3DGetAffineTransform", .linkage = .weak }) orelse missing("CATransform3DGetAffineTransform");
    return objc.abi.fromAbi(cg.AffineTransform, function(objc.abi.toAbi(Transform3D, t)));
}

/// `kCAFillModeForwards`.
pub fn fillModeForwards() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAFillModeForwards", .linkage = .weak }) orelse missing("kCAFillModeForwards");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAFillModeBackwards`.
pub fn fillModeBackwards() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAFillModeBackwards", .linkage = .weak }) orelse missing("kCAFillModeBackwards");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAFillModeBoth`.
pub fn fillModeBoth() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAFillModeBoth", .linkage = .weak }) orelse missing("kCAFillModeBoth");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAFillModeRemoved`.
pub fn fillModeRemoved() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAFillModeRemoved", .linkage = .weak }) orelse missing("kCAFillModeRemoved");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `CAToneMapModeAutomatic`.
pub fn toneMapModeAutomatic() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "CAToneMapModeAutomatic", .linkage = .weak }) orelse missing("CAToneMapModeAutomatic");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `CAToneMapModeNever`.
pub fn toneMapModeNever() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "CAToneMapModeNever", .linkage = .weak }) orelse missing("CAToneMapModeNever");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `CAToneMapModeIfSupported`.
pub fn toneMapModeIfSupported() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "CAToneMapModeIfSupported", .linkage = .weak }) orelse missing("CAToneMapModeIfSupported");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `CADynamicRangeAutomatic`.
pub fn dynamicRangeAutomatic() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "CADynamicRangeAutomatic", .linkage = .weak }) orelse missing("CADynamicRangeAutomatic");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `CADynamicRangeStandard`.
pub fn dynamicRangeStandard() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "CADynamicRangeStandard", .linkage = .weak }) orelse missing("CADynamicRangeStandard");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `CADynamicRangeConstrainedHigh`.
pub fn dynamicRangeConstrainedHigh() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "CADynamicRangeConstrainedHigh", .linkage = .weak }) orelse missing("CADynamicRangeConstrainedHigh");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `CADynamicRangeHigh`.
pub fn dynamicRangeHigh() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "CADynamicRangeHigh", .linkage = .weak }) orelse missing("CADynamicRangeHigh");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGravityCenter`.
pub fn gravityCenter() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGravityCenter", .linkage = .weak }) orelse missing("kCAGravityCenter");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGravityTop`.
pub fn gravityTop() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGravityTop", .linkage = .weak }) orelse missing("kCAGravityTop");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGravityBottom`.
pub fn gravityBottom() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGravityBottom", .linkage = .weak }) orelse missing("kCAGravityBottom");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGravityLeft`.
pub fn gravityLeft() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGravityLeft", .linkage = .weak }) orelse missing("kCAGravityLeft");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGravityRight`.
pub fn gravityRight() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGravityRight", .linkage = .weak }) orelse missing("kCAGravityRight");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGravityTopLeft`.
pub fn gravityTopLeft() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGravityTopLeft", .linkage = .weak }) orelse missing("kCAGravityTopLeft");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGravityTopRight`.
pub fn gravityTopRight() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGravityTopRight", .linkage = .weak }) orelse missing("kCAGravityTopRight");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGravityBottomLeft`.
pub fn gravityBottomLeft() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGravityBottomLeft", .linkage = .weak }) orelse missing("kCAGravityBottomLeft");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGravityBottomRight`.
pub fn gravityBottomRight() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGravityBottomRight", .linkage = .weak }) orelse missing("kCAGravityBottomRight");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGravityResize`.
pub fn gravityResize() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGravityResize", .linkage = .weak }) orelse missing("kCAGravityResize");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGravityResizeAspect`.
pub fn gravityResizeAspect() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGravityResizeAspect", .linkage = .weak }) orelse missing("kCAGravityResizeAspect");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGravityResizeAspectFill`.
pub fn gravityResizeAspectFill() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGravityResizeAspectFill", .linkage = .weak }) orelse missing("kCAGravityResizeAspectFill");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAContentsFormatRGBA8Uint`.
pub fn contentsFormatRGBA8Uint() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAContentsFormatRGBA8Uint", .linkage = .weak }) orelse missing("kCAContentsFormatRGBA8Uint");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAContentsFormatRGBA16Float`.
pub fn contentsFormatRGBA16Float() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAContentsFormatRGBA16Float", .linkage = .weak }) orelse missing("kCAContentsFormatRGBA16Float");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAContentsFormatGray8Uint`.
pub fn contentsFormatGray8Uint() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAContentsFormatGray8Uint", .linkage = .weak }) orelse missing("kCAContentsFormatGray8Uint");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAContentsFormatAutomatic`.
pub fn contentsFormatAutomatic() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAContentsFormatAutomatic", .linkage = .weak }) orelse missing("kCAContentsFormatAutomatic");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAFilterNearest`.
pub fn filterNearest() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAFilterNearest", .linkage = .weak }) orelse missing("kCAFilterNearest");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAFilterLinear`.
pub fn filterLinear() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAFilterLinear", .linkage = .weak }) orelse missing("kCAFilterLinear");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAFilterTrilinear`.
pub fn filterTrilinear() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAFilterTrilinear", .linkage = .weak }) orelse missing("kCAFilterTrilinear");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCACornerCurveCircular`.
pub fn cornerCurveCircular() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCACornerCurveCircular", .linkage = .weak }) orelse missing("kCACornerCurveCircular");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCACornerCurveContinuous`.
pub fn cornerCurveContinuous() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCACornerCurveContinuous", .linkage = .weak }) orelse missing("kCACornerCurveContinuous");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAOnOrderIn`.
pub fn onOrderIn() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAOnOrderIn", .linkage = .weak }) orelse missing("kCAOnOrderIn");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAOnOrderOut`.
pub fn onOrderOut() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAOnOrderOut", .linkage = .weak }) orelse missing("kCAOnOrderOut");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransition`.
pub fn transition() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransition", .linkage = .weak }) orelse missing("kCATransition");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `CAFrameRateRangeDefault`.
pub fn frameRateRangeDefault() FrameRateRange {
    const symbol = @extern(?*const objc.abi.Abi(FrameRateRange), .{ .name = "CAFrameRateRangeDefault", .linkage = .weak }) orelse missing("CAFrameRateRangeDefault");
    return objc.abi.fromAbi(FrameRateRange, symbol.*);
}

/// `CAFrameRateRangeMake`.
pub fn frameRateRangeMake(minimum: f32, maximum: f32, preferred: f32) FrameRateRange {
    const function = @extern(?*const fn (objc.abi.Abi(f32), objc.abi.Abi(f32), objc.abi.Abi(f32)) callconv(.c) objc.abi.Abi(FrameRateRange), .{ .name = "CAFrameRateRangeMake", .linkage = .weak }) orelse missing("CAFrameRateRangeMake");
    return objc.abi.fromAbi(FrameRateRange, function(objc.abi.toAbi(f32, minimum), objc.abi.toAbi(f32, maximum), objc.abi.toAbi(f32, preferred)));
}

/// `CAFrameRateRangeIsEqualToRange`.
pub fn frameRateRangeIsEqualToRange(range: FrameRateRange, other: FrameRateRange) bool {
    const function = @extern(?*const fn (objc.abi.Abi(FrameRateRange), objc.abi.Abi(FrameRateRange)) callconv(.c) objc.abi.Abi(bool), .{ .name = "CAFrameRateRangeIsEqualToRange", .linkage = .weak }) orelse missing("CAFrameRateRangeIsEqualToRange");
    return objc.abi.fromAbi(bool, function(objc.abi.toAbi(FrameRateRange, range), objc.abi.toAbi(FrameRateRange, other)));
}

/// `kCAAnimationLinear`.
pub fn animationLinear() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAAnimationLinear", .linkage = .weak }) orelse missing("kCAAnimationLinear");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAAnimationDiscrete`.
pub fn animationDiscrete() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAAnimationDiscrete", .linkage = .weak }) orelse missing("kCAAnimationDiscrete");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAAnimationPaced`.
pub fn animationPaced() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAAnimationPaced", .linkage = .weak }) orelse missing("kCAAnimationPaced");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAAnimationCubic`.
pub fn animationCubic() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAAnimationCubic", .linkage = .weak }) orelse missing("kCAAnimationCubic");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAAnimationCubicPaced`.
pub fn animationCubicPaced() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAAnimationCubicPaced", .linkage = .weak }) orelse missing("kCAAnimationCubicPaced");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAAnimationRotateAuto`.
pub fn animationRotateAuto() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAAnimationRotateAuto", .linkage = .weak }) orelse missing("kCAAnimationRotateAuto");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAAnimationRotateAutoReverse`.
pub fn animationRotateAutoReverse() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAAnimationRotateAutoReverse", .linkage = .weak }) orelse missing("kCAAnimationRotateAutoReverse");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransitionFade`.
pub fn transitionFade() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransitionFade", .linkage = .weak }) orelse missing("kCATransitionFade");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransitionMoveIn`.
pub fn transitionMoveIn() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransitionMoveIn", .linkage = .weak }) orelse missing("kCATransitionMoveIn");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransitionPush`.
pub fn transitionPush() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransitionPush", .linkage = .weak }) orelse missing("kCATransitionPush");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransitionReveal`.
pub fn transitionReveal() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransitionReveal", .linkage = .weak }) orelse missing("kCATransitionReveal");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransitionFromRight`.
pub fn transitionFromRight() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransitionFromRight", .linkage = .weak }) orelse missing("kCATransitionFromRight");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransitionFromLeft`.
pub fn transitionFromLeft() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransitionFromLeft", .linkage = .weak }) orelse missing("kCATransitionFromLeft");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransitionFromTop`.
pub fn transitionFromTop() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransitionFromTop", .linkage = .weak }) orelse missing("kCATransitionFromTop");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransitionFromBottom`.
pub fn transitionFromBottom() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransitionFromBottom", .linkage = .weak }) orelse missing("kCATransitionFromBottom");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerPoint`.
pub fn emitterLayerPoint() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerPoint", .linkage = .weak }) orelse missing("kCAEmitterLayerPoint");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerLine`.
pub fn emitterLayerLine() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerLine", .linkage = .weak }) orelse missing("kCAEmitterLayerLine");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerRectangle`.
pub fn emitterLayerRectangle() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerRectangle", .linkage = .weak }) orelse missing("kCAEmitterLayerRectangle");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerCuboid`.
pub fn emitterLayerCuboid() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerCuboid", .linkage = .weak }) orelse missing("kCAEmitterLayerCuboid");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerCircle`.
pub fn emitterLayerCircle() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerCircle", .linkage = .weak }) orelse missing("kCAEmitterLayerCircle");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerSphere`.
pub fn emitterLayerSphere() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerSphere", .linkage = .weak }) orelse missing("kCAEmitterLayerSphere");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerPoints`.
pub fn emitterLayerPoints() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerPoints", .linkage = .weak }) orelse missing("kCAEmitterLayerPoints");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerOutline`.
pub fn emitterLayerOutline() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerOutline", .linkage = .weak }) orelse missing("kCAEmitterLayerOutline");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerSurface`.
pub fn emitterLayerSurface() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerSurface", .linkage = .weak }) orelse missing("kCAEmitterLayerSurface");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerVolume`.
pub fn emitterLayerVolume() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerVolume", .linkage = .weak }) orelse missing("kCAEmitterLayerVolume");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerUnordered`.
pub fn emitterLayerUnordered() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerUnordered", .linkage = .weak }) orelse missing("kCAEmitterLayerUnordered");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerOldestFirst`.
pub fn emitterLayerOldestFirst() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerOldestFirst", .linkage = .weak }) orelse missing("kCAEmitterLayerOldestFirst");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerOldestLast`.
pub fn emitterLayerOldestLast() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerOldestLast", .linkage = .weak }) orelse missing("kCAEmitterLayerOldestLast");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerBackToFront`.
pub fn emitterLayerBackToFront() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerBackToFront", .linkage = .weak }) orelse missing("kCAEmitterLayerBackToFront");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAEmitterLayerAdditive`.
pub fn emitterLayerAdditive() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAEmitterLayerAdditive", .linkage = .weak }) orelse missing("kCAEmitterLayerAdditive");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAMediaTimingFunctionLinear`.
pub fn mediaTimingFunctionLinear() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAMediaTimingFunctionLinear", .linkage = .weak }) orelse missing("kCAMediaTimingFunctionLinear");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAMediaTimingFunctionEaseIn`.
pub fn mediaTimingFunctionEaseIn() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAMediaTimingFunctionEaseIn", .linkage = .weak }) orelse missing("kCAMediaTimingFunctionEaseIn");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAMediaTimingFunctionEaseOut`.
pub fn mediaTimingFunctionEaseOut() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAMediaTimingFunctionEaseOut", .linkage = .weak }) orelse missing("kCAMediaTimingFunctionEaseOut");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAMediaTimingFunctionEaseInEaseOut`.
pub fn mediaTimingFunctionEaseInEaseOut() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAMediaTimingFunctionEaseInEaseOut", .linkage = .weak }) orelse missing("kCAMediaTimingFunctionEaseInEaseOut");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAMediaTimingFunctionDefault`.
pub fn mediaTimingFunctionDefault() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAMediaTimingFunctionDefault", .linkage = .weak }) orelse missing("kCAMediaTimingFunctionDefault");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGradientLayerAxial`.
pub fn gradientLayerAxial() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGradientLayerAxial", .linkage = .weak }) orelse missing("kCAGradientLayerAxial");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGradientLayerRadial`.
pub fn gradientLayerRadial() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGradientLayerRadial", .linkage = .weak }) orelse missing("kCAGradientLayerRadial");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAGradientLayerConic`.
pub fn gradientLayerConic() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAGradientLayerConic", .linkage = .weak }) orelse missing("kCAGradientLayerConic");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCARendererColorSpace`.
pub fn rendererColorSpace() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCARendererColorSpace", .linkage = .weak }) orelse missing("kCARendererColorSpace");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCARendererMetalCommandQueue`.
pub fn rendererMetalCommandQueue() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCARendererMetalCommandQueue", .linkage = .weak }) orelse missing("kCARendererMetalCommandQueue");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAScrollNone`.
pub fn scrollNone() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAScrollNone", .linkage = .weak }) orelse missing("kCAScrollNone");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAScrollVertically`.
pub fn scrollVertically() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAScrollVertically", .linkage = .weak }) orelse missing("kCAScrollVertically");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAScrollHorizontally`.
pub fn scrollHorizontally() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAScrollHorizontally", .linkage = .weak }) orelse missing("kCAScrollHorizontally");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAScrollBoth`.
pub fn scrollBoth() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAScrollBoth", .linkage = .weak }) orelse missing("kCAScrollBoth");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAFillRuleNonZero`.
pub fn fillRuleNonZero() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAFillRuleNonZero", .linkage = .weak }) orelse missing("kCAFillRuleNonZero");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAFillRuleEvenOdd`.
pub fn fillRuleEvenOdd() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAFillRuleEvenOdd", .linkage = .weak }) orelse missing("kCAFillRuleEvenOdd");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCALineJoinMiter`.
pub fn lineJoinMiter() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCALineJoinMiter", .linkage = .weak }) orelse missing("kCALineJoinMiter");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCALineJoinRound`.
pub fn lineJoinRound() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCALineJoinRound", .linkage = .weak }) orelse missing("kCALineJoinRound");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCALineJoinBevel`.
pub fn lineJoinBevel() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCALineJoinBevel", .linkage = .weak }) orelse missing("kCALineJoinBevel");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCALineCapButt`.
pub fn lineCapButt() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCALineCapButt", .linkage = .weak }) orelse missing("kCALineCapButt");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCALineCapRound`.
pub fn lineCapRound() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCALineCapRound", .linkage = .weak }) orelse missing("kCALineCapRound");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCALineCapSquare`.
pub fn lineCapSquare() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCALineCapSquare", .linkage = .weak }) orelse missing("kCALineCapSquare");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATruncationNone`.
pub fn truncationNone() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATruncationNone", .linkage = .weak }) orelse missing("kCATruncationNone");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATruncationStart`.
pub fn truncationStart() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATruncationStart", .linkage = .weak }) orelse missing("kCATruncationStart");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATruncationEnd`.
pub fn truncationEnd() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATruncationEnd", .linkage = .weak }) orelse missing("kCATruncationEnd");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATruncationMiddle`.
pub fn truncationMiddle() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATruncationMiddle", .linkage = .weak }) orelse missing("kCATruncationMiddle");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAAlignmentNatural`.
pub fn alignmentNatural() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAAlignmentNatural", .linkage = .weak }) orelse missing("kCAAlignmentNatural");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAAlignmentLeft`.
pub fn alignmentLeft() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAAlignmentLeft", .linkage = .weak }) orelse missing("kCAAlignmentLeft");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAAlignmentRight`.
pub fn alignmentRight() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAAlignmentRight", .linkage = .weak }) orelse missing("kCAAlignmentRight");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAAlignmentCenter`.
pub fn alignmentCenter() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAAlignmentCenter", .linkage = .weak }) orelse missing("kCAAlignmentCenter");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAAlignmentJustified`.
pub fn alignmentJustified() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAAlignmentJustified", .linkage = .weak }) orelse missing("kCAAlignmentJustified");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransactionAnimationDuration`.
pub fn transactionAnimationDuration() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransactionAnimationDuration", .linkage = .weak }) orelse missing("kCATransactionAnimationDuration");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransactionDisableActions`.
pub fn transactionDisableActions() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransactionDisableActions", .linkage = .weak }) orelse missing("kCATransactionDisableActions");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransactionAnimationTimingFunction`.
pub fn transactionAnimationTimingFunction() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransactionAnimationTimingFunction", .linkage = .weak }) orelse missing("kCATransactionAnimationTimingFunction");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCATransactionCompletionBlock`.
pub fn transactionCompletionBlock() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCATransactionCompletionBlock", .linkage = .weak }) orelse missing("kCATransactionCompletionBlock");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAValueFunctionRotateX`.
pub fn valueFunctionRotateX() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAValueFunctionRotateX", .linkage = .weak }) orelse missing("kCAValueFunctionRotateX");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAValueFunctionRotateY`.
pub fn valueFunctionRotateY() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAValueFunctionRotateY", .linkage = .weak }) orelse missing("kCAValueFunctionRotateY");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAValueFunctionRotateZ`.
pub fn valueFunctionRotateZ() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAValueFunctionRotateZ", .linkage = .weak }) orelse missing("kCAValueFunctionRotateZ");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAValueFunctionScale`.
pub fn valueFunctionScale() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAValueFunctionScale", .linkage = .weak }) orelse missing("kCAValueFunctionScale");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAValueFunctionScaleX`.
pub fn valueFunctionScaleX() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAValueFunctionScaleX", .linkage = .weak }) orelse missing("kCAValueFunctionScaleX");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAValueFunctionScaleY`.
pub fn valueFunctionScaleY() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAValueFunctionScaleY", .linkage = .weak }) orelse missing("kCAValueFunctionScaleY");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAValueFunctionScaleZ`.
pub fn valueFunctionScaleZ() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAValueFunctionScaleZ", .linkage = .weak }) orelse missing("kCAValueFunctionScaleZ");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAValueFunctionTranslate`.
pub fn valueFunctionTranslate() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAValueFunctionTranslate", .linkage = .weak }) orelse missing("kCAValueFunctionTranslate");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAValueFunctionTranslateX`.
pub fn valueFunctionTranslateX() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAValueFunctionTranslateX", .linkage = .weak }) orelse missing("kCAValueFunctionTranslateX");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAValueFunctionTranslateY`.
pub fn valueFunctionTranslateY() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAValueFunctionTranslateY", .linkage = .weak }) orelse missing("kCAValueFunctionTranslateY");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

/// `kCAValueFunctionTranslateZ`.
pub fn valueFunctionTranslateZ() foundation.String {
    const symbol = @extern(?*const objc.abi.Abi(foundation.String), .{ .name = "kCAValueFunctionTranslateZ", .linkage = .weak }) orelse missing("kCAValueFunctionTranslateZ");
    return objc.abi.fromAbi(foundation.String, symbol.*);
}

// Not generated:
//   MTLIOFlushAndDestroyCompressionContext: MTLIOCompressionStatus
