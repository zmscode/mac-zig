---
name: mac-zig
description: Integrate, configure, test, and debug the mac-zig Zig 0.17 bindings for the macOS system frameworks. Use when an agent needs 2D drawing, bitmap or PDF output, image loading and saving, paths, gradients, colour spaces, or text drawing on macOS from Zig; needs display or window enumeration; needs mouse position, modifier state or synthetic input; or must reach parts of a macOS C framework the wrappers do not yet cover.
---

# macOS frameworks in Zig

One package, a namespace per framework:

| Namespace | Framework |
| --------- | --------- |
| `mac.cg` | CoreGraphics |
| `mac.cg.imageio` | ImageIO, under `-Dimageio` |
| `mac.cg.text` | CoreText, under `-Dcoretext` |
| `mac.iokit` | IOKit power sources, under `-Diokit` |
| `mac.cf` | CoreFoundation |

Use the idiomatic namespaces by default. Reach for `mac.raw` only when a wrapper does not
cover a call.

Objective-C frameworks (AVFoundation, Metal, AppKit, Foundation) are **not** here and cannot
be added without a message-sending bridge. Do not reach for them.

macOS only. The Xcode command line tools must be present, because the headers come from the
SDK that `xcode-select` points at.

## Add the dependency

```sh
zig fetch --save=mac git+https://github.com/zmscode/mac-zig.git
```

```zig
const dependency = b.dependency("mac", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("mac", dependency.module("mac"));
```

The frameworks ship with macOS and are linked for you. Nothing is fetched or compiled.

## The shape of a program

```zig
const mac = @import("mac");
const cg = mac.cg;            // the rest of this file assumes this

const ctx = try cg.Context.initBitmap(.{ .width = 400, .height = 300 });
defer ctx.deinit();

ctx.setFillColor(.hex(0x1E2430));
ctx.fillRect(ctx.bitmapBounds());

ctx.setFillColor(.hex(0x2ECC71));
ctx.fillEllipseInRect(.init(150, 100, 100, 100));

try cg.imageio.writeContext(ctx, "out.png", .png, .{});
```

## Eight things to get right

1. **The y axis points up.** A context's origin is at the bottom left. Left alone this costs
   nothing — shapes, images and text all come out correct. `flipVertically(height)` switches
   to top-left, y-down coordinates, and then images need `drawImageUpright` and text needs
   `setTextMatrix(.scaling(1, -1))`.
2. **Create means you own it.** Anything with a `deinit` is yours to release; anything
   returned without one is borrowed from something that is. `Get`-named CoreFoundation calls
   lend, `Create`/`Copy` hand over.
3. **Drawing consumes the current path.** `fillPath`, `strokePath` and `drawPath` leave it
   empty. To draw a shape twice, build a `Path` and `addPath` before each draw.
4. **Clipping only shrinks.** There is no call to widen it again. Wrap it in
   `save()` / `defer restore()`.
5. **`?T` is an answer, an error is a failure.** Null that means *absent* comes back as an
   optional; null that means *failed* becomes `error.Failed`. The `CGError` codes are named
   separately in the same set -- `error.CgFailure` is `kCGErrorFailure`, not the null case.
6. **A PDF context needs `closePdf`.** Releasing it without that leaves a truncated file.
7. **`bitmapData()` rows are padded.** The slice is `bytesPerRow * height`, and
   `bytesPerRow` is not always `width * 4`. Index with `bitmapBytesPerRow()`.
8. **Permissions fail quietly.** `Event.post` does nothing without Accessibility; window
   titles are `null` and captures come back null or blank without Screen Recording. Neither
   reports an error — call `cg.window.hasScreenCaptureAccess()` or
   `cg.event.hasListenAccess()` instead of inferring it from a failure.
9. **Size capture buffers from `Display.pixelSize()`, never `bounds()`.** On a Retina display
   `bounds()` is points and a buffer sized from it holds a quarter of the pixels.

## Colours

Two spellings, for two costs:

```zig
ctx.setFillColor(.hex(0x2ECC71));       // four numbers, nothing allocated
ctx.setFillColor(.rgba(1, 0, 0, 0.5));
ctx.setFillGray(.{ .level = 0.5 });

// A CGColorRef, for a colour space device RGB cannot express:
const space = try cg.ColorSpace.named(.display_p3);
defer space.deinit();
const wide = try cg.Color.init(space, &.{ 1, 0, 0, 1 });  // one per component + alpha
defer wide.deinit();
ctx.setFillColorRef(wide);
```

Note `Rgba` components are 0..1, not 0..255. `.hex` takes the 0..255 form and converts.

Chained calls need the explicit type — inference does not flow through a method call:

```zig
ctx.setFillColor(cg.Rgba.hex(0xECF0F1).withAlpha(0.85));   // not .hex(...).withAlpha(...)
```

## Bitmap contexts

```zig
const ctx = try cg.Context.initBitmap(.{
    .width = 512,
    .height = 512,
    .bitmap_info = .bgra8888,   // the default: fastest on a Mac
    // .bitmap_info = .rgba8888, // R, G, B, A in memory order
    // .space = my_space,        // defaults to a temporary sRGB
    // .pixels = my_buffer,      // defaults to CoreGraphics allocating
});
defer ctx.deinit();
```

`initBitmap` rejects a zero dimension and a layout a bitmap context cannot accept, where
CoreGraphics would return `NULL` and say nothing. The non-premultiplied alpha layouts
(`.last`, `.first`) are valid for images but not for contexts.

Reading pixels back:

```zig
const data = ctx.bitmapData().?;
const offset = y * ctx.bitmapBytesPerRow() + x * 4;
const pixel = data[offset..][0..4].*;   // B, G, R, A for .bgra8888
```

## Paths

```zig
const path = try cg.MutablePath.init();
defer path.deinit();

path.moveTo(.init(0, 0));
path.lineTo(.init(10, 0));
path.curveTo(.init(10, 5), .init(5, 10), .init(0, 10));
path.closeSubpath();

ctx.addPath(path.asPath());
ctx.fillPath();
```

`asPath()` is a borrowed view of the same object — do not `deinit` it, and do not keep it
past the next change. `toOwnedPath()` makes an independent snapshot.

Building calls take no transform; `Path.transformed(t)` makes a transformed copy. The
exception is `addPathTransformed`, where placing a sub-path is the point.

Derived paths, each owned by the caller:

```zig
_ = try path.asPath().stroked(.{ .line_width = 4, .cap = .round });
_ = try path.asPath().dashed(0, &.{ 9, 5 });
_ = try a.subtracting(b, false);     // also unionWith, intersection, symmetricDifference
_ = try path.asPath().flattened(0.1);
```

## Text

Under `-Dcoretext`. Check `mac.features.coretext` if the package might be built without it.

```zig
const font = try cg.text.Font.initSystem(24);      // or .initMonospaced, or .init("Helvetica", 24)
defer font.deinit();

const metrics = try cg.text.measure("hello", font);
try cg.text.draw(ctx, "hello", font, .init(40, 40), null);
```

`origin` is on the **baseline**, not the top — add `metrics.ascent` to place the top.
`color` null takes the context's fill colour; pass a `cg.Color` to bind it to the line.

`Font.init` substitutes silently when the name is unknown; check `fullName` if that matters.
One `Line` is one line — newlines are not breaks, so split the text first.

In a flipped context, set `ctx.setTextMatrix(.scaling(1, -1))` or glyphs draw mirrored.

## Images

```zig
const img = try cg.imageio.readImage("photo.jpg");   // any format ImageIO knows
defer img.deinit();

ctx.drawImage(.init(0, 0, 200, 150), img);           // scaled to fill
ctx.setInterpolationQuality(.none);                  // for pixel art

try cg.imageio.writeImage(img, "out.jpg", .jpeg, .{ .quality = 0.8 });
try cg.imageio.writeContext(ctx, "out.png", .png, .{});   // snapshot + write
```

CoreGraphics itself decodes only PNG and JPEG, through `Image.initPng` / `Image.initJpeg`;
everything else goes through `cg.imageio`.

`Image.cropped` measures from the **top left**, unlike the rest of the framework.

## PDF

```zig
const ctx = try cg.Context.initPdfFile(allocator, "out.pdf", .{
    .media_box = .init(0, 0, 612, 792),   // US Letter in points
    .title = "report",
});
defer ctx.deinit();
defer ctx.closePdf();

ctx.beginPdfPage();
// ... draw ...
ctx.endPdfPage();
```

Reading, where pages count from **1**:

```zig
const document = try cg.pdf.Document.initFile("in.pdf");
defer document.deinit();

var it = document.pages();
while (it.next()) |page| {
    ctx.concat(page.drawingTransform(.media, page.box(.media), 0, true));
    ctx.drawPdfPage(page);
}
```

Pages draw onto transparency — fill the background first if a white page is wanted.

## Displays and windows

```zig
var buffer: [64]cg.Display = undefined;
const displays = try cg.Display.active(&buffer);    // no allocation

const mode = try displays[0].currentMode();
defer mode.deinit();
```

`modes(.{})` usually **omits the current mode** on a Retina display. Pass
`.{ .include_scaled = true }` to see it.

```zig
const windows = try cg.window.list(allocator, .visible, 0);
defer windows.deinit(allocator);
```

## Events

Nothing here works without permission, and only the tap side reports it:

```zig
if (!cg.event.hasListenAccess()) _ = cg.event.requestListenAccess();

const source = try cg.event.Source.init(.private);
defer source.deinit();

const click = try cg.event.Event.initMouse(source, .left_mouse_down, .init(100, 200), .left);
defer click.deinit();
click.post(.hid);       // silently does nothing without Accessibility permission
```

Event locations are in the **global display space** — origin at the main display's top left,
y downwards — not a context's coordinates.

Reading a scroll amount back is asymmetric: `scroll_delta_axis_1` is always in lines, so a
`.pixel` event's amounts come from `scroll_point_delta_axis_1`.

## Power

```zig
const state = try mac.iokit.power.snapshot(allocator);
defer state.deinit(allocator);

state.providing           // .ac, .battery, .off_line
state.onBattery()
state.battery()           // ?Source, null on a desktop

mac.iokit.power.timeRemaining()   // ?u32 minutes, null on mains or while estimating
mac.iokit.power.warningLevel()    // .none, .early, .final
```

No permission needed. A desktop gives an empty `sources` list, not an error.
`Source.time_to_empty` is null unless the source is discharging and `time_to_full` is null
unless it is charging -- IOKit reports 0 for the irrelevant half rather than omitting it.

Prefer `warningLevel()` over a percentage threshold of your own: it is what drives the
system's own low-battery notifications.

## Build options

| Option              | Default | Effect                                              |
| ------------------- | ------- | --------------------------------------------------- |
| `-Dimageio=false`   | on      | Drops `mac.cg.imageio`                              |
| `-Dcoretext=false`  | on      | Drops `mac.cg.text`                                 |
| `-Diokit=false`     | on      | Drops `mac.iokit`                                   |

Both namespaces exist either way, holding `enabled = false` when off. Check
`mac.features.imageio` / `mac.features.coretext` rather than assuming.

## Validate a change

```sh
zig build test                      # inline tests plus integration tests
zig build test -Dimageio=false      # the gated namespaces still compile out
zig build test -Dcoretext=false
zig build                           # every example still builds
zig build bindings                  # inspect the translated C API
```

Drawing tests assert on real pixels — make a small bitmap context, draw, and read
`bitmapData()` indexed by `bitmapBytesPerRow()`. Do not write tests that post events: they
would move the user's real mouse.

## Adding a framework

One translation unit, one `Error` set, one `cf`. To add a C framework:

1. include its umbrella header in `vendor/mac_translate.h` behind a `MAC_ZIG_<NAME>` macro;
2. add the build option, the `defineCMacro`, the `linkFramework` and the `features` field in
   `build.zig` and `src/mac.zig`;
3. put the wrappers in `src/<name>/`, importing `../errors.zig` and `../cf.zig`;
4. add any new failure codes to the shared `Error` set.

Expect header trouble: see the notes at the end of README.md for the three spellings that do
not survive Zig 0.17's C translator. Check a new framework's headers for blocks first --
`grep -l '(\^' <headers>/*.h` -- because those cannot be translated at all.

## Adding a wrapper

Find the call in `zig-out/bindings/mac.zig` after `zig build bindings`, then:

- handles are a struct over one non-optional pointer, with `init`/`deinit`, `toRaw` and
  `fromRaw`;
- null-on-failure goes through `errors.checkPtr` (`error.Failed`), a `CGError` through
  `errors.checkCode`;
- loose integer constants become an `enum` with `_` for the unnamed values, converted with
  `@backingInt` / `@fromBackingInt`;
- an or-ed bit word becomes a `packed struct(uN)` with a test asserting it equals the C
  constants or-ed together;
- `ptr, count` pairs become slices; `const char *` becomes `[]const u8`.

## Zig 0.17 notes

These bit during development and are easy to hit again:

- `@bitCast` no longer accepts `extern struct` destinations. The geometry types convert
  with explicit `toRaw` / `fromRaw` instead.
- The `**` array-repeat operator is gone; use `@splat`.
- `@typeInfo(T).@"struct"` has `field_names` and `field_types`, not `fields`.
- `std.ArrayList` is unmanaged: `.empty`, then `append(allocator, x)` and
  `deinit(allocator)`.
- A `format` method takes `*std.Io.Writer` and returns `std.Io.Writer.Error!void`, and is
  reached with `{f}`.
- Zig rejects a parameter that shadows a declaration, which bites constantly when a getter
  is named `size`, `width`, `name`, `value` or `components`.
