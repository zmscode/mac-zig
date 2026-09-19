# mac-zig

Zig 0.17 bindings for the macOS system frameworks. One package, one translated C layer, one
`Error` set, and a namespace per framework.

Today that is:

| Namespace | Framework | Covers |
| --------- | --------- | ------ |
| `mac.cg`  | CoreGraphics | contexts, paths, colours and colour spaces, images, gradients, layers, PDF in and out, displays, the window list, synthetic input |
| `mac.cg.imageio` | ImageIO | reading and writing image files, under `-Dimageio` |
| `mac.cg.text` | CoreText | drawing and measuring a line of text, under `-Dcoretext` |
| `mac.iokit` | IOKit | power sources: battery charge, mains or battery, time remaining, under `-Diokit` |
| `mac.cf`  | CoreFoundation | just enough to work the frameworks above it |

Everything links what macOS already ships, so there is nothing to fetch and nothing to build.

AI coding agents can use the repository's installable [`mac-zig` skill](SKILL.md) for concise,
version-specific integration guidance.

macOS only, and the Xcode command line tools must be installed — the headers live in the SDK.

## Why one package

These frameworks share CoreFoundation's types. A `CFStringRef` that CoreGraphics produces has
to be the *same Zig type* as one IOKit consumes, or the two cannot be passed between. Separate
packages, each running `translate-c` over its own headers, would each emit their own
incompatible `CFStringRef`.

So there is one translation unit covering every framework that is switched on, one `mac.cf`
namespace they all share, and one `mac.Error`. Adding a framework is a build option and a
namespace, not another dependency.

## What is not here

Frameworks written in Objective-C — AVFoundation, Metal, AppKit, Foundation, CoreImage — need
a message-sending bridge (`objc_msgSend`, selector lookup, retain/release by hand) that this
package does not have. They are out of scope until it does. Of AVFoundation's 160 headers, 106
declare Objective-C classes; of CoreGraphics' 50, none do. That line is the whole difference.

## Use as a dependency

```sh
zig fetch --save=mac git+https://github.com/zmscode/mac-zig.git
```

For local development the equivalent path dependency is:

```zig
.dependencies = .{
    .mac = .{ .path = "../mac-zig" },
},
```

Then expose the module to your executable in `build.zig`:

```zig
const mac_dependency = b.dependency("mac", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("mac", mac_dependency.module("mac"));
```

Nothing else is needed — the frameworks are linked for you.

## A drawing

```zig
const mac = @import("mac");

const ctx = try mac.cg.Context.initBitmap(.{ .width = 400, .height = 300 });
defer ctx.deinit();

ctx.setFillColor(.hex(0x1E2430));
ctx.fillRect(ctx.bitmapBounds());

ctx.setFillColor(.hex(0x2ECC71));
ctx.fillEllipseInRect(.init(150, 100, 100, 100));

try mac.cg.imageio.writeContext(ctx, "out.png", .png, .{});
```

A program that wants one framework can pull the namespace out and forget the umbrella is
there, which is how the rest of this file is written:

```zig
const cg = @import("mac").cg;
```

`Context`, `Image`, `Path` and the rest are one-pointer handles passed by value. Most of
them need no allocator, because CoreFoundation owns its own memory — the allocator-taking
calls in this package are the ones that copy data *out* of CoreFoundation and into memory
you own, and they say so.

## What the wrapper changes

| CoreGraphics                                      | mac-zig                                                    |
| ------------------------------------------------- | --------------------------------------------------------- |
| `CGBitmapContextCreate` / `CGContextRelease`      | `Context.initBitmap` / `deinit`, with `defer`              |
| `NULL` returns with no error code                 | an `Error` set; `?T` where null is a real answer           |
| `CGError` codes from the display calls            | the same `Error` set, with the codes named                 |
| `CGBitmapInfo` as or-ed constants from three enums | a `packed struct` with four named fields                   |
| `kCGBlendMode*`, `kCGLineCap*`, `kCGPathFill`     | `BlendMode`, `LineCap`, `DrawingMode` enums                |
| `CGPathApply` with an untyped points array        | `path.Element`, a `union(enum)`                            |
| `CGPathRef` and `CGMutablePathRef` by `const`     | `Path` and `MutablePath`, two types                        |
| `ptr, count` argument pairs                       | slices                                                     |
| `CFStringRef` everywhere                          | `[]const u8` in, `toOwnedSlice(allocator)` out             |
| `CFDictionary` of `CFNumber` for the window list  | `window.Window`, a plain struct                            |
| `CGRectDivide` with two out-parameters            | `Rect.divide` returning a `Division`                       |

Anything not yet wrapped is reachable through `mac.raw`, the complete translated API.

## Two things to get right

**The y axis points up.** A context's origin is at the bottom left. Shapes, images and text
drawn into a fresh context all come out correct, including once written to a PNG — the
coordinates simply count from the bottom. `Context.flipVertically` switches to top-left,
y-down coordinates when that suits the numbers better, and the cost is that it flips
everything: use `drawImageUpright` for images and `setTextMatrix(.scaling(1, -1))` for text.

**Create means you own it.** A CoreFoundation call with `Create` or `Copy` in its name hands
over a reference that is yours to release; one with `Get` lends you a reference that you must
not. The wrapper keeps that visible: anything with a `deinit` is yours, and anything returned
without one is borrowed from something that is.

## The bitmap info word

`CGBitmapInfo` is one `uint32_t` holding four unrelated fields, built by or-ing constants
from three different enums:

```c
kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little
```

Get it wrong and `CGBitmapContextCreate` returns `NULL` with no explanation, or succeeds and
gives you an image with red and blue swapped. Here the fields are named and the working
combinations have names:

```zig
const info: cg.BitmapInfo = .bgra8888;   // the layout a Mac composites fastest
const other: cg.BitmapInfo = .rgba8888;  // R, G, B, A in memory order

// And a layout a bitmap context cannot accept is an error here rather
// than a silent null from CoreGraphics:
_ = cg.Context.initBitmap(.{
    .width = 4,
    .height = 4,
    .bitmap_info = .{ .alpha = .last },  // error.IllegalArgument
});
```

## Paths

`Path` is immutable and `MutablePath` is being built, so the two cannot be confused:

```zig
const star = try cg.MutablePath.init();
defer star.deinit();

star.moveTo(.init(0, 0));
star.lineTo(.init(10, 0));
star.curveTo(.init(10, 5), .init(5, 10), .init(0, 10));
star.closeSubpath();

ctx.addPath(star.asPath());
ctx.fillPath();
```

Walking one is a tagged union rather than an array whose length you infer from a tag:

```zig
const elements = try star.asPath().toOwnedElements(allocator);
defer allocator.free(elements);

for (elements) |element| switch (element) {
    .move_to => |p| moveTo(p),
    .line_to => |p| lineTo(p),
    .quad_curve_to => |c| quadTo(c.control, c.end),
    .curve_to => |c| cubicTo(c.control1, c.control2, c.end),
    .close_subpath => close(),
};
```

Boolean operations, stroking to an outline, dashing and flattening all produce new paths:

```zig
const carved = try square.subtracting(circle, false);
defer carved.deinit();

const outline = try line.stroked(.{ .line_width = 4, .cap = .round });
defer outline.deinit();
```

## Graphics state

`save` and `restore` pair exactly with `defer`, which is what makes clipping and transforms
safe to nest:

```zig
ctx.save();
defer ctx.restore();

ctx.addEllipseInRect(.init(0, 0, 120, 120));
ctx.clip();                      // clipping only ever shrinks
ctx.drawLinearGradient(ramp, .init(0, 120), .init(120, 0), .both);
```

The current path is the one thing *not* in the graphics state, which is why every call that
draws it also clears it. Build a `Path` once and `addPath` it to draw the same shape twice.

## PDF

Out:

```zig
const ctx = try cg.Context.initPdfFile(allocator, "out.pdf", .{
    .media_box = .init(0, 0, 612, 792),
    .title = "report",
});
defer ctx.deinit();
defer ctx.closePdf();            // without this the file has no trailer

ctx.beginPdfPage();
ctx.setFillColor(.white);
ctx.fillRect(.init(0, 0, 612, 792));
ctx.endPdfPage();
```

And back in, which is how a page gets rasterised:

```zig
const document = try cg.pdf.Document.initFile("out.pdf");
defer document.deinit();

const page = document.page(1).?;     // pages count from 1
const box = page.box(.media);

ctx.concat(page.drawingTransform(.media, box, 0, true));
ctx.drawPdfPage(page);
```

## Power

```zig
const state = try mac.iokit.power.snapshot(allocator);
defer state.deinit(allocator);

if (state.battery()) |b| {
    std.debug.print("{d}%{s}\n", .{ b.percent, if (b.is_charging) " charging" else "" });
}
if (mac.iokit.power.timeRemaining()) |minutes| { ... }
```

In C this is an opaque blob, then a `CFArray` of opaque handles, then a `CFDictionary` per
handle whose keys are plain C strings and whose values are boxed `CFNumber`s. Here it is one
call returning plain structs. A desktop with no battery gives an empty source list rather than
an error, and nothing here needs a permission.

## Displays and windows

Finding the display something is on, which is what "go fullscreen where the cursor is" needs:

```zig
const now = try cg.event.Event.initCurrentState(null);
defer now.deinit();
const under_cursor = cg.Display.containing(now.location()) orelse .main();

// Or, for a window: the display it mostly sits on. SDL reports window
// positions in this same global space on macOS, so its rectangle goes
// straight in.
const window_screen = cg.Display.bestFor(window_rect) orelse .main();
```

```zig
var buffer: [64]cg.Display = undefined;
for (try cg.Display.active(&buffer)) |screen| {
    const mode = try screen.currentMode();
    defer mode.deinit();
    std.debug.print("{f} at {d}Hz\n", .{ mode.size(), mode.refreshRate() });
}
```

The window list arrives as plain structs rather than a `CFArray` of `CFDictionary`:

```zig
const windows = try cg.window.list(allocator, .visible, 0);
defer windows.deinit(allocator);

for (windows.windows) |w| {
    std.debug.print("{s} {f}\n", .{ w.owner_name orelse "?", w.bounds });
}
```

Window *titles* need Screen Recording permission; everything else does not, and a `null`
title means the permission is missing rather than that the window is untitled.
`cg.window.hasScreenCaptureAccess()` answers that directly, and `requestScreenCaptureAccess()`
prompts — once only, since a process that has been refused is never re-prompted.

## Text

Under `-Dcoretext` (on by default). CoreGraphics cannot lay text out — the calls that took a
string were deprecated in macOS 10.9 — so this is a thin CoreText bridge covering one line in
one font, which is enough to label, caption and measure:

```zig
const font = try cg.text.Font.initSystem(24);
defer font.deinit();

const metrics = try cg.text.measure("mac-zig", font);   // for alignment
ctx.setFillColor(.white);
try cg.text.draw(ctx, "mac-zig", font, .init(40, 40), null);
```

## Traps

- **`clipToPath` replaces the current path.** CoreGraphics has no call that clips to a path
  directly, so it goes through the current one. Take a `copyPath` first if you still need it.
- **A PDF context is not finished when it is released.** Call `closePdf` or the file is
  truncated.
- **`Event.post` is a silent no-op without Accessibility permission.** No error, no code.
  If synthetic input appears to do nothing, that is almost always why.
- **A display's current mode is usually absent from `modes(.{})`.** On a Retina display the
  current mode is a scaled one, and CoreGraphics leaves those out unless you pass
  `.{ .include_scaled = true }`.
- **`intersection` returns a *null* rectangle, not an empty one, when two rectangles miss.**
  Check it with `isNull`, not `isEmpty`.
- **`Image.cropped` measures from the top left**, unlike everything else in the framework.
- **`Display.pixelSize()` is not `CGDisplayPixelsWide`.** That call predates Retina and answers
  in *points* — on a 6016x3384 panel it says 3008x1692, and a capture buffer sized from it holds
  a quarter of the pixels. `pixelSize()` reads the current mode instead; `legacyPixelSize()` is
  the old number if you need to match it.
- **ImageIO's default JPEG quality is not maximum.** A 6016x3384 screenshot came out at 2.0 MB
  with `.{}` and 5.3 MB with `.{ .quality = 1.0 }`. PNG is lossless regardless.
- **The screen-capture calls are obsoleted as of macOS 15**, not merely deprecated —
  `obsoleted=15.0`, which in C is a hard compile error. Zig ignores availability attributes, so
  they compile and link, and they still worked on macOS 26.6. There will be no warning on the
  day they stop, only a null return.
- **IOKit reports a time-to-empty of 0 while on mains**, which is not an estimate that the
  machine is about to die. `Source.time_to_empty` is null unless the source is actually
  discharging, and `time_to_full` unless it is actually charging.

## Examples

```sh
zig build run-info        # displays, modes and the windows on screen
zig build run-power       # battery, mains, time remaining
zig build run-shapes      # paths, dashes, clipping, shadows, boolean ops
zig build run-gradient    # gradients, transforms and layers
zig build run-text        # measuring, aligning, the flipped-context fix
zig build run-pdf         # a PDF written, read back and rasterised
```

## Build options

| Option              | Default | Effect                                                    |
| ------------------- | ------- | --------------------------------------------------------- |
| `-Dimageio=false`   | on      | Drops `mac.cg.imageio`; no reading or writing of image files |
| `-Dcoretext=false`  | on      | Drops `mac.cg.text`; no string drawing                     |
| `-Diokit=false`     | on      | Drops `mac.iokit`; no power-source reading                 |

Both namespaces still exist when switched off, holding only `enabled = false`, so a
dependent can check `mac.features.imageio` rather than failing to compile.

## Steps

| Step                | Effect                                                |
| ------------------- | ----------------------------------------------------- |
| `zig build`         | Builds every example into `zig-out/bin`               |
| `zig build test`    | Runs the inline tests and the integration tests       |
| `zig build bindings`| Writes the translated C bindings to `zig-out/bindings`|

## Layout

| Path                      | What is in it                                             |
| ------------------------- | --------------------------------------------------------- |
| `src/mac.zig`             | Umbrella root: the framework namespaces and feature flags |
| `src/errors.zig`          | The `Error` set, shared by every framework                |
| `src/cf.zig`              | Just enough CoreFoundation to work the rest               |
| `src/cg/cg.zig`           | CoreGraphics namespace root and re-exports                |
| `src/cg/geometry.zig`     | `Point`, `Size`, `Rect`, `AffineTransform`                |
| `src/cg/color.zig`        | `ColorSpace`, `Color`, `Rgba`                             |
| `src/cg/image.zig`        | `Image`, `BitmapInfo`, `DataProvider`                     |
| `src/cg/path.zig`         | `Path`, `MutablePath`, `Element`                          |
| `src/cg/context.zig`      | `Context`, `Gradient`, `Layer` — the drawing surface      |
| `src/cg/pdf.zig`          | Reading PDFs                                              |
| `src/cg/display.zig`      | Displays and display modes                                |
| `src/cg/window.zig`       | The window list                                           |
| `src/cg/event.zig`        | Synthetic input and event taps                            |
| `src/cg/imageio.zig`      | Image files, under `-Dimageio`                            |
| `src/cg/text.zig`         | The CoreText bridge, under `-Dcoretext`                   |
| `src/iokit/iokit.zig`     | IOKit namespace root                                      |
| `src/iokit/power.zig`     | Power sources, under `-Diokit`                            |
| `vendor/mac_translate.h`  | The umbrella header, and the header workarounds           |

## Where the frameworks come from

They are already on the machine. The package links `CoreGraphics`, `CoreFoundation`, and
optionally `ImageIO`, `CoreText` and `IOKit`, from the macOS SDK that `xcode-select` points at.

The one piece worth knowing about is `vendor/mac_translate.h`. Three of Apple's spellings do
not survive Zig 0.17's C translator, and all three are handled there rather than in
`build.zig`, so the workaround sits next to the thing it works around:

1. **Nullability on bounded array parameters** — `const CGFloat wp[_Nonnull 3]` in
   `CGColorSpace.h`. The translator reports the feature as supported and then rejects the
   syntax, so the spellings are blanked.
2. **Blocks** — the translator has no blocks support, and Zig cannot call a block anyway. The
   few headers carrying block declarations claim their own include guards and re-declare
   everything except the block APIs, each omission documented with the non-block equivalent.
   CoreText is block-infested throughout, which is why `src/text.zig` declares its thirteen
   functions by hand instead.
3. **Struct-size assertions on bitfield structs** — CoreFoundation reaches `mach/message.h`,
   whose descriptors carry bitfields that translate-c can only render as `opaque`, leaving a
   top-level `comptime` block asking for `@sizeOf` of an opaque type. The assertion macros are
   blanked at the source.
