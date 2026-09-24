//! Classes: looking them up, sending them messages, and defining new ones
//! from Zig.

const std = @import("std");
const raw = @import("mac_raw");
const abi = @import("abi.zig");
const message = @import("message.zig");
const exception = @import("exception.zig");
const encoding = @import("encoding.zig");
const sel = @import("sel.zig");
const errors = @import("../errors.zig");

const Error = errors.Error;
const Object = @import("object.zig").Object;
const Sel = sel.Sel;
const Protocol = @import("protocol.zig").Protocol;

/// A class, such as `NSString` or one defined with `allocateClassPair`.
/// Classes are objects too, and `msgSend` on a `Class` is how the class
/// methods -- `alloc`, `new`, `stringWithUTF8String:` -- are reached.
pub const Class = extern struct {
    value: *raw.struct_objc_class,

    pub fn fromRaw(value: raw.Class) ?Class {
        return .{ .value = value orelse return null };
    }

    pub inline fn toRaw(self: Class) raw.Class {
        return self.value;
    }

    /// Sends a class message. See `Object.msgSend`.
    pub inline fn msgSend(
        self: Class,
        comptime Return: type,
        selector: anytype,
        args: anytype,
    ) Return {
        return message.send(self.value, Return, selector, args);
    }

    /// Sends a class message, catching an Objective-C exception. See
    /// `Object.tryMsgSend`.
    pub inline fn tryMsgSend(
        self: Class,
        comptime Return: type,
        selector: anytype,
        args: anytype,
        caught: ?*exception.Exception,
    ) Error!Return {
        return self.asObject().tryMsgSend(Return, selector, args, caught);
    }

    /// The class as an object, for the calls that take one.
    pub fn asObject(self: Class) Object {
        return .{ .value = self.value };
    }

    /// The name, borrowed from the runtime.
    pub fn name(self: Class) [:0]const u8 {
        return std.mem.span(raw.class_getName(self.value));
    }

    /// Null for a root class, like `NSObject`.
    pub fn superclass(self: Class) ?Class {
        return .fromRaw(raw.class_getSuperclass(self.value));
    }

    /// The class of this class: where its class methods live. Add a class
    /// method by adding it to the metaclass.
    pub fn metaclass(self: Class) Class {
        return .{ .value = abi.object_getClass(self.value).? };
    }

    pub fn isMetaclass(self: Class) bool {
        return abi.fromAbi(bool, raw.class_isMetaClass(self.value));
    }

    /// True when this is `other` or inherits from it.
    pub fn isSubclassOf(self: Class, other: Class) bool {
        var current: ?Class = self;
        while (current) |class| : (current = class.superclass()) {
            if (class.value == other.value) return true;
        }
        return false;
    }

    /// True when instances respond to `selector`. This asks the class, so
    /// it works before any instance exists.
    pub inline fn respondsTo(self: Class, selector: anytype) bool {
        return abi.fromAbi(bool, raw.class_respondsToSelector(self.value, sel.from(selector).value));
    }

    /// True when this class, or a superclass, adopts `protocol`.
    pub fn conformsTo(self: Class, protocol: Protocol) bool {
        var current: ?Class = self;
        while (current) |class| : (current = class.superclass()) {
            if (abi.fromAbi(bool, raw.class_conformsToProtocol(class.value, protocol.value))) return true;
        }
        return false;
    }

    /// The size in bytes of an instance.
    pub fn instanceSize(self: Class) usize {
        return raw.class_getInstanceSize(self.value);
    }

    /// The type encoding of the instance method `selector`, or null when
    /// instances do not implement it. Borrowed from the runtime.
    pub inline fn methodEncoding(self: Class, selector: anytype) ?[:0]const u8 {
        const method = raw.class_getInstanceMethod(self.value, sel.from(selector).value) orelse
            return null;
        return std.mem.span(raw.method_getTypeEncoding(method));
    }

    // -- defining ------------------------------------------------------

    /// Adds an instance method. Fails when this class already implements
    /// `selector` itself; overriding a superclass's method is fine.
    ///
    /// `imp` is an ordinary Zig function shaped like the method, with the
    /// receiver and the selector first:
    ///
    /// ```zig
    /// fn add(self: objc.Object, _: objc.Sel, amount: objc.Integer) objc.Integer { ... }
    /// try class.addMethod("add:", add);
    /// ```
    ///
    /// The receiver may be an `Object` or a wrapper of one; the other
    /// parameters and the result may be any type `msgSend` takes. A C
    /// trampoline converting to and from those types is generated, along
    /// with the method's type encoding. A string selector is checked
    /// against the function's parameter count.
    ///
    /// `imp` may not return a Zig error: there is nowhere in Objective-C
    /// for one to go. Handle it inside.
    pub inline fn addMethod(self: Class, selector: anytype, comptime imp: anytype) Error!void {
        const s = resolveFor(selector, imp);
        const added = raw.class_addMethod(
            self.value,
            s.value,
            @ptrCast(abi.adapt(imp)),
            encoding.method(@TypeOf(imp)),
        );
        if (!abi.fromAbi(bool, added)) return Error.Failed;
    }

    /// Sets the implementation of `selector`, adding the method if it is
    /// not there and replacing it if it is. This is `addMethod` without
    /// the failure, for when replacing is the point.
    pub inline fn replaceMethod(self: Class, selector: anytype, comptime imp: anytype) void {
        const s = resolveFor(selector, imp);
        _ = raw.class_replaceMethod(
            self.value,
            s.value,
            @ptrCast(abi.adapt(imp)),
            encoding.method(@TypeOf(imp)),
        );
    }

    /// Declares an instance variable of type `T`. Only possible between
    /// `allocateClassPair` and `registerClassPair` -- the layout of an
    /// instance is fixed when the class is registered.
    ///
    /// `T` may be anything, including an ordinary Zig struct; it is laid
    /// out with its own size and alignment. Reach it with `Object.ivar`.
    ///
    /// A new instance's variables are zero-filled by the runtime, and a
    /// struct's default field values are *not* applied. Make zero the
    /// starting state, or set the variable in an `init` override.
    pub fn addIvar(self: Class, comptime T: type, ivar_name: [:0]const u8) Error!void {
        const added = raw.class_addIvar(
            self.value,
            ivar_name.ptr,
            @sizeOf(T),
            std.math.log2_int(usize, @alignOf(T)),
            encoding.encode(T),
        );
        if (!abi.fromAbi(bool, added)) return Error.Failed;
    }

    /// Declares that this class adopts `protocol`. Fails when it already
    /// does. The methods themselves still have to be added.
    pub fn addProtocol(self: Class, protocol: Protocol) Error!void {
        if (!abi.fromAbi(bool, raw.class_addProtocol(self.value, protocol.value))) return Error.Failed;
    }
};

inline fn resolveFor(selector: anytype, comptime imp: anytype) Sel {
    const F = @TypeOf(imp);
    const params = @typeInfo(F).@"fn".param_types;
    if (params.len < 2 or params[1] != Sel) @compileError(
        "a method implementation takes the receiver and an objc.Sel first; found " ++ @typeName(F),
    );
    if (@TypeOf(selector) == Sel) {
        return selector;
    } else {
        comptime sel.checkArity(selector, params.len - 2, "the implementation");
        return Sel.cached(selector);
    }
}

/// The class called `name`, or null when nothing loaded defines it.
/// AppKit's classes, for one, are only here when AppKit is linked.
pub fn getClass(name: [:0]const u8) ?Class {
    return .fromRaw(raw.objc_getClass(name.ptr));
}

/// Starts defining a class called `name`, inheriting from `superclass`
/// (null makes a new root class, which is almost never wanted -- pass
/// `NSObject`). Add methods and instance variables, then
/// `registerClassPair` before making an instance.
///
/// Fails when a class called `name` already exists. Class names are
/// process-wide, so pick a prefix that will not collide.
pub fn allocateClassPair(superclass: ?Class, name: [:0]const u8) Error!Class {
    const parent: raw.Class = if (superclass) |class| class.value else null;
    return Class.fromRaw(raw.objc_allocateClassPair(parent, name.ptr, 0)) orelse Error.Failed;
}

/// Finishes defining `class`. Its instance variables are fixed from here
/// on; methods can still be added.
pub fn registerClassPair(class: Class) void {
    raw.objc_registerClassPair(class.value);
}

/// Destroys a class made with `allocateClassPair`. Not safe while an
/// instance of it, or a subclass of it, still exists.
pub fn disposeClassPair(class: Class) void {
    raw.objc_disposeClassPair(class.value);
}

test "looking up a class" {
    const string = getClass("NSString").?;
    try std.testing.expectEqualStrings("NSString", string.name());
    try std.testing.expect(string.isSubclassOf(getClass("NSObject").?));
    try std.testing.expect(!string.isMetaclass());
    try std.testing.expect(string.metaclass().isMetaclass());
    try std.testing.expect(getClass("NSObject").?.superclass() == null);
    try std.testing.expect(getClass("NoSuchClassAnywhere") == null);
}

test "a class answers for its instances" {
    const object = getClass("NSObject").?;
    try std.testing.expect(object.respondsTo("description"));
    try std.testing.expect(!object.respondsTo("noSuchMethod"));
    try std.testing.expect(getClass("NSString").?.conformsTo(
        @import("protocol.zig").getProtocol("NSCopying").?,
    ));
}
