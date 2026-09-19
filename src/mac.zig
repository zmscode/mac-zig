//! Zig bindings for the macOS system frameworks.
//!
//! One package, one translated C layer, one `Error` set, and a namespace
//! per framework:
//!
//! ```zig
//! const mac = @import("mac");
//!
//! const ctx = try mac.cg.Context.initBitmap(.{ .width = 400, .height = 300 });
//! defer ctx.deinit();
//! ```
//!
//! A program that only wants one framework can pull the namespace out and
//! forget the umbrella is there:
//!
//! ```zig
//! const cg = @import("mac").cg;
//! ```
//!
//! ## Why one package
//!
//! These frameworks share CoreFoundation's types. A `CFStringRef` produced
//! by CoreGraphics has to be the *same Zig type* as one consumed by IOKit,
//! or the two cannot be passed between. Separate packages, each running
//! `translate-c` over its own headers, would each emit their own
//! incompatible `CFStringRef`. So there is one translation unit here,
//! covering every framework that is switched on, and one `cf` namespace
//! that all of them share.
//!
//! ## What is here
//!
//! - `cg` -- CoreGraphics: 2D drawing, images, PDF, displays, the window
//!   list and synthetic input. Optionally ImageIO and a CoreText bridge.
//! - `iokit` -- power sources: battery charge and time remaining.
//! - `cf` -- just enough CoreFoundation to work the rest.
//!
//! Everything is C. Frameworks written in Objective-C -- AVFoundation,
//! Metal, AppKit -- need a message-sending bridge that this package does
//! not have, and are out of scope until it does.

const build_options = @import("mac_build_options");

/// The complete, mechanically translated C API of every framework that is
/// switched on, for the corners the wrappers do not cover.
pub const raw = @import("mac_raw");

/// The `Error` set, shared by every framework in the package.
pub const errors = @import("errors.zig");

/// Just enough CoreFoundation to work the frameworks above it: strings,
/// data, numbers, arrays, dictionaries and URLs.
pub const cf = @import("cf.zig");

/// CoreGraphics: contexts, paths, colours, images, gradients, PDF,
/// displays, the window list and synthetic input.
pub const cg = @import("cg/cg.zig");

/// IOKit's power sources: battery charge, mains or battery, time
/// remaining. Under `-Diokit` (on by default); without it this namespace
/// holds only `enabled = false`.
pub const iokit = if (build_options.iokit) @import("iokit/iokit.zig") else struct {
    pub const enabled = false;
};

pub const Error = errors.Error;

/// Which optional pieces this build has. Check these rather than assuming,
/// since a dependent can switch them off.
pub const features: Features = .{
    .imageio = build_options.imageio,
    .coretext = build_options.coretext,
    .iokit = build_options.iokit,
};

pub const Features = struct {
    /// `mac.cg.imageio`: reading and writing image files.
    imageio: bool,
    /// `mac.cg.text`: drawing a string.
    coretext: bool,
    /// `mac.iokit`: power sources.
    iokit: bool,
};

test {
    // Listed rather than `refAllDecls`, which would also walk `raw` and
    // force the Mach message headers' size assertions -- those cover
    // bitfield structs that translate-c can only render as `opaque`.
    _ = errors;
    _ = cf;
    _ = cg;
    _ = iokit;
}
