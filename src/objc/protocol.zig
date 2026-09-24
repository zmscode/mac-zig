//! Protocols: named sets of methods a class promises to implement.

const std = @import("std");
const raw = @import("mac_raw");
const abi = @import("abi.zig");

/// A protocol, such as `NSCopying` or `NSApplicationDelegate`.
///
/// A protocol is only registered with the runtime once something that
/// uses it is loaded, so `getProtocol` answers null for a delegate
/// protocol whose framework is not linked -- `NSApplicationDelegate` needs
/// AppKit.
pub const Protocol = extern struct {
    value: *raw.Protocol,

    pub fn fromRaw(value: [*c]raw.Protocol) ?Protocol {
        if (value == null) return null;
        return .{ .value = value };
    }

    pub inline fn toRaw(self: Protocol) [*c]raw.Protocol {
        return self.value;
    }

    /// The name, borrowed from the runtime.
    pub fn name(self: Protocol) [:0]const u8 {
        return std.mem.span(raw.protocol_getName(self.value));
    }

    /// True when this protocol adopts `other`, directly or not.
    pub fn conformsTo(self: Protocol, other: Protocol) bool {
        return abi.fromAbi(bool, raw.protocol_conformsToProtocol(self.value, other.value));
    }

    pub fn eql(self: Protocol, other: Protocol) bool {
        return abi.fromAbi(bool, raw.protocol_isEqual(self.value, other.value));
    }
};

/// The protocol called `name`, or null if nothing loaded declares it.
pub fn getProtocol(name: [:0]const u8) ?Protocol {
    return .fromRaw(raw.objc_getProtocol(name.ptr));
}

test "a protocol from Foundation" {
    const copying = getProtocol("NSCopying").?;
    try std.testing.expectEqualStrings("NSCopying", copying.name());
    try std.testing.expect(getProtocol("NoSuchProtocolAnywhere") == null);

    const secure = getProtocol("NSSecureCoding").?;
    try std.testing.expect(secure.conformsTo(getProtocol("NSCoding").?));
}
