//! Colour spaces and colours.
//!
//! There are two ways to say "red" in CoreGraphics, and this module keeps
//! both because they cost different things:
//!
//! - `Rgba` is four numbers passed straight to `CGContextSetRGBFillColor`.
//!   Nothing is allocated and nothing needs releasing. This is what
//!   `Context.setFillColor` takes, and it is what almost all drawing wants.
//! - `Color` is a real `CGColorRef`: a colour bound to a colour space,
//!   reference counted, and the only way to say something that device RGB
//!   cannot -- a Display P3 red, a CMYK ink, a pattern. `Context` takes one
//!   through `setFillColorRef`.
//!
//! Colour *spaces* are reference counted too, and the device ones are not
//! free: `ColorSpace.deviceRgb()` creates a new object each time it is
//! called. Create one and keep it for the life of the drawing rather than
//! creating one per shape.

const std = @import("std");
const raw = @import("cg_raw");
const errors = @import("errors.zig");
const cf = @import("cf.zig");
const geometry = @import("geometry.zig");

const Error = errors.Error;
const Float = geometry.Float;

/// How out-of-gamut colours are handled when converting between spaces.
pub const RenderingIntent = enum(i32) {
    /// Whatever the colour space or the context prefers.
    default = 0,
    absolute_colorimetric = 1,
    relative_colorimetric = 2,
    /// Compresses the whole gamut so relationships survive. Right for
    /// photographs.
    perceptual = 3,
    /// Keeps colours vivid at the cost of accuracy. Right for charts.
    saturation = 4,
    _,
};

/// What kind of components a colour space has, which is also how many.
pub const Model = enum(i32) {
    unknown = -1,
    monochrome = 0,
    rgb = 1,
    cmyk = 2,
    lab = 3,
    device_n = 4,
    indexed = 5,
    pattern = 6,
    xyz = 7,
    _,
};

/// The colour spaces CoreGraphics ships with, named rather than spelled as
/// `CFStringRef` constants.
pub const Name = enum {
    srgb,
    extended_srgb,
    linear_srgb,
    display_p3,
    adobe_rgb_1998,
    generic_rgb,
    generic_rgb_linear,
    generic_gray,
    generic_gray_gamma_2_2,
    generic_cmyk,
    generic_lab,

    fn toRaw(self: Name) raw.CFStringRef {
        return switch (self) {
            .srgb => raw.kCGColorSpaceSRGB,
            .extended_srgb => raw.kCGColorSpaceExtendedSRGB,
            .linear_srgb => raw.kCGColorSpaceLinearSRGB,
            .display_p3 => raw.kCGColorSpaceDisplayP3,
            .adobe_rgb_1998 => raw.kCGColorSpaceAdobeRGB1998,
            .generic_rgb => raw.kCGColorSpaceGenericRGB,
            .generic_rgb_linear => raw.kCGColorSpaceGenericRGBLinear,
            .generic_gray => raw.kCGColorSpaceGenericGray,
            .generic_gray_gamma_2_2 => raw.kCGColorSpaceGenericGrayGamma2_2,
            .generic_cmyk => raw.kCGColorSpaceGenericCMYK,
            .generic_lab => raw.kCGColorSpaceGenericLab,
        };
    }
};

pub const ColorSpace = struct {
    handle: *raw.struct_CGColorSpace,

    /// The device's own RGB, uncalibrated. Fast, and what a throwaway
    /// bitmap usually wants.
    pub fn deviceRgb() Error!ColorSpace {
        return .{ .handle = try errors.checkPtr(raw.CGColorSpaceCreateDeviceRGB()) };
    }

    pub fn deviceGray() Error!ColorSpace {
        return .{ .handle = try errors.checkPtr(raw.CGColorSpaceCreateDeviceGray()) };
    }

    pub fn deviceCmyk() Error!ColorSpace {
        return .{ .handle = try errors.checkPtr(raw.CGColorSpaceCreateDeviceCMYK()) };
    }

    /// One of the colour spaces CoreGraphics ships with. `.srgb` is the
    /// right default for anything that will be written to a file or shown
    /// on a screen.
    pub fn named(which: Name) Error!ColorSpace {
        return .{ .handle = try errors.checkPtr(raw.CGColorSpaceCreateWithName(which.toRaw())) };
    }

    /// A colour space from an embedded ICC profile.
    pub fn initIccProfile(profile: cf.Data) Error!ColorSpace {
        const created = raw.CGColorSpaceCreateWithICCData(profile.toRaw());
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: ColorSpace) void {
        raw.CGColorSpaceRelease(self.handle);
    }

    pub fn retain(self: ColorSpace) ColorSpace {
        return .{ .handle = raw.CGColorSpaceRetain(self.handle).? };
    }

    pub fn fromRaw(value: raw.CGColorSpaceRef) ?ColorSpace {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: ColorSpace) raw.CGColorSpaceRef {
        return self.handle;
    }

    pub fn model(self: ColorSpace) Model {
        return @fromBackingInt(@intCast(raw.CGColorSpaceGetModel(self.handle)));
    }

    /// How many components a colour in this space has, *not* counting
    /// alpha. `Color.init` wants one more than this.
    pub fn componentCount(self: ColorSpace) usize {
        return raw.CGColorSpaceGetNumberOfComponents(self.handle);
    }

    /// The space's identifier, borrowed -- `"kCGColorSpaceSRGB"`,
    /// `"kCGColorSpaceDeviceRGB"` and so on. Null for spaces that have no
    /// identifier to give, such as one built from an ICC profile.
    pub fn name(self: ColorSpace) ?cf.String {
        return cf.String.fromRaw(raw.CGColorSpaceGetName(self.handle));
    }
};

/// Four components in device RGB, in the 0..1 range CoreGraphics uses
/// throughout -- not 0..255.
pub const Rgba = struct {
    r: Float,
    g: Float,
    b: Float,
    a: Float = 1,

    pub const black: Rgba = .{ .r = 0, .g = 0, .b = 0 };
    pub const white: Rgba = .{ .r = 1, .g = 1, .b = 1 };
    /// Fully transparent, which is not the same as `black` with alpha 0 for
    /// blend modes that read the colour.
    pub const clear: Rgba = .{ .r = 0, .g = 0, .b = 0, .a = 0 };

    pub fn rgb(r: Float, g: Float, b: Float) Rgba {
        return .{ .r = r, .g = g, .b = b };
    }

    pub fn rgba(r: Float, g: Float, b: Float, a: Float) Rgba {
        return .{ .r = r, .g = g, .b = b, .a = a };
    }

    /// A neutral grey in RGB. For a colour in a real grayscale space, use
    /// `Context.setFillGray`.
    pub fn gray(level: Float) Rgba {
        return .{ .r = level, .g = level, .b = level };
    }

    /// `0xRRGGBB`, the way colours are written everywhere except
    /// CoreGraphics. Values are treated as plain sRGB byte levels.
    pub fn hex(value: u24) Rgba {
        return .{
            .r = @as(Float, @floatFromInt((value >> 16) & 0xFF)) / 255,
            .g = @as(Float, @floatFromInt((value >> 8) & 0xFF)) / 255,
            .b = @as(Float, @floatFromInt(value & 0xFF)) / 255,
        };
    }

    pub fn withAlpha(self: Rgba, a: Float) Rgba {
        return .{ .r = self.r, .g = self.g, .b = self.b, .a = a };
    }
};

/// A level and an alpha in a grayscale space.
pub const Gray = struct {
    level: Float,
    a: Float = 1,
};

/// Four inks and an alpha. Meaningful for PDF output and print; on screen
/// it is converted.
pub const Cmyk = struct {
    c: Float,
    m: Float,
    y: Float,
    k: Float,
    a: Float = 1,
};

/// A `CGColorRef`: a colour that carries its colour space with it.
///
/// Worth the reference counting when the colour cannot be said in device
/// RGB -- a Display P3 red, a CMYK ink, a pattern -- or when the same
/// colour is set over and over and the components would otherwise be
/// re-converted each time. For everything else, `Rgba` is cheaper.
pub const Color = struct {
    handle: *raw.struct_CGColor,

    /// A colour in sRGB, which is the safe choice for anything that leaves
    /// this machine.
    pub fn initSrgb(value: Rgba) Error!Color {
        const created = raw.CGColorCreateSRGB(value.r, value.g, value.b, value.a);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn initGenericGray(value: Gray) Error!Color {
        const created = raw.CGColorCreateGenericGray(value.level, value.a);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn initGenericCmyk(value: Cmyk) Error!Color {
        const created = raw.CGColorCreateGenericCMYK(value.c, value.m, value.y, value.k, value.a);
        return .{ .handle = try errors.checkPtr(created) };
    }

    /// A colour in an arbitrary space. `components` must hold one value per
    /// component of `space` plus one for alpha -- four for RGB, five for
    /// CMYK -- which is checked here rather than left to crash inside
    /// CoreGraphics.
    pub fn init(in: ColorSpace, values: []const Float) Error!Color {
        if (values.len != in.componentCount() + 1) return Error.IllegalArgument;
        const created = raw.CGColorCreate(in.handle, values.ptr);
        return .{ .handle = try errors.checkPtr(created) };
    }

    pub fn deinit(self: Color) void {
        raw.CGColorRelease(self.handle);
    }

    pub fn retain(self: Color) Color {
        return .{ .handle = raw.CGColorRetain(self.handle).? };
    }

    pub fn fromRaw(value: raw.CGColorRef) ?Color {
        return .{ .handle = value orelse return null };
    }

    pub inline fn toRaw(self: Color) raw.CGColorRef {
        return self.handle;
    }

    pub fn eql(self: Color, other: Color) bool {
        return raw.CGColorEqualToColor(self.handle, other.handle);
    }

    pub fn alpha(self: Color) Float {
        return raw.CGColorGetAlpha(self.handle);
    }

    /// The colour space, borrowed from the colour -- do not `deinit` it.
    pub fn space(self: Color) ?ColorSpace {
        return ColorSpace.fromRaw(raw.CGColorGetColorSpace(self.handle));
    }

    /// The components, borrowed. The last one is alpha, so this is one
    /// longer than the colour space's component count.
    pub fn components(self: Color) []const Float {
        const count = raw.CGColorGetNumberOfComponents(self.handle);
        const base = raw.CGColorGetComponents(self.handle);
        if (base == null or count == 0) return &.{};
        return base[0..count];
    }

    /// The same colour at a different alpha, as a new colour.
    pub fn withAlpha(self: Color, value: Float) Error!Color {
        const created = raw.CGColorCreateCopyWithAlpha(self.handle, value);
        return .{ .handle = try errors.checkPtr(created) };
    }
};

test "hex matches the byte levels it is written with" {
    const green = Rgba.hex(0x2ECC71);
    try std.testing.expectApproxEqAbs(@as(Float, 0x2E) / 255, green.r, 1e-12);
    try std.testing.expectApproxEqAbs(@as(Float, 0xCC) / 255, green.g, 1e-12);
    try std.testing.expectApproxEqAbs(@as(Float, 0x71) / 255, green.b, 1e-12);
    try std.testing.expectEqual(@as(Float, 1), green.a);
}

test "a colour space reports its model and component count" {
    const rgb_space = try ColorSpace.deviceRgb();
    defer rgb_space.deinit();
    try std.testing.expectEqual(Model.rgb, rgb_space.model());
    try std.testing.expectEqual(@as(usize, 3), rgb_space.componentCount());

    const cmyk = try ColorSpace.deviceCmyk();
    defer cmyk.deinit();
    try std.testing.expectEqual(Model.cmyk, cmyk.model());
    try std.testing.expectEqual(@as(usize, 4), cmyk.componentCount());
}

test "a space's name identifies it" {
    const srgb = try ColorSpace.named(.srgb);
    defer srgb.deinit();

    const identifier = try srgb.name().?.toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(identifier);
    try std.testing.expectEqualStrings("kCGColorSpaceSRGB", identifier);

    // The device spaces name themselves too, which is worth knowing
    // before using a null name to tell them apart -- use `model` for that.
    const device = try ColorSpace.deviceRgb();
    defer device.deinit();
    const device_identifier = try device.name().?.toOwnedSlice(std.testing.allocator);
    defer std.testing.allocator.free(device_identifier);
    try std.testing.expectEqualStrings("kCGColorSpaceDeviceRGB", device_identifier);
}

test "Color.init checks the component count instead of trusting it" {
    const space = try ColorSpace.deviceRgb();
    defer space.deinit();

    // Three components is the count without alpha, and it is the mistake
    // this check exists for.
    try std.testing.expectError(Error.IllegalArgument, Color.init(space, &.{ 1, 0, 0 }));

    const red = try Color.init(space, &.{ 1, 0, 0, 1 });
    defer red.deinit();
    try std.testing.expectEqual(@as(usize, 4), red.components().len);
    try std.testing.expectEqual(@as(Float, 1), red.alpha());
}

test "a colour keeps its space and can change alpha" {
    const red = try Color.initSrgb(.rgb(1, 0, 0));
    defer red.deinit();

    const faded = try red.withAlpha(0.25);
    defer faded.deinit();

    try std.testing.expectEqual(@as(Float, 0.25), faded.alpha());
    try std.testing.expect(!red.eql(faded));
    try std.testing.expectEqual(Model.rgb, faded.space().?.model());
}
