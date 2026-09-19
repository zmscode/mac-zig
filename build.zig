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
    mac.addSystemFrameworkPath(.{
        .cwd_relative = b.pathJoin(&.{ sdk, "System/Library/Frameworks" }),
    });
    mac.linkFramework("CoreFoundation", .{});
    mac.linkFramework("CoreGraphics", .{});
    if (imageio) mac.linkFramework("ImageIO", .{});
    if (coretext) mac.linkFramework("CoreText", .{});

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
    unit_tests.root_module.addSystemFrameworkPath(.{
        .cwd_relative = b.pathJoin(&.{ sdk, "System/Library/Frameworks" }),
    });
    unit_tests.root_module.linkFramework("CoreFoundation", .{});
    unit_tests.root_module.linkFramework("CoreGraphics", .{});
    if (imageio) unit_tests.root_module.linkFramework("ImageIO", .{});
    if (coretext) unit_tests.root_module.linkFramework("CoreText", .{});
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

    const examples_step = b.step("examples", "Build every example");
    for ([_][]const u8{ "info", "shapes", "gradient", "text", "pdf" }) |name| {
        addExample(b, examples_step, mac, target, optimize, name);
    }
    b.getInstallStep().dependOn(examples_step);
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
