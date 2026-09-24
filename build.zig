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
    if (appkit and !objc) {
        std.debug.print("-Dappkit needs -Dobjc: AppKit is reached through the Objective-C runtime.\n", .{});
        std.process.exit(1);
    }
    const features: Features = .{
        .imageio = imageio,
        .coretext = coretext,
        .iokit = iokit,
        .objc = objc,
        .appkit = appkit,
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
    options.addOption(bool, "objc", objc);
    options.addOption(bool, "appkit", appkit);

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
    const generator = b.addExecutable(.{
        .name = "objc_gen",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/objc_gen/main.zig"),
            .target = b.graph.host,
            .optimize = .ReleaseSafe,
            .imports = &.{.{
                .name = "manifest",
                .module = b.createModule(.{ .root_source_file = b.path("tools/objc_gen/appkit.zig") }),
            }},
        }),
    });
    const generate = b.addRunArtifact(generator);
    generate.addArgs(&.{ b.graph.zig_exe, sdk });
    _ = generate.addOutputDirectoryArg("dumps");
    generate.addDirectoryArg(b.path("src/appkit"));
    generate.has_side_effects = true;
    const format_generated = b.addFmt(.{ .paths = &.{b.path("src/appkit/generated.zig")} });
    format_generated.step.dependOn(&generate.step);
    b.step("generate", "Regenerate src/appkit/generated.zig from the SDK's headers")
        .dependOn(&format_generated.step);

    const examples_step = b.step("examples", "Build every example");
    for ([_][]const u8{ "info", "power", "shapes", "gradient", "text", "pdf", "objc", "window" }) |name| {
        addExample(b, examples_step, mac, target, optimize, name);
    }
    b.getInstallStep().dependOn(examples_step);
}

const Features = struct {
    imageio: bool,
    coretext: bool,
    iokit: bool,
    objc: bool,
    appkit: bool,
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
}

fn addExample(
    b: *std.Build,
    step: *std.Build.Step,
    mac: *std.Build.Module,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    name: []const u8,
) void {
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
}
