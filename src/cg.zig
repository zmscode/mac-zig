//! Zig bindings for [CoreGraphics](https://developer.apple.com/documentation/coregraphics),
//! Apple's 2D drawing engine.
//!
//! CoreGraphics is C, so the raw layer is `translate-c` over the framework
//! headers with no shim in between. Everything else is the layer you are
//! meant to use:
//!
//! - handles with `init` / `deinit` instead of Create/Release pairs, and
//!   one rule for who owns what;
//! - one `Error` set, covering both of CoreGraphics' failure channels;
//! - `enum` for blend modes, line caps and colour models instead of loose
//!   integers;
//! - `packed struct` for `CGBitmapInfo`, whose four fields are or-ed into
//!   one `uint32_t` in C and are the single most common source of a
//!   silently wrong image;
//! - a `union(enum)` `path.Element`, where `CGPathApply` hands over a
//!   points array whose length you are trusted to infer.
//!
//! Reach for `raw` where the wrapper does not yet cover something.
//!
//! ```zig
//! const cg = @import("cg");
//!
//! const ctx = try cg.Context.initBitmap(.{ .width = 400, .height = 300 });
//! defer ctx.deinit();
//!
//! ctx.setFillColor(.hex(0x1E2430));
//! ctx.fillRect(ctx.bitmapBounds());
//!
//! ctx.setFillColor(.hex(0x2ECC71));
//! ctx.fillEllipseInRect(.init(150, 100, 100, 100));
//!
//! try cg.imageio.writeContext(ctx, "out.png", .png, .{});
//! ```
//!
//! ## Two things to get right
//!
//! **The y axis points up.** A context's origin is at the bottom left.
//! Images, text and every file format assume the opposite, so a fresh
//! bitmap draws them upside down. `Context.flipVertically` is the fix; see
//! the note at the top of `context.zig`.
//!
//! **Create means you own it.** A CoreFoundation call with Create or Copy
//! in its name hands over a reference that is yours to release; a call with
//! Get in its name lends you one that you must not. This binding keeps that
//! visible: anything with a `deinit` is yours, and anything returned
//! without one is borrowed from something that is.

const build_options = @import("cg_build_options");

/// The complete, mechanically translated CoreGraphics and CoreFoundation
/// API, for the corners this wrapper does not cover.
pub const raw = @import("cg_raw");

pub const errors = @import("errors.zig");
pub const cf = @import("cf.zig");
pub const geometry = @import("geometry.zig");
pub const color = @import("color.zig");
pub const image = @import("image.zig");
pub const path = @import("path.zig");
pub const context = @import("context.zig");
pub const pdf = @import("pdf.zig");
pub const display = @import("display.zig");
pub const window = @import("window.zig");
pub const event = @import("event.zig");

/// Reading and writing image files, compiled in with `-Dimageio` (on by
/// default). Without it this namespace holds only `enabled = false`.
pub const imageio = if (build_options.imageio) @import("imageio.zig") else struct {
    pub const enabled = false;
};

/// Drawing a string, compiled in with `-Dcoretext` (on by default).
/// Without it this namespace holds only `enabled = false`.
pub const text = if (build_options.coretext) @import("text.zig") else struct {
    pub const enabled = false;
};

pub const features: Features = .{
    .imageio = build_options.imageio,
    .coretext = build_options.coretext,
};

pub const Features = struct {
    imageio: bool,
    coretext: bool,
};

// The types you reach for most, re-exported so a program can say
// `cg.Context` rather than `cg.context.Context`.

pub const Error = errors.Error;

pub const Float = geometry.Float;
pub const Point = geometry.Point;
pub const Size = geometry.Size;
pub const Vector = geometry.Vector;
pub const Rect = geometry.Rect;
pub const AffineTransform = geometry.AffineTransform;

pub const ColorSpace = color.ColorSpace;
pub const Color = color.Color;
pub const Rgba = color.Rgba;
pub const Gray = color.Gray;
pub const Cmyk = color.Cmyk;
pub const RenderingIntent = color.RenderingIntent;

pub const Image = image.Image;
pub const BitmapInfo = image.BitmapInfo;
pub const AlphaInfo = image.AlphaInfo;
pub const DataProvider = image.DataProvider;
pub const InterpolationQuality = image.InterpolationQuality;

pub const Path = path.Path;
pub const MutablePath = path.MutablePath;
pub const LineCap = path.LineCap;
pub const LineJoin = path.LineJoin;
pub const DrawingMode = path.DrawingMode;

pub const Context = context.Context;
pub const Gradient = context.Gradient;
pub const Layer = context.Layer;
pub const BlendMode = context.BlendMode;
pub const Shadow = context.Shadow;

pub const Display = display.Display;

test {
    // Listed rather than `refAllDecls`, which would also walk `raw` and
    // force the Mach message headers' size assertions -- those cover
    // bitfield structs that translate-c can only render as `opaque`.
    _ = errors;
    _ = cf;
    _ = geometry;
    _ = color;
    _ = image;
    _ = path;
    _ = context;
    _ = pdf;
    _ = display;
    _ = window;
    _ = event;
    _ = imageio;
    _ = text;
}
