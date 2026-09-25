const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const imageio = b.option(
        bool,
        "imageio",
        "Expose ImageIO, which is what reads and writes PNG and JPEG files",
    ) orelse true;
    const coretext = b.option(
        bool,
        "coretext",
        "Expose the CoreText bridge, which is what draws a string",
    ) orelse true;
    const iokit = b.option(
        bool,
        "iokit",
        "Expose IOKit's power sources: battery charge and time remaining",
    ) orelse true;
    const iosurface = b.option(
        bool,
        "iosurface",
        "Expose IOSurface, pixel buffers shared between processes and with the GPU",
    ) orelse true;
    const objc = b.option(
        bool,
        "objc",
        "Expose the Objective-C runtime and Foundation, which is what sends a message",
    ) orelse true;
    const appkit = b.option(
        bool,
        "appkit",
        "Expose the generated AppKit wrappers and link AppKit (needs -Dobjc)",
    ) orelse objc;
    const metal = b.option(
        bool,
        "metal",
        "Expose the generated Metal wrappers and link Metal and QuartzCore (needs -Dobjc)",
    ) orelse objc;
    if (metal and !iosurface) {
        std.debug.print("-Dmetal needs -Diosurface: Metal's textures can be backed by an IOSurface.\n", .{});
        std.process.exit(1);
    }
    if (metal and !objc) {
        std.debug.print("-Dmetal needs -Dobjc: Metal is reached through the Objective-C runtime.\n", .{});
        std.process.exit(1);
    }
    if (appkit and !objc) {
        std.debug.print("-Dappkit needs -Dobjc: AppKit is reached through the Objective-C runtime.\n", .{});
        std.process.exit(1);
    }
    const features: Features = .{
        .imageio = imageio,
        .coretext = coretext,
        .iokit = iokit,
        .iosurface = iosurface,
        .objc = objc,
        .appkit = appkit,
        .metal = metal,
    };

    // -----------------------------------------------------------------
    // CoreGraphics ships with macOS, so there is nothing to build and
    // nothing to fetch -- but the headers live in the Xcode SDK, and the
    // frameworks are only there to link against on Darwin.
    // -----------------------------------------------------------------
    if (!target.result.os.tag.isDarwin()) {
        std.debug.print(
            \\mac-zig binds the macOS system frameworks, which exist only on Apple platforms.
            \\The requested target was {s}.
            \\
        , .{@tagName(target.result.os.tag)});
        std.process.exit(1);
    }

    const sdk = std.zig.system.darwin.getSdk(b.graph.arena, b.graph.io, &target.result) orelse {
        std.debug.print(
            \\mac-zig needs the macOS SDK headers and could not find them.
            \\Install the Xcode command line tools with:
            \\
            \\    xcode-select --install
            \\
        , .{});
        std.process.exit(1);
    };

    const options = b.addOptions();
    options.addOption(bool, "imageio", imageio);
    options.addOption(bool, "coretext", coretext);
    options.addOption(bool, "iokit", iokit);
    options.addOption(bool, "iosurface", iosurface);
    options.addOption(bool, "objc", objc);
    options.addOption(bool, "appkit", appkit);
    options.addOption(bool, "metal", metal);

    // -----------------------------------------------------------------
    // The raw layer.
    // -----------------------------------------------------------------
    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("vendor/mac_translate.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    translate_c.addSystemFrameworkPath(.{
        .cwd_relative = b.pathJoin(&.{ sdk, "System/Library/Frameworks" }),
    });
    translate_c.addSystemIncludePath(.{
        .cwd_relative = b.pathJoin(&.{ sdk, "usr/include" }),
    });
    if (imageio) translate_c.defineCMacro("MAC_ZIG_IMAGEIO", "1");
    if (iokit) translate_c.defineCMacro("MAC_ZIG_IOKIT", "1");
    if (iosurface) translate_c.defineCMacro("MAC_ZIG_IOSURFACE", "1");
    if (objc) translate_c.defineCMacro("MAC_ZIG_OBJC", "1");

    // -----------------------------------------------------------------
    // The idiomatic layer.
    // -----------------------------------------------------------------
    const mac = b.addModule("mac", .{
        .root_source_file = b.path("src/mac.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .imports = &.{
            .{ .name = "mac_raw", .module = translate_c.createModule() },
            .{ .name = "mac_build_options", .module = options.createModule() },
        },
    });
    linkFrameworks(b, mac, sdk, features);

    // -----------------------------------------------------------------
    // Steps
    // -----------------------------------------------------------------
    const bindings_step = b.step("bindings", "Write the translated C bindings to zig-out/bindings");
    bindings_step.dependOn(&b.addInstallFile(translate_c.getOutput(), "bindings/mac.zig").step);

    const test_step = b.step("test", "Run the binding tests");

    // The inline tests that sit next to the code they cover. The module is
    // rebuilt here rather than reused, because `cg` is a dependency of the
    // test artifact and a dependency's own tests do not come along.
    const unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/mac.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{
                .{ .name = "mac_raw", .module = translate_c.createModule() },
                .{ .name = "mac_build_options", .module = options.createModule() },
            },
        }),
    });
    linkFrameworks(b, unit_tests.root_module, sdk, features);
    test_step.dependOn(&b.addRunArtifact(unit_tests).step);

    // The tests that use the package the way a dependent would.
    const smoke_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("tests/smoke.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "mac", .module = mac }},
        }),
    });
    test_step.dependOn(&b.addRunArtifact(smoke_tests).step);

    // -----------------------------------------------------------------
    // Regenerating the Objective-C wrappers. Not part of a normal build:
    // the output is checked in, and this needs the SDK's full headers.
    // -----------------------------------------------------------------
    const generate_step = b.step("generate", "Regenerate the Objective-C wrappers from the SDK's headers");
    // Each manifest, and where its wrappers go. The generator is built once
    // per manifest, since the manifest is compiled into it.
    for ([_][2][]const u8{ .{ "appkit", "src/appkit" }, .{ "metal", "src/metal" } }) |job| {
        const generator = b.addExecutable(.{
            .name = b.fmt("objc_gen_{s}", .{job[0]}),
            .root_module = b.createModule(.{
                .root_source_file = b.path("tools/objc_gen/main.zig"),
                .target = b.graph.host,
                .optimize = .ReleaseSafe,
                .imports = &.{.{
                    .name = "manifest",
                    .module = b.createModule(.{ .root_source_file = b.path(b.fmt("tools/objc_gen/{s}.zig", .{job[0]})) }),
                }},
            }),
        });
        const generate = b.addRunArtifact(generator);
        generate.addArgs(&.{ b.graph.zig_exe, sdk });
        _ = generate.addOutputDirectoryArg("dumps");
        generate.addDirectoryArg(b.path(job[1]));
        generate.has_side_effects = true;
        const format_generated = b.addFmt(.{ .paths = &.{b.path(b.fmt("{s}/generated.zig", .{job[1]}))} });
        format_generated.step.dependOn(&generate.step);
        generate_step.dependOn(&format_generated.step);
    }

    const examples_step = b.step("examples", "Build every example");
    for ([_][]const u8{ "info", "power", "shapes", "gradient", "text", "pdf", "objc", "window", "metal" }) |name| {
        const exe = addExample(b, examples_step, mac, target, optimize, name);

        // The window example again, as the app it is.
        if (std.mem.eql(u8, name, "window") and appkit) {
            const bundle = addAppBundle(b, exe, .{
                .name = "mac-zig Window",
                .identifier = "io.github.zmscode.mac-zig.window",
                .category = "public.app-category.developer-tools",
            });
            b.step("window-app", "Build the window example as a signed .app bundle")
                .dependOn(bundle.step);
            b.step("run-window-app", "Run the window example from its .app bundle")
                .dependOn(&bundle.run.step);
        }
    }
    b.getInstallStep().dependOn(examples_step);
}

// ---------------------------------------------------------------------
// Application bundles
// ---------------------------------------------------------------------

pub const AppBundleOptions = struct {
    /// The name in Finder, the Dock and the menu bar. The bundle is
    /// installed as `<name>.app` under the install prefix.
    name: []const u8,
    /// Reverse-DNS and unique to the app -- `com.example.demo`. macOS keys
    /// permissions, preferences and notifications to it.
    identifier: []const u8,
    /// `CFBundleShortVersionString`, the version a person sees.
    version: []const u8 = "1.0",
    /// `CFBundleVersion`, the build number.
    build: []const u8 = "1",
    /// The oldest macOS the app will launch on.
    minimum_system_version: []const u8 = "13.0",
    /// An `.icns` file for the Dock and Finder.
    icon: ?std.Build.LazyPath = null,
    /// `LSApplicationCategoryType`, such as `public.app-category.games`.
    category: ?[]const u8 = null,
    /// No Dock icon or menu bar (`LSUIElement`): a menu-bar extra or a
    /// background helper.
    agent: bool = false,
    /// Further `Info.plist` entries -- usage descriptions like
    /// `NSCameraUsageDescription`, say.
    info: []const InfoEntry = &.{},
    /// The code-signing identity. `"-"` signs ad hoc, which is enough to
    /// run locally and to hold on to granted permissions; a Developer ID is
    /// needed to hand the app to anyone else. null leaves it unsigned.
    sign: ?[]const u8 = "-",
    /// An entitlements `.plist` to sign with.
    entitlements: ?std.Build.LazyPath = null,
};

pub const InfoEntry = struct {
    key: []const u8,
    value: union(enum) {
        string: []const u8,
        boolean: bool,
    },
};

pub const AppBundle = struct {
    /// Builds, lays out and signs the bundle.
    step: *std.Build.Step,
    /// The installed `.app`, under the install prefix.
    path: std.Build.LazyPath,
    /// Runs the executable inside the bundle -- a bundled app in every way
    /// that matters, with its output still in the terminal. Takes `--`
    /// arguments.
    run: *std.Build.Step.Run,
};

/// Wraps `exe` in a macOS application bundle:
///
/// ```text
/// <name>.app/Contents/Info.plist
///                    /PkgInfo
///                    /MacOS/<exe>
///                    /Resources/<icon>.icns
/// ```
///
/// and signs it. A dependent reaches this from its own `build.zig` through
/// the package, `@import("mac").addAppBundle(b, exe, .{ ... })`.
pub fn addAppBundle(b: *std.Build, exe: *std.Build.Step.Compile, options: AppBundleOptions) AppBundle {
    const app_dir = b.fmt("{s}.app", .{options.name});
    const contents = b.fmt("{s}/Contents", .{app_dir});
    const step = b.step(b.fmt("bundle {s}", .{options.name}), b.fmt("Bundle {s}.app", .{options.name}));

    const install_exe = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .{ .custom = b.fmt("{s}/MacOS", .{contents}) } },
    });

    const icon_name: ?[]const u8 = if (options.icon) |icon| blk: {
        const name = "AppIcon.icns";
        const install_icon = b.addInstallFileWithDir(icon, .{ .custom = b.fmt("{s}/Resources", .{contents}) }, name);
        step.dependOn(&install_icon.step);
        break :blk name;
    } else null;

    const files = b.addWriteFiles();
    const plist = files.add("Info.plist", infoPlist(b, exe.name, options, icon_name));
    const pkg_info = files.add("PkgInfo", "APPL????");
    const install_plist = b.addInstallFileWithDir(plist, .{ .custom = contents }, "Info.plist");
    const install_pkg_info = b.addInstallFileWithDir(pkg_info, .{ .custom = contents }, "PkgInfo");

    const path: std.Build.LazyPath = .{ .relative = .{ .base = .install_prefix, .sub_path = app_dir } };
    if (options.sign) |identity| {
        // Signed last, over the finished bundle: the signature seals
        // Info.plist and the resources as well as the executable.
        const codesign = b.addSystemCommand(&.{ "codesign", "--force", "--sign", identity });
        if (options.entitlements) |entitlements| {
            codesign.addArg("--entitlements");
            codesign.addFileArg(entitlements);
        }
        codesign.addDirectoryArg(path);
        codesign.step.dependOn(&install_exe.step);
        codesign.step.dependOn(&install_plist.step);
        codesign.step.dependOn(&install_pkg_info.step);
        codesign.has_side_effects = true;
        codesign.setName(b.fmt("codesign {s}.app", .{options.name}));
        step.dependOn(&codesign.step);
    } else {
        step.dependOn(&install_exe.step);
        step.dependOn(&install_plist.step);
        step.dependOn(&install_pkg_info.step);
    }

    const run = std.Build.Step.Run.create(b, b.fmt("run {s}.app", .{options.name}));
    run.addFileArg(.{ .relative = .{
        .base = .install_prefix,
        .sub_path = b.fmt("{s}/MacOS/{s}", .{ contents, exe.name }),
    } });
    run.step.dependOn(step);
    run.addPassthruArgs();

    return .{ .step = step, .path = path, .run = run };
}

fn infoPlist(b: *std.Build, executable: []const u8, options: AppBundleOptions, icon: ?[]const u8) []const u8 {
    var out: std.ArrayList(u8) = .empty;
    const a = b.allocator;
    out.appendSlice(a,
        \\<?xml version="1.0" encoding="UTF-8"?>
        \\<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        \\<plist version="1.0">
        \\<dict>
        \\
    ) catch @panic("out of memory");

    const strings = [_][2][]const u8{
        .{ "CFBundleName", options.name },
        .{ "CFBundleDisplayName", options.name },
        .{ "CFBundleIdentifier", options.identifier },
        .{ "CFBundleExecutable", executable },
        .{ "CFBundlePackageType", "APPL" },
        .{ "CFBundleShortVersionString", options.version },
        .{ "CFBundleVersion", options.build },
        .{ "CFBundleInfoDictionaryVersion", "6.0" },
        .{ "LSMinimumSystemVersion", options.minimum_system_version },
        .{ "NSPrincipalClass", "NSApplication" },
    };
    for (strings) |entry| plistString(a, &out, entry[0], entry[1]);
    plistBool(a, &out, "NSHighResolutionCapable", true);
    plistBool(a, &out, "NSSupportsAutomaticGraphicsSwitching", true);
    if (icon) |name| plistString(a, &out, "CFBundleIconFile", name);
    if (options.category) |category| plistString(a, &out, "LSApplicationCategoryType", category);
    if (options.agent) plistBool(a, &out, "LSUIElement", true);
    for (options.info) |entry| switch (entry.value) {
        .string => |value| plistString(a, &out, entry.key, value),
        .boolean => |value| plistBool(a, &out, entry.key, value),
    };

    out.appendSlice(a, "</dict>\n</plist>\n") catch @panic("out of memory");
    return out.items;
}

fn plistString(a: std.mem.Allocator, out: *std.ArrayList(u8), key: []const u8, value: []const u8) void {
    out.appendSlice(a, "\t<key>") catch @panic("out of memory");
    xmlEscape(a, out, key);
    out.appendSlice(a, "</key>\n\t<string>") catch @panic("out of memory");
    xmlEscape(a, out, value);
    out.appendSlice(a, "</string>\n") catch @panic("out of memory");
}

fn plistBool(a: std.mem.Allocator, out: *std.ArrayList(u8), key: []const u8, value: bool) void {
    out.appendSlice(a, "\t<key>") catch @panic("out of memory");
    xmlEscape(a, out, key);
    out.appendSlice(a, if (value) "</key>\n\t<true/>\n" else "</key>\n\t<false/>\n") catch @panic("out of memory");
}

fn xmlEscape(a: std.mem.Allocator, out: *std.ArrayList(u8), text: []const u8) void {
    for (text) |c| {
        const escaped: []const u8 = switch (c) {
            '&' => "&amp;",
            '<' => "&lt;",
            '>' => "&gt;",
            '"' => "&quot;",
            else => &.{c},
        };
        out.appendSlice(a, escaped) catch @panic("out of memory");
    }
}

const Features = struct {
    imageio: bool,
    coretext: bool,
    iokit: bool,
    iosurface: bool,
    objc: bool,
    appkit: bool,
    metal: bool,
};

/// Everything a module needs to use the frameworks that are switched on:
/// the SDK's search paths, the links, and the one Objective-C source file.
fn linkFrameworks(b: *std.Build, module: *std.Build.Module, sdk: []const u8, features: Features) void {
    module.addSystemFrameworkPath(.{
        .cwd_relative = b.pathJoin(&.{ sdk, "System/Library/Frameworks" }),
    });
    module.linkFramework("CoreFoundation", .{});
    module.linkFramework("CoreGraphics", .{});
    if (features.imageio) module.linkFramework("ImageIO", .{});
    if (features.coretext) module.linkFramework("CoreText", .{});
    if (features.iokit) module.linkFramework("IOKit", .{});
    if (features.iosurface) module.linkFramework("IOSurface", .{});
    if (features.objc) {
        // libobjc is a library rather than a framework, and a cross build
        // does not search the SDK's usr/lib unless told to.
        module.addLibraryPath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "usr/lib" }) });
        module.linkSystemLibrary("objc", .{});
        module.linkFramework("Foundation", .{});

        // @try/@catch has no C spelling, so catching an Objective-C
        // exception takes one small Objective-C file.
        module.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{ sdk, "usr/include" }) });
        module.addCSourceFile(.{ .file = b.path("vendor/mac_objc_exception.m") });
    }
    if (features.appkit) module.linkFramework("AppKit", .{});
    if (features.metal) {
        module.linkFramework("Metal", .{});
        module.linkFramework("QuartzCore", .{});
    }
}

fn addExample(
    b: *std.Build,
    step: *std.Build.Step,
    mac: *std.Build.Module,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    name: []const u8,
) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = name,
        .root_module = b.createModule(.{
            .root_source_file = b.path(b.fmt("examples/{s}.zig", .{name})),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "mac", .module = mac }},
        }),
    });
    step.dependOn(&b.addInstallArtifact(exe, .{}).step);

    const run = b.addRunArtifact(exe);
    run.addPassthruArgs();
    b.step(
        b.fmt("run-{s}", .{name}),
        b.fmt("Run the {s} example", .{name}),
    ).dependOn(&run.step);
    return exe;
}
