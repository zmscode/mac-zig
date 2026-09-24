//! Selectors: the names messages are sent by.

const std = @import("std");
const raw = @import("mac_raw");

/// A registered method name, like `initWithFrame:`. Two selectors with the
/// same name are the same pointer, so `eql` is a pointer comparison.
///
/// Most code never makes one: `msgSend` takes the name as a comptime
/// string and looks the selector up once per call site. Build a `Sel` for a
/// name that is only known at run time.
pub const Sel = extern struct {
    value: *raw.struct_objc_selector,

    /// Registers `name` if it is new, and returns its selector either way.
    pub fn init(text: [:0]const u8) Sel {
        return .{ .value = raw.sel_registerName(text.ptr).? };
    }

    /// The selector for a comptime-known `name`, registered on first use
    /// and cached from then on. This is what a string passed to `msgSend`
    /// becomes, and it is the equivalent of the selector references a C
    /// compiler emits.
    pub fn cached(comptime text: [:0]const u8) Sel {
        const Cache = struct {
            // Referenced so that each name gets its own `Cache` -- a
            // struct that does not mention `text` is shared between them.
            const key = text;
            var value: ?*raw.struct_objc_selector = null;
        };
        if (@atomicLoad(?*raw.struct_objc_selector, &Cache.value, .monotonic)) |value| {
            return .{ .value = value };
        }
        const selector = init(Cache.key);
        @atomicStore(?*raw.struct_objc_selector, &Cache.value, selector.value, .monotonic);
        return selector;
    }

    pub fn fromRaw(value: raw.SEL) ?Sel {
        return .{ .value = value orelse return null };
    }

    pub inline fn toRaw(self: Sel) raw.SEL {
        return self.value;
    }

    /// The name, borrowed from the runtime, which never frees it.
    pub fn name(self: Sel) [:0]const u8 {
        return std.mem.span(raw.sel_getName(self.value));
    }

    pub fn eql(self: Sel, other: Sel) bool {
        return self.value == other.value;
    }

    /// How many arguments a message with this selector takes: one per
    /// colon.
    pub fn argumentCount(self: Sel) usize {
        return std.mem.countScalar(u8, self.name(), ':');
    }
};

/// `Sel.init`, under the name the runtime uses.
pub fn sel(name: [:0]const u8) Sel {
    return .init(name);
}

/// Fails compilation when a comptime selector does not take `count`
/// arguments -- the mistake that otherwise surfaces as a crash inside
/// `objc_msgSend`, or worse, as garbage read from a register.
pub fn checkArity(comptime name: [:0]const u8, comptime count: usize, comptime what: []const u8) void {
    const colons = std.mem.countScalar(u8, name, ':');
    if (colons != count) @compileError(std.fmt.comptimePrint(
        "selector \"{s}\" takes {d} argument(s), but {s} has {d}",
        .{ name, colons, what, count },
    ));
}

/// The selector named by `selector`, which is either a `Sel` or a
/// comptime-known string.
pub inline fn from(selector: anytype) Sel {
    return if (@TypeOf(selector) == Sel) selector else Sel.cached(comptime selector);
}

/// `from`, with a string checked against `arg_count`.
pub inline fn resolve(selector: anytype, comptime arg_count: usize) Sel {
    if (@TypeOf(selector) == Sel) {
        return selector;
    } else {
        comptime checkArity(selector, arg_count, "the call");
        return Sel.cached(selector);
    }
}

test "a selector knows its name and arity" {
    const s = sel("initWithFrame:display:");
    try std.testing.expectEqualStrings("initWithFrame:display:", s.name());
    try std.testing.expectEqual(@as(usize, 2), s.argumentCount());
}

test "the same name is the same selector" {
    try std.testing.expect(sel("description").eql(sel("description")));
    try std.testing.expect(Sel.cached("description").eql(sel("description")));
    try std.testing.expect(!Sel.cached("hash").eql(Sel.cached("description")));
}
