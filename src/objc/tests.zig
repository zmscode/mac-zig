//! Tests that drive the runtime through Foundation, checking each kind of
//! value against a real method rather than against this binding's idea of
//! one.

const std = @import("std");
const cf = @import("../cf.zig");
const geometry = @import("../cg/geometry.zig");
const objc = @import("objc.zig");

const Object = objc.Object;
const Sel = objc.Sel;
const Integer = objc.Integer;
const UInteger = objc.UInteger;

fn class(comptime name: [:0]const u8) objc.Class {
    return objc.getClass(name).?;
}

fn number(value: i64) Object {
    return class("NSNumber").msgSend(Object, "numberWithLongLong:", .{value});
}

/// An autoreleased `NSString`.
fn string(text: [:0]const u8) Object {
    return class("NSString").msgSend(Object, "stringWithUTF8String:", .{text.ptr});
}

test "integers in and out, through a tagged pointer" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    // Small NSNumbers are tagged pointers -- not aligned, not dereferenceable.
    const n = number(42);
    try std.testing.expectEqual(@as(i64, 42), n.msgSend(i64, "longLongValue", .{}));
    try std.testing.expect(n.isKindOf(class("NSNumber")));
    try std.testing.expect(!n.isKindOf(class("NSString")));
}

test "floats in and out" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const n = class("NSNumber").msgSend(Object, "numberWithDouble:", .{@as(f64, 2.25)});
    try std.testing.expectEqual(@as(f64, 2.25), n.msgSend(f64, "doubleValue", .{}));
    try std.testing.expectEqual(@as(f32, 2.25), n.msgSend(f32, "floatValue", .{}));
}

test "BOOL in and out" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const yes = class("NSNumber").msgSend(Object, "numberWithBool:", .{true});
    try std.testing.expect(yes.msgSend(bool, "boolValue", .{}));

    const a = string("same");
    try std.testing.expect(a.msgSend(bool, "isEqualToString:", .{string("same")}));
    try std.testing.expect(!a.msgSend(bool, "isEqualToString:", .{string("different")}));
    try std.testing.expect(a.eql(string("same")));
}

test "a struct too big for registers, in and out" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    // 32 bytes: returned through memory on both architectures.
    const rect: geometry.Rect = .init(1, 2, 3, 4);
    const boxed = class("NSValue").msgSend(Object, "valueWithRect:", .{rect});
    const back = boxed.msgSend(geometry.Rect, "rectValue", .{});
    try std.testing.expectEqual(rect, back);
}

test "a two-word struct, in and out" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const text = string("hello, world");
    const found = text.msgSend(objc.Range, "rangeOfString:", .{string("world")});
    try std.testing.expectEqual(objc.Range{ .location = 7, .length = 5 }, found);

    const missing = text.msgSend(objc.Range, "rangeOfString:", .{string("absent")});
    try std.testing.expect(!missing.found());
}

test "nil comes back as null" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const empty = class("NSArray").msgSend(Object, "array", .{});
    try std.testing.expect(empty.msgSend(?Object, "firstObject", .{}) == null);
    try std.testing.expectEqual(@as(UInteger, 0), empty.msgSend(UInteger, "count", .{}));
}

test "a runtime selector" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const name: [:0]const u8 = "uppercaseString";
    const upper = string("shout").msgSend(Object, objc.sel(name), .{});
    try std.testing.expect(upper.eql(string("SHOUT")));
    try std.testing.expect(string("x").respondsTo("length"));
    try std.testing.expect(!string("x").respondsTo("noSuchMethod"));
}

test "CoreFoundation values are Objective-C objects" {
    const text = try cf.String.init("bridged");
    defer text.deinit();

    const object = Object.fromCf(text);
    try std.testing.expectEqual(@as(UInteger, 7), object.msgSend(UInteger, "length", .{}));
    try std.testing.expect(object.asCf(cf.String) != null);
    try std.testing.expect(object.asCf(cf.Number) == null);

    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();
    const tagged = number(3);
    try std.testing.expectEqual(@as(i64, 3), tagged.asCf(cf.Number).?.toInt());
}

test "description, as a Zig string" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const text = try number(1234).description(std.testing.allocator);
    defer std.testing.allocator.free(text);
    try std.testing.expectEqualStrings("1234", text);
}

test "properties by name" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const text = class("NSMutableString").msgSend(Object, "string", .{});
    text.setProperty("string", string("set through a property"));
    try std.testing.expectEqual(@as(UInteger, 22), text.getProperty(UInteger, "length"));
}

test "a typed wrapper passes and returns as an object" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const String = struct {
        object: Object,

        fn length(self: @This()) UInteger {
            return self.object.msgSend(UInteger, "length", .{});
        }
    };

    const word = class("NSString").msgSend(String, "stringWithUTF8String:", .{"wrapped".ptr});
    try std.testing.expectEqual(@as(UInteger, 7), word.length());

    const joined = word.object.msgSend(String, "stringByAppendingString:", .{word});
    try std.testing.expectEqual(@as(UInteger, 14), joined.length());
}

test "a block called by Foundation" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const values = [_]Object{ number(1), number(2), number(3), number(4) };
    const array = class("NSArray").msgSend(Object, "arrayWithObjects:count:", .{
        @as([*]const Object, &values),
        @as(UInteger, values.len),
    });

    const Visit = objc.Block(struct { total: *i64, visits: *usize }, fn (Object, UInteger, *bool) void);
    var total: i64 = 0;
    var visits: usize = 0;
    var block = Visit.init(.{ .total = &total, .visits = &visits }, struct {
        fn body(captures: *const Visit.Captures, item: Object, index: UInteger, stop: *bool) void {
            captures.total.* += item.msgSend(i64, "longLongValue", .{});
            captures.visits.* += 1;
            if (index == 2) stop.* = true;
        }
    }.body);
    array.msgSend(void, "enumerateObjectsUsingBlock:", .{&block});

    try std.testing.expectEqual(@as(i64, 6), total);
    try std.testing.expectEqual(@as(usize, 3), visits);
}

test "a block that returns a value to Foundation" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const values = [_]Object{ number(3), number(1), number(2) };
    const array = class("NSArray").msgSend(Object, "arrayWithObjects:count:", .{
        @as([*]const Object, &values),
        @as(UInteger, values.len),
    });

    // Sorts descending, so the result proves the block's answer was used.
    const Compare = objc.Block(struct {}, fn (Object, Object) Integer);
    var block = Compare.init(.{}, struct {
        fn body(_: *const Compare.Captures, a: Object, b: Object) Integer {
            return b.msgSend(Integer, "compare:", .{a});
        }
    }.body);
    const sorted = array.msgSend(Object, "sortedArrayUsingComparator:", .{&block});

    for ([_]i64{ 3, 2, 1 }, 0..) |expected, i| {
        const item = sorted.msgSend(Object, "objectAtIndex:", .{@as(UInteger, i)});
        try std.testing.expectEqual(expected, item.msgSend(i64, "longLongValue", .{}));
    }
}

test "a block kept by Foundation outlives the stack block, and holds its objects" {
    const Run = objc.Block(struct { label: Object, seen: *UInteger }, fn () void);

    var seen: UInteger = 0;
    const operation = blk: {
        const pool = objc.AutoreleasePool.init();
        defer pool.deinit();

        const label = class("NSMutableString").msgSend(Object, "stringWithUTF8String:", .{"kept".ptr});
        var block = Run.init(.{ .label = label, .seen = &seen }, struct {
            fn body(captures: *const Run.Captures) void {
                captures.seen.* = captures.label.msgSend(UInteger, "length", .{});
            }
        }.body);

        // The operation copies the block, and the copy retains `label`.
        const op = class("NSBlockOperation").msgSend(Object, "blockOperationWithBlock:", .{&block});
        break :blk op.retain();
    };
    defer operation.release();

    // The pool that owned `label`, and the frame that held the stack
    // block, are both gone.
    operation.msgSend(void, "start", .{});
    try std.testing.expectEqual(@as(UInteger, 4), seen);
}

// -- defining a class ----------------------------------------------------

const Counter = struct {
    object: Object,

    var class_: ?objc.Class = null;

    /// Defined once per process; classes cannot be defined twice.
    fn define() !objc.Class {
        if (class_) |existing| return existing;

        const cls = try objc.allocateClassPair(class("NSObject"), "MacZigTestCounter");
        try cls.addIvar(Integer, "count");
        try cls.addIvar(State, "state");
        try cls.addMethod("increment", increment);
        try cls.addMethod("add:", add);
        try cls.addMethod("count", count);
        try cls.addMethod("isZero", isZero);
        try cls.addMethod("description", description);
        try cls.addMethod("each:", each);
        try cls.metaclass().addMethod("counterStartingAt:", startingAt);
        try cls.addProtocol(objc.getProtocol("NSCopying").?);
        objc.registerClassPair(cls);

        class_ = cls;
        return cls;
    }

    /// An ordinary Zig struct, kept in an instance variable. The runtime
    /// zero-fills it, so zero is the starting state.
    const State = struct {
        calls: u32,
        last: Integer,
    };

    fn state(self: Counter) *State {
        return self.object.ivar(State, "state").?;
    }

    fn increment(self: Counter, _: Sel) void {
        self.object.ivar(Integer, "count").?.* += 1;
        self.state().calls += 1;
    }

    fn add(self: Counter, _: Sel, amount: Integer) Integer {
        const value = self.object.ivar(Integer, "count").?;
        value.* += amount;
        self.state().calls += 1;
        self.state().last = amount;
        return value.*;
    }

    fn count(self: Counter, _: Sel) Integer {
        return self.object.ivar(Integer, "count").?.*;
    }

    fn isZero(self: Counter, cmd: Sel) bool {
        return count(self, cmd) == 0;
    }

    fn description(self: Counter, _: Sel) Object {
        // [super description] is "<MacZigTestCounter: 0x...>"; keep only the class.
        const inherited = self.object.msgSendSuper(class("NSObject"), Object, "description", .{});
        const upto = inherited.msgSend(objc.Range, "rangeOfString:", .{string(":")});
        return inherited.msgSend(Object, "substringToIndex:", .{upto.location});
    }

    /// Calls `visit` with 0, 1, ... count-1 -- a block handed in from outside.
    fn each(self: Counter, cmd: Sel, visit: objc.BlockRef(fn (Integer) void)) void {
        var i: Integer = 0;
        while (i < count(self, cmd)) : (i += 1) visit.call(.{i});
    }

    fn startingAt(cls: objc.Class, _: Sel, start: Integer) Counter {
        const counter = cls.msgSend(Counter, "new", .{});
        counter.object.ivar(Integer, "count").?.* = start;
        return counter.object.autorelease().as(Counter);
    }
};

test "a class defined in Zig" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const cls = try Counter.define();
    try std.testing.expect(cls.isSubclassOf(class("NSObject")));
    try std.testing.expect(cls.conformsTo(objc.getProtocol("NSCopying").?));

    const counter = cls.msgSend(Counter, "new", .{});
    defer counter.object.release();

    try std.testing.expect(counter.object.msgSend(bool, "isZero", .{}));
    counter.object.msgSend(void, "increment", .{});
    counter.object.msgSend(void, "increment", .{});
    try std.testing.expectEqual(@as(Integer, 12), counter.object.msgSend(Integer, "add:", .{@as(Integer, 10)}));
    try std.testing.expectEqual(@as(Integer, 12), counter.object.msgSend(Integer, "count", .{}));
    try std.testing.expect(!counter.object.msgSend(bool, "isZero", .{}));

    try std.testing.expectEqual(@as(u32, 3), counter.state().calls);
    try std.testing.expectEqual(@as(Integer, 10), counter.state().last);
}

test "a class method, and the runtime's view of the encodings" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const cls = try Counter.define();
    const counter = cls.msgSend(Counter, "counterStartingAt:", .{@as(Integer, 5)});
    try std.testing.expectEqual(@as(Integer, 5), counter.object.msgSend(Integer, "count", .{}));

    try std.testing.expectEqualStrings("q@:q", cls.methodEncoding("add:").?);
    try std.testing.expectEqualStrings("v@:@?", cls.methodEncoding("each:").?);
}

test "an override that calls super" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const counter = (try Counter.define()).msgSend(Object, "new", .{});
    defer counter.release();

    const text = try counter.description(std.testing.allocator);
    defer std.testing.allocator.free(text);
    try std.testing.expectEqualStrings("<MacZigTestCounter", text);
}

test "a Zig block handed to a Zig method, through Objective-C" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const counter = (try Counter.define()).msgSend(Counter, "counterStartingAt:", .{@as(Integer, 4)});

    const Sum = objc.Block(struct { total: *Integer }, fn (Integer) void);
    var total: Integer = 0;
    var block = Sum.init(.{ .total = &total }, struct {
        fn body(captures: *const Sum.Captures, i: Integer) void {
            captures.total.* += i;
        }
    }.body);
    counter.object.msgSend(void, "each:", .{&block});

    try std.testing.expectEqual(@as(Integer, 0 + 1 + 2 + 3), total);
}

test "a class name can only be taken once" {
    _ = try Counter.define();
    try std.testing.expectError(
        error.Failed,
        objc.allocateClassPair(class("NSObject"), "MacZigTestCounter"),
    );
}

// -- exceptions ----------------------------------------------------------

test "an exception becomes an error, and can be inspected" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const empty = class("NSArray").msgSend(Object, "array", .{});
    var caught: objc.Exception = undefined;
    try std.testing.expectError(
        error.ObjcException,
        empty.tryMsgSend(Object, "objectAtIndex:", .{@as(UInteger, 3)}, &caught),
    );
    defer caught.deinit();

    const name = try caught.name(std.testing.allocator);
    defer std.testing.allocator.free(name);
    try std.testing.expectEqualStrings("NSRangeException", name);

    const reason = try caught.reason(std.testing.allocator);
    defer std.testing.allocator.free(reason);
    try std.testing.expect(std.mem.indexOf(u8, reason, "3") != null);
}

test "an unrecognised selector is an error, not a crash" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    try std.testing.expectError(
        error.ObjcException,
        string("x").tryMsgSend(void, objc.sel("noSuchMethodAnywhere"), .{}, null),
    );
    // And the happy path still answers.
    try std.testing.expectEqual(@as(UInteger, 1), try string("x").tryMsgSend(UInteger, "length", .{}, null));
}

test "tryCall catches across several messages, and passes results through" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const Steps = struct {
        fn lastTwo(array: Object) i64 {
            const n = array.msgSend(UInteger, "count", .{});
            const a = array.msgSend(Object, "objectAtIndex:", .{n - 1});
            const b = array.msgSend(Object, "objectAtIndex:", .{n -% 2});
            return a.msgSend(i64, "longLongValue", .{}) + b.msgSend(i64, "longLongValue", .{});
        }
    };

    const values = [_]Object{ number(5), number(7) };
    const pair = class("NSArray").msgSend(Object, "arrayWithObjects:count:", .{
        @as([*]const Object, &values),
        @as(UInteger, 2),
    });
    try std.testing.expectEqual(@as(i64, 12), try objc.tryCall(Steps.lastTwo, .{pair}, null));

    const single = class("NSArray").msgSend(Object, "arrayWithObject:", .{number(1)});
    try std.testing.expectError(error.ObjcException, objc.tryCall(Steps.lastTwo, .{single}, null));
}

test "an exception thrown through a method implemented in Zig" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    // Counter's `each:` calls back into a block; this block throws.
    const counter = (try Counter.define()).msgSend(Counter, "counterStartingAt:", .{@as(Integer, 2)});
    const Throw = objc.Block(struct {}, fn (Integer) void);
    var block = Throw.init(.{}, struct {
        fn body(_: *const Throw.Captures, _: Integer) void {
            _ = class("NSArray").msgSend(Object, "array", .{}).msgSend(Object, "objectAtIndex:", .{@as(UInteger, 0)});
        }
    }.body);

    var caught: objc.Exception = undefined;
    try std.testing.expectError(error.ObjcException, counter.object.tryMsgSend(void, "each:", .{&block}, &caught));
    defer caught.deinit();

    var buffer: [256]u8 = undefined;
    const text = try std.fmt.bufPrint(&buffer, "{f}", .{caught});
    try std.testing.expect(std.mem.startsWith(u8, text, "NSRangeException: "));
}

// -- Subclass ------------------------------------------------------------

var tally_deinits: usize = 0;

const Tally = objc.Subclass(.{ .name = "MacZigTestTally", .protocols = &.{"NSCopying"} }, struct {
    total: Integer = 0,
    label: [8]u8 = "untitled".*,
    history: std.ArrayList(Integer) = .empty,

    const Self = @This();

    pub fn increment(self: *Self) void {
        self.total += 1;
    }

    pub fn @"add:"(self: *Self, amount: Integer) Integer {
        self.total += amount;
        self.history.append(std.testing.allocator, amount) catch @panic("out of memory");
        return self.total;
    }

    /// A getter cannot share its field's name -- Zig allows one or the
    /// other -- so the field is `total` and the method is `count`.
    pub fn count(self: *const Self) Integer {
        return self.total;
    }

    /// Takes the typed wrapper instead of the state.
    pub fn doubled(self: Tally) Integer {
        return self.msgSend(Integer, "count", .{}) * 2;
    }

    /// NSCopying, so the protocol is not a lie.
    pub fn @"copyWithZone:"(self: Tally, _: ?*anyopaque) Object {
        const copy = Tally.new();
        copy.state().total = self.state().total;
        return copy.object;
    }

    /// A class method.
    pub fn @"tallyWithCount:"(_: objc.Class, start: Integer) Tally {
        const tally = Tally.new();
        tally.state().total = start;
        return tally.autorelease();
    }

    /// Not a method: no receiver.
    pub fn helper(x: Integer) Integer {
        return x + 1;
    }

    pub fn deinit(self: *Self) void {
        self.history.deinit(std.testing.allocator);
        tally_deinits += 1;
    }
});

test "Subclass: defaults, methods, and state" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    const tally = Tally.new();
    defer tally.release();

    // Defaults applied at allocation, not zeroes.
    try std.testing.expectEqualStrings("untitled", &tally.state().label);
    try std.testing.expectEqual(@as(Integer, 0), tally.state().total);

    tally.msgSend(void, "increment", .{});
    try std.testing.expectEqual(@as(Integer, 6), tally.msgSend(Integer, "add:", .{@as(Integer, 5)}));
    try std.testing.expectEqual(@as(Integer, 6), tally.msgSend(Integer, "count", .{}));
    try std.testing.expectEqual(@as(Integer, 12), tally.msgSend(Integer, "doubled", .{}));
    try std.testing.expectEqualSlices(Integer, &.{5}, tally.state().history.items);

    try std.testing.expect(Tally.fromState(tally.state()).object.value == tally.object.value);
    try std.testing.expect(!Tally.class().respondsTo("helper"));
    try std.testing.expect(Tally.class().conformsTo(objc.getProtocol("NSCopying").?));
}

test "Subclass: registered once, class methods, and Foundation calling in" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    try std.testing.expect(Tally.class().value == Tally.class().value);

    const tally = Tally.class().msgSend(Tally, "tallyWithCount:", .{@as(Integer, 4)});
    try std.testing.expectEqual(@as(Integer, 4), tally.state().total);

    // -copy goes through NSObject, which calls our copyWithZone:.
    const copy = tally.msgSend(Tally, "copy", .{});
    defer copy.release();
    try std.testing.expectEqual(@as(Integer, 4), copy.state().total);
    try std.testing.expect(copy.object.value != tally.object.value);
}

test "Subclass: deinit runs when the instance is freed" {
    const before = tally_deinits;
    {
        const tally = Tally.new();
        _ = tally.msgSend(Integer, "add:", .{@as(Integer, 1)});
        tally.release();
    }
    try std.testing.expectEqual(before + 1, tally_deinits);
}

const Loud = objc.Subclass(.{ .name = "MacZigTestLoudTally", .superclass = "MacZigTestTally" }, struct {
    volume: u8 = 11,

    pub fn increment(self: Loud) void {
        // [super increment], then again.
        self.object.msgSendSuper(Tally.class(), void, "increment", .{});
        self.object.msgSendSuper(Tally.class(), void, "increment", .{});
    }
});

test "Subclass: a subclass of a subclass keeps both states" {
    const pool = objc.AutoreleasePool.init();
    defer pool.deinit();

    _ = Tally.class(); // the superclass has to exist first
    const loud = Loud.new();
    defer loud.release();

    try std.testing.expectEqual(@as(u8, 11), loud.state().volume);
    const as_tally = loud.object.as(Tally);
    try std.testing.expectEqualStrings("untitled", &as_tally.state().label);

    loud.msgSend(void, "increment", .{});
    try std.testing.expectEqual(@as(Integer, 2), as_tally.state().total);
}
