---
name: mac-zig
description: Integrate, configure, test, and debug the mac-zig Zig 0.17 bindings for the macOS system frameworks. Use when an agent needs 2D drawing, bitmap or PDF output, image loading and saving, paths, gradients, colour spaces, or text drawing on macOS from Zig; needs display or window enumeration; needs mouse position, modifier state or synthetic input; needs to call an Objective-C framework (Foundation, AppKit, Metal) from Zig, define an Objective-C class in Zig, or pass a block; or must reach parts of a macOS C framework the wrappers do not yet cover.
---

# macOS frameworks in Zig

One package, a namespace per framework:

| Namespace | Framework |
| --------- | --------- |
| `mac.cg` | CoreGraphics |
| `mac.cg.imageio` | ImageIO, under `-Dimageio` |
| `mac.cg.text` | CoreText, under `-Dcoretext` |
| `mac.iokit` | IOKit power sources, under `-Diokit` |
| `mac.objc` | the Objective-C runtime, under `-Dobjc` |
| `mac.foundation` | Foundation, hand-wrapped, under `-Dobjc` |
| `mac.appkit` | AppKit, generated from the SDK, under `-Dappkit` |
| `mac.metal` | Metal and QuartzCore's Metal layer, generated, under `-Dmetal` |
| `mac.iosurface` | IOSurface, shared pixel buffers, under `-Diosurface` |
| `mac.dispatch` | Grand Central Dispatch |
| `mac.cf` | CoreFoundation |

Use the idiomatic namespaces by default. Reach for `mac.raw` only when a wrapper does not
cover a call.

For Objective-C, prefer, in order: `mac.foundation` and `mac.appkit` wrappers; then adding the
class to the generator manifest (`tools/objc_gen/appkit.zig`) and running `zig build generate`;
then a small hand-written wrapper struct; then raw `msgSend` with a selector string.

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

`Display.containing(point)` and `Display.bestFor(rect)` answer "which screen is this on" —
both in the global display space, which is what `cg.event` locations and SDL window positions
are already in. `Display.fromId(n)` wraps an id from elsewhere.

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

## Objective-C

Under `-Dobjc`, which links libobjc and Foundation. Any other framework must be linked by the
program: `exe.root_module.linkFramework("AppKit", .{})`, or `getClass` answers null.

```zig
const objc = mac.objc;

const pool = objc.AutoreleasePool.init();       // every thread that sends messages needs one
defer pool.deinit();

const info = objc.getClass("NSProcessInfo").?.msgSend(objc.Object, "processInfo", .{});
const cores = info.msgSend(objc.UInteger, "activeProcessorCount", .{});
const rect = boxed.msgSend(cg.Rect, "rectValue", .{});       // NSRect is cg.Rect
const first = array.msgSend(?objc.Object, "firstObject", .{}); // ?Object where nil is possible
```

`msgSend(Return, selector, .{args})`. The selector is a comptime string (checked against the
argument count) or an `objc.Sel` for one built at run time. Rules:

- **Literals need a type**: `@as(objc.Integer, 3)`, `@as(cg.Float, 1.5)`, `@as(?objc.Object, null)`.
  Pick the type the method declares — `NSInteger` is `objc.Integer`, `NSUInteger` is
  `objc.UInteger`, `CGFloat` is `cg.Float`, `int` is `c_int`.
- **Ask for the right return type.** Nothing checks it against the method. `Object` asserts
  non-nil; use `?Object` when nil is possible.
- **C strings** go in as `"text".ptr` (`[*:0]const u8`) and come out as `[*:0]const u8`.
- **Arrays of objects** go in as `@as([*]const objc.Object, &array)` with a count.
- **Uncaught exceptions are fatal.** Where one is possible, use
  `obj.tryMsgSend(R, "sel:", .{args}, &caught)` (or `null` to discard it), which answers
  `error.ObjcException`; `objc.tryCall(f, args, &caught)` wraps a whole function. Unwinding skips
  Zig `defer`s in the frames it passes, so keep cleanup out of a `tryCall`ed function.
- **Ownership** is in the name: alloc/new/copy/mutableCopy → `release` it; anything else is
  autoreleased. `retain` to keep one past the pool.
- `cf` values bridge: `objc.Object.fromCf(cf_string)` is an NSString; `obj.asCf(cf.String)` goes
  back. Same reference, not a copy.

Typed wrappers — any struct whose only field is an `objc.Object` passes and returns as one:

```zig
const Window = struct {
    object: objc.Object,
    fn setTitle(self: Window, title: objc.Object) void {
        self.object.msgSend(void, "setTitle:", .{title});
    }
};
const window = app.msgSend(Window, "mainWindow", .{});
```

Blocks:

```zig
const Visit = objc.Block(struct { total: *i64 }, fn (objc.Object, objc.UInteger, *bool) void);
var block = Visit.init(.{ .total = &total }, struct {
    fn body(captures: *const Visit.Captures, item: objc.Object, _: objc.UInteger, _: *bool) void { ... }
}.body);
array.msgSend(void, "enumerateObjectsUsingBlock:", .{&block});   // pass a pointer
```

The signature is a Zig function type; the body takes `*const Captures` (or `*Captures`) first,
then the signature's parameters. Generated methods take `objc.BlockRef(fn (...) R)`: pass
`block.ref()` — a block of any other signature does not compile. A stack block lives as long as
its variable; APIs that keep a block copy it themselves. A block handed *to* your method is an
`objc.BlockRef(fn (...) R)` parameter; call it with `.call(.{...})`.

Defining a class — use `objc.Subclass`:

```zig
const Thing = objc.Subclass(.{ .name = "MyPrefixThing", .superclass = "NSObject" }, struct {
    last: objc.Integer = 0,                      // every field needs a default
    pub fn @"doThing:"(self: *@This(), arg: objc.Integer) void { self.last = arg; }
    pub fn @"make:"(_: objc.Class, n: objc.Integer) Thing { ... }   // class method
    pub fn deinit(self: *@This()) void { ... }   // runs from -dealloc
});
const thing = Thing.new();                       // yours: thing.release()
thing.state().last;
```

- Registered on first `Thing.class()`/`new()`, once. Defaults applied at alloc; `deinit` at dealloc.
- Receiver (first param): `*State`, `*const State`, `Thing`, or `objc.Object` = instance
  method; `objc.Class` = class method. No `_cmd`. `pub fn`s without a receiver are ignored.
- A method cannot share a field's name (Zig rule): field `total`, getter `count`.
- **Give the superclass and protocols as generated types when they exist** —
  `.superclass = appkit.View`, `.protocols = .{appkit.WindowDelegate, "NSCopying"}` — and every
  override is checked against the SDK's signature at compile time (by ABI shape: `f32` for
  `CGFloat`, `Point` for `Rect`, `bool` for `NSInteger` are errors). Strings are unchecked.
- Methods may not return a Zig error. `[super x]` is
  `self.object.msgSendSuper(<superclass, spelled out>, R, "x", .{})`.
- The raw API (`allocateClassPair`, `addMethod` with `(self, _: objc.Sel, ...)`, `addIvar`,
  `registerClassPair`) is there for cases the struct form does not fit; its ivars are
  zero-filled, with no defaults.

## Foundation

```zig
const foundation = mac.foundation;
const s = try foundation.String.init("text");    // yours: s.deinit()
const k = foundation.String.literal("key");      // made once, never freed; no pool needed
const list = foundation.Array(foundation.String).init(&.{ k, s });   // yours
list.at(9)                                       // null, not an exception
var details: foundation.ErrorObject = undefined; // for `error:` out-parameters
_ = foundation.Data.initContentsOfFile(path, &details) catch { defer details.deinit(); ... };
```

- **`init...` → yours to `deinit`**; every other returned object is autoreleased.
- Collections are typed: `Array(T)`, `MutableArray(T)`, `Dictionary(K, V)`,
  `MutableDictionary(K, V)`. `T` must be `objc.Object` or an `extern struct` whose one field is
  an `objc.Object` — every wrapper here, and every `Subclass`, is.
- `{f}` prints a `String` or an `ErrorObject`. `.utf8()` borrows; `.toOwnedSlice(a)` copies.

Beyond the hand-written types, `foundation.all` is generated: `text.all().lowercaseString()`
reaches every NSString method; `foundation.all.FileManager.defaultManager()`,
`UserDefaults`, `NotificationCenter`, `ProcessInfo`, `Bundle`, `JSONSerialization`, `Task`,
`URLSession`... Generated methods take and return the hand-written types.

## Completion handlers

```zig
var done = try objc.Completion(fn (?metal.Library, ?foundation.ErrorObject) void).init(gpa, io);
defer done.deinit();
device.newLibraryWithSourceOptionsCompletionHandler(src, null, done.handler());
const library = try foundation.valueOrError(try done.wait(), &details);   // Io wait: cancelable
```

- `gpa` must be thread-safe (`std.heap.smp_allocator`): the handler may free the shared state
  on its own thread. **Not** `std.testing.allocator`.
- `wait()` returns the handler's args (tuple if several); objects in it live until `deinit`.
- `waitTimeout(timeout)` / cancel are safe: the handler may still run later, and state is
  reference-counted. The handler must be called once.

## AppKit

```zig
const appkit = mac.appkit;
const window = appkit.Window.alloc().initWithContentRectStyleMaskBackingDefer(
    rect, .{ .titled = true, .closable = true }, .buffered, false);
window.setTitle(.literal("title"));
window.into(appkit.Responder)                    // superclass methods; checked at compile time
```

- Names: `NSWindow` → `Window`; selector `a:b:c:` → method `aBC`; enum constants snake case
  (`NSBackingStoreBuffered` → `.buffered`); option sets are `packed struct`s of bools.
- Types: `NSString *` → `foundation.String`, `NSArray<NSScreen *> *` → `foundation.Array(Screen)`,
  `NSRect` → `cg.Rect`, `CGImageRef`/`CGContextRef`/… → `cg.Image`/`cg.Context`/…,
  `NSEdgeInsets` → `EdgeInsets`, unlisted classes → `objc.Object`, blocks →
  `objc.BlockRef(fn (...) R)` (pass `block.ref()`). Nullable → optional.
- Constants and C functions are under `all`, lower camel case, prefix off:
  `foundation.all.runLoopCommonModes()`, `appkit.all.beep()`, `metal.all.currentMediaTime()`.
  A constant is a function. All are weakly linked: one missing from the running macOS panics
  only when used.
- Inherited methods are generated on each subclass: `window.nextResponder()`. `into(T)` is
  only for passing a value where a superclass type is wanted.
- **Never edit `src/appkit/generated.zig`.** To wrap more, add the class, enum, struct or
  protocol to
  `tools/objc_gen/appkit.zig` (or `metal.zig`) and run `zig build generate` (about 10 s). Methods
  the generator cannot type are listed in a `// Not generated:` comment at the end of each
  struct — the usual fix is listing the enum or struct they use.
- C arrays of objects are `[*]const T`, or `[*]const objc.Nullable(T)` when elements may be
  nil: `encoder.setFragmentTexturesWithRange(&.{ .of(tex), .none }, range)`. `const T *` inputs
  are `[*]const T`. C function pointers are `*const fn (...) callconv(.c) R`.
- Main thread only.

`Subclass` instances convert with `into`, checked against the declared superclass and
protocols: `app.setDelegate(delegate.into(appkit.ApplicationDelegate))`,
`window.setContentView(canvas.into(appkit.View))`.

## Metal

```zig
const device = metal.createSystemDefaultDevice() orelse return error.NoGpu;   // yours
const library = try metal.newLibrary(device, msl_source, &details);           // yours
const desc = metal.RenderPipelineDescriptor.new();                            // yours
desc.colorAttachments().objectAtIndexedSubscript(0).setPixelFormat(.bgra8_unorm);
const pipeline = try metal.newRenderPipelineState(device, desc, null);        // yours
```

- Protocols are wrappers: `id<MTLDevice>` → `metal.Device`, `id<MTLTexture>` → `metal.Texture`.
  Parent-protocol methods are on the child (`encoder.endEncoding()`); `into(metal.Resource)`
  converts.
- `new...`/`create...`/`copy...` → yours to `release`; command buffers and encoders are
  autoreleased — a pool per frame.
- Readback: render into a `.managed` texture, `blit.synchronizeResource(tex.into(metal.Resource))`,
  `commit()`, `waitUntilCompleted()`, then `getBytesBytesPerRowFromRegionMipmapLevel`.
- On screen: `appkit.MetalView.init(.{ .frame = rect }, &renderer, Renderer)` with
  `pub fn draw(*Renderer, appkit.MetalView.Frame) void` (and optional `resized`). In `draw`:
  `frame.queue.commandBuffer()`, `frame.renderPass(clear)`, encode, `frame.present(commands)`.
- To wrap more of Metal, edit `tools/objc_gen/metal.zig` and `zig build generate`.

IOSurface — one buffer for the CPU, the GPU, a layer and other processes:

```zig
const surface = try iosurface.Surface.init(.{ .width = w, .height = h });   // .bgra; yours
const locked = try surface.lock(.{});           // bytes only while locked
defer locked.unlock();
const ctx = try locked.initContext();           // cg into the surface (bgra only); deinit before unlock
locked.row(y)                                   // rows are padded: never index by width * 4
device.newTextureWithDescriptorIosurfacePlane(desc, surface, 0)   // Metal view of it (.managed)
layer.setContents(objc.Object.fromCf(surface))                    // a CALayer shows it
```

`Surface.lookup(id)` / `createMachPort` + `fromMachPort` share it with another process; a lookup
returns a new reference to the same memory, not the same pointer.

An app bundle, from a dependent's `build.zig`:

```zig
const bundle = @import("mac").addAppBundle(b, exe, .{ .name = "Demo", .identifier = "com.example.demo" });
b.getInstallStep().dependOn(bundle.step);            // zig-out/Demo.app, ad-hoc signed
b.step("run-app", "Run").dependOn(&bundle.run.step); // runs inside the bundle, output in terminal
```

Options: `.version`, `.build`, `.icon` (.icns LazyPath), `.category`, `.agent` (no Dock icon),
`.info` (extra Info.plist keys, e.g. usage descriptions), `.sign` (identity; `"-"` ad hoc, null
unsigned), `.entitlements`. Permissions such as Screen Recording stick to a bundle's identity
and signature, not to a bare executable that changes with every build.

An application:

```zig
const App = struct {
    pub fn launched(self: *App) void { ... make windows ... }   // optional handlers:
    pub fn shouldQuit(self: *App) bool { return true; }         // launched, shouldQuit,
};                                                              // willQuit, reopened
var app: App = .{};
defer app.deinit();                                  // runs: `run` RETURNS on quit, no exit()
appkit.app.run(.{}, &app, App);                      // menu bar, delegate, event loop; name from bundle
```

- Handler names must not match the context struct's field names (Zig rule) — `did_launch`, not
  `launched`, for a flag.
- A view is `objc.Subclass(.{ .name = ..., .superclass = "NSView" }, struct { ... })` with
  `pub fn @"drawRect:"(self: *@This(), dirty: cg.Rect) void`; draw into
  `appkit.app.currentContext().?` (borrowed — no `deinit`). Make one with
  `Canvas.alloc().msgSend(Canvas, "initWithFrame:", .{rect})`; pass it as
  `appkit.View.from(canvas.object)`.
- Override `acceptsFirstResponder` for keys, `acceptsFirstMouse:` to get the activating click.
- Quit programmatically with `appkit.app.requestQuit()` (asks `shouldQuit`) or `stop()`.
- Off the main thread: `dispatch.Queue.global(.utility).async(ptr, f)`, back with
  `appkit.app.onMain(ptr, f)`. Contexts are pointers that must outlive the work, or use
  `asyncOwned(allocator, value, f)`.
- Test views offscreen: `view.bitmapImageRepForCachingDisplayInRect` +
  `cacheDisplayInRectToBitmapImageRep`, then `colorAtXY`. Deliver events with `NSEvent`
  factories and `window.sendEvent` on a window ordered in at alpha 0 — never `cg.event.post`,
  which moves the user's real mouse.

## Build options

| Option              | Default | Effect                                              |
| ------------------- | ------- | --------------------------------------------------- |
| `-Dimageio=false`   | on      | Drops `mac.cg.imageio`                              |
| `-Dcoretext=false`  | on      | Drops `mac.cg.text`                                 |
| `-Diokit=false`     | on      | Drops `mac.iokit`                                   |
| `-Dobjc=false`      | on      | Drops `mac.objc`, `mac.foundation` and their links  |
| `-Dappkit=false`    | on      | Drops `mac.appkit` and AppKit; needs `-Dobjc`       |
| `-Dmetal=false`     | on      | Drops `mac.metal`, `appkit.MetalView`; needs `-Dobjc` |
| `-Diosurface=false` | on      | Drops `mac.iosurface`; `-Dmetal` needs it           |

Every namespace exists either way, holding `enabled = false` when off. Check
`mac.features.imageio` / `mac.features.coretext` / `mac.features.objc` rather than assuming.

## Validate a change

```sh
zig build test                      # inline tests plus integration tests
zig build test -Dimageio=false      # the gated namespaces still compile out
zig build test -Dcoretext=false
zig build test -Dobjc=false
zig build test -Dappkit=false
zig build test -Dmetal=false
zig build test -Dtarget=x86_64-macos   # BOOL, _stret and _fpret differ on Intel; runs under Rosetta
zig build                           # every example still builds
zig build bindings                  # inspect the translated C API
zig build generate                  # after changing tools/objc_gen; commit the result
```

Drawing tests assert on real pixels — make a small bitmap context, draw, and read
`bitmapData()` indexed by `bitmapBytesPerRow()`. Do not write tests that post events: they
would move the user's real mouse.

Objective-C tests check values against a real Foundation method (`NSValue` round trips a
struct, `NSArray` calls a block), not against this binding's own idea of the answer. A class
defined in a test must be defined once per process: cache it.

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
- `@Fn(param_types, param_attrs, Return, .{ .@"callconv" = .c })` builds a function type, and
  `@Tuple(&types)` a tuple type. `@Type` is gone. A function *body* of computed arity is still
  impossible, which is why `objc/abi.zig` spells out one trampoline per arity.
- A plain function call is a runtime value even when every argument is comptime, so
  `if (isObject(T))` analyses both branches. Make such type predicates `inline fn`.
- A struct declared inside a generic function is one type across instantiations unless it
  mentions the comptime parameter — a per-name static cache has to reference the name.
- `@alignCast` and `@ptrFromInt` check alignment at run time, even into `[*c]`. A tagged-pointer
  Objective-C object is not aligned, so objects stay `*anyopaque` and never become `raw.id`.
