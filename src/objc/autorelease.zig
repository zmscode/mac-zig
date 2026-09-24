//! Autorelease pools: where objects you do not own go to be released.

const abi = @import("abi.zig");

/// `@autoreleasepool { ... }`.
///
/// Most messages hand back an object you do not own, which the runtime
/// keeps alive by adding it to the innermost pool. The pool releases
/// everything in it when it is drained, so a loop that makes many
/// temporary objects wants a pool of its own, and a thread that sends
/// messages wants at least one:
///
/// ```zig
/// const pool = objc.AutoreleasePool.init();
/// defer pool.deinit();
/// ```
///
/// Pools nest, and must be drained in the reverse of the order they were
/// made -- which `defer` does for free.
pub const AutoreleasePool = struct {
    handle: ?*anyopaque,

    pub fn init() AutoreleasePool {
        return .{ .handle = abi.objc_autoreleasePoolPush() };
    }

    /// Releases every object autoreleased since `init`.
    pub fn deinit(self: AutoreleasePool) void {
        abi.objc_autoreleasePoolPop(self.handle);
    }
};
