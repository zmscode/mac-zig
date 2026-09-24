//! Objects: instances, and the messages sent to them.

const std = @import("std");
const raw = @import("mac_raw");
const abi = @import("abi.zig");
const message = @import("message.zig");
const exception = @import("exception.zig");
const encoding = @import("encoding.zig");
const errors = @import("../errors.zig");
const cf = @import("../cf.zig");

const Error = errors.Error;
const Class = @import("class.zig").Class;
const sel = @import("sel.zig");

/// Any Objective-C object: an `NSString`, an `NSWindow`, an instance of a
/// class defined from Zig.
///
/// ## Ownership
///
/// This is a pointer, not an owner. Objective-C's rule is the same as
/// CoreFoundation's, keyed on the method name: a message whose selector
/// starts with **alloc**, **new**, **copy** or **mutableCopy** hands back
/// an object you own and must `release`. Anything else hands back one you
/// do not, which lives until the enclosing `AutoreleasePool` is drained --
/// `retain` it to keep it longer.
///
/// ## nil
///
/// `Object` is never nil. Ask `msgSend` for `?Object` where a method can
/// answer nil; asking for `Object` asserts that it did not.
///
/// ## Typed wrappers
///
/// Any struct whose only field is an `Object` is treated as one: passed
/// to messages as the bare object, returned from them by wrapping. That is
/// how a program gives an Objective-C class a Zig type of its own:
///
/// ```zig
/// const Window = struct {
///     object: objc.Object,
///
///     pub fn setTitle(self: Window, title: objc.Object) void {
///         self.object.msgSend(void, "setTitle:", .{title});
///     }
/// };
///
/// const window = app.msgSend(Window, "mainWindow", .{});
/// ```
pub const Object = extern struct {
    value: *anyopaque,

    /// There is deliberately no `toRaw`: the translated `id` is an aligned
    /// pointer, and a tagged-pointer object is not aligned. Use `value`
    /// with a function declared to take `?*anyopaque`.
    pub fn fromRaw(value: raw.id) ?Object {
        if (value == null) return null;
        return .{ .value = @ptrCast(value) };
    }

    /// Sends `selector` -- a comptime string like `"initWithFrame:"`, or a
    /// `Sel` -- with the arguments in the tuple `args`, and returns the
    /// answer as `Return`.
    ///
    /// A string selector is checked against the tuple: one argument per
    /// colon, or it does not compile. Integer and float literals must be
    /// given a type, since the method's parameter types are not known
    /// here -- `@as(objc.Integer, 3)`, not `3`.
    ///
    /// Sending a message the receiver does not implement raises an
    /// Objective-C exception, which Zig cannot catch and which ends the
    /// process. Check `respondsTo` first when that is in doubt.
    pub inline fn msgSend(
        self: Object,
        comptime Return: type,
        selector: anytype,
        args: anytype,
    ) Return {
        return message.send(self.value, Return, selector, args);
    }

    /// `msgSend`, with an Objective-C exception turned into
    /// `error.ObjcException` instead of ending the process. When `caught`
    /// is not null the exception is stored there, and is the caller's to
    /// `deinit`.
    ///
    /// ```zig
    /// const item = array.tryMsgSend(objc.Object, "objectAtIndex:", .{index}, null) catch
    ///     return error.OutOfRange;
    /// ```
    pub inline fn tryMsgSend(
        self: Object,
        comptime Return: type,
        selector: anytype,
        args: anytype,
        caught: ?*exception.Exception,
    ) Error!Return {
        const s = sel.resolve(selector, @typeInfo(@TypeOf(args)).@"struct".field_types.len);
        return exception.trySend(self.value, Return, s, args, caught);
    }

    /// `[super selector]`: runs `superclass`'s implementation on this
    /// object. `superclass` is the superclass of the class whose method is
    /// making the call -- write it out, rather than asking the object for
    /// its class's superclass, which is wrong the moment the class is
    /// subclassed.
    pub inline fn msgSendSuper(
        self: Object,
        superclass: Class,
        comptime Return: type,
        selector: anytype,
        args: anytype,
    ) Return {
        return message.sendSuper(self.value, superclass, Return, selector, args);
    }

    /// The value of the property `name`: `[object name]`. For a `BOOL`
    /// property whose getter is renamed, pass the getter -- `"isVisible"`.
    pub inline fn getProperty(self: Object, comptime Return: type, comptime name: [:0]const u8) Return {
        return self.msgSend(Return, name, .{});
    }

    /// Sets the property `name`: `[object setName:value]`. Pass the
    /// property's name, not the setter's -- `"title"`, not `"setTitle:"`.
    pub inline fn setProperty(self: Object, comptime name: [:0]const u8, value: anytype) void {
        self.msgSend(void, comptime setterName(name), .{value});
    }

    /// This object seen as `T`, a wrapper -- a struct whose only field is
    /// an `Object`. Nothing is checked; see `isKindOf`.
    pub fn as(self: Object, comptime T: type) T {
        return abi.wrap(T, self);
    }

    pub fn getClass(self: Object) Class {
        return .{ .value = abi.object_getClass(self.value).? };
    }

    /// The name of this object's class, borrowed from the runtime.
    pub fn className(self: Object) [:0]const u8 {
        return self.getClass().name();
    }

    /// True when this object is an instance of `class` or of a subclass.
    pub fn isKindOf(self: Object, class: Class) bool {
        return self.msgSend(bool, "isKindOfClass:", .{class});
    }

    /// True when this object implements `selector`, which is what to check
    /// before sending a message that might not be understood.
    pub inline fn respondsTo(self: Object, selector: anytype) bool {
        return self.msgSend(bool, "respondsToSelector:", .{sel.from(selector)});
    }

    /// `isEqual:`, which is value equality where the class defines it --
    /// two `NSString`s with the same characters are equal.
    pub fn eql(self: Object, other: Object) bool {
        return self.msgSend(bool, "isEqual:", .{other});
    }

    /// Makes this object yours: it lives until the matching `release`.
    pub fn retain(self: Object) Object {
        return .{ .value = abi.objc_retain(self.value).? };
    }

    /// Gives up a reference that is yours -- from `retain`, or from a
    /// message starting alloc, new, copy or mutableCopy.
    pub fn release(self: Object) void {
        abi.objc_release(self.value);
    }

    /// Hands a reference that is yours to the current `AutoreleasePool`,
    /// which releases it when drained.
    pub fn autorelease(self: Object) Object {
        return .{ .value = abi.objc_autorelease(self.value).? };
    }

    /// A pointer to the instance variable `name`, which must hold a `T`,
    /// or null when the class has no such variable.
    ///
    /// This is how a class defined from Zig keeps its state: declare the
    /// variable with `Class.addIvar` before registering the class, and
    /// read and write it through this pointer. Nothing is retained or
    /// released on the way -- an `Object` stored here is stored as a bare
    /// pointer.
    ///
    /// In safe builds the variable's encoding is checked against `T`.
    pub fn ivar(self: Object, comptime T: type, name: [:0]const u8) ?*T {
        const variable = raw.class_getInstanceVariable(self.getClass().value, name.ptr) orelse
            return null;
        if (std.debug.runtime_safety) {
            const actual = std.mem.span(raw.ivar_getTypeEncoding(variable));
            if (!std.mem.eql(u8, actual, encoding.encode(T))) std.debug.panic(
                "instance variable {s} is encoded \"{s}\", but was read as {s} (\"{s}\")",
                .{ name, actual, @typeName(T), encoding.encode(T) },
            );
        }
        const base: [*]u8 = @ptrCast(self.value);
        return @ptrCast(@alignCast(base + @as(usize, @intCast(raw.ivar_getOffset(variable)))));
    }

    /// A CoreFoundation value as the Objective-C object it is. `CFString`
    /// is `NSString`, `CFArray` is `NSArray`, and so on through the
    /// toll-free bridged types -- the same pointer, and the same reference,
    /// so a `cf` value that is yours to `deinit` becomes one that is yours
    /// to `release`, and not both.
    pub fn fromCf(value: anytype) Object {
        return .{ .value = @ptrCast(@constCast(value.handle)) };
    }

    /// This object as the CoreFoundation type `T` -- `cf.String`,
    /// `cf.Array`, `cf.Number` -- or null when it is something else. The
    /// reference is shared, not copied.
    pub fn asCf(self: Object, comptime T: type) ?T {
        if (raw.CFGetTypeID(self.value) != T.typeId()) return null;
        return .{ .handle = @ptrCast(self.value) };
    }

    /// A UTF-8 copy of `description`, in memory the caller owns. The
    /// intermediate string is autoreleased, so call this inside an
    /// `AutoreleasePool`.
    pub fn description(self: Object, allocator: std.mem.Allocator) ![]u8 {
        const text = self.msgSend(Object, "description", .{});
        const string = text.asCf(cf.String) orelse return Error.Failed;
        return string.toOwnedSlice(allocator);
    }
};

/// `"title"` to `"setTitle:"`.
fn setterName(comptime name: [:0]const u8) [:0]const u8 {
    if (name.len == 0) @compileError("a property needs a name");
    return "set" ++ [_]u8{std.ascii.toUpper(name[0])} ++ name[1..] ++ ":";
}

test "setter names" {
    try std.testing.expectEqualStrings("setTitle:", comptime setterName("title"));
    try std.testing.expectEqualStrings("setX:", comptime setterName("x"));
}
