const std = @import("std");
const objc = @import("../objc/objc.zig");
const foundation = @import("foundation.zig");
const generated = @import("generated.zig");

test "every generated constant and function compiles" {
    @setEvalBranchQuota(1_000_000);
    inline for (@typeInfo(generated).@"struct".decl_names) |name| {
        const member = @field(generated, name);
        const info = @typeInfo(@TypeOf(member));
        if (info == .@"fn" and !info.@"fn".is_generic) std.mem.doNotOptimizeAway(&member);
    }
}

test "Foundation's constants and functions, called" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    try std.testing.expect(foundation.all.runLoopCommonModes().eql(.literal("kCFRunLoopCommonModes")));
    try std.testing.expect(foundation.all.homeDirectory().hasPrefix(.literal("/")));
    try std.testing.expect(foundation.all.stringFromSelector(objc.sel("initWithFrame:")).eql(.literal("initWithFrame:")));
    try std.testing.expect(foundation.all.selectorFromString(.literal("count")).eql(objc.sel("count")));
    try std.testing.expect(foundation.all.cocoaErrorDomain().eql(.literal("NSCocoaErrorDomain")));
}
