//! What `zig build generate` generates for Foundation: its constants and
//! C functions. Foundation's classes are wrapped by hand, in
//! `src/foundation/`; this is the long tail beside them -- notification
//! names, run-loop modes, error domains, `NSStringFromSelector` and the
//! like. The result is `src/foundation/generated.zig`.

pub const framework = "Foundation";
pub const imports = [_][]const u8{"Foundation/Foundation.h"};
pub const prefixes = [_][]const u8{"NS"};
/// The frameworks whose `extern` constants and C functions are generated.
pub const frameworks = [_][]const u8{"Foundation"};

pub const classes = [_][]const u8{};
pub const protocols = [_][]const u8{};
pub const enums = [_][]const u8{
    "NSComparisonResult",
    "NSSearchPathDirectory",
    "NSSearchPathDomainMask",
    "NSQualityOfService",
};
pub const structs = [_][]const u8{};
