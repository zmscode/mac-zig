//! Sending a message: the one generic call underneath `Object.msgSend`,
//! `Class.msgSend` and `Object.msgSendSuper`.
//!
//! `objc_msgSend` is not a variadic function, whatever its C declaration
//! suggests. It is a trampoline that finds the method and jumps to it with
//! the argument registers untouched, so it must be called through a
//! pointer of the *method's* exact type -- calling it as a C varargs
//! function passes floats in the wrong registers on arm64. The function
//! type is built here, at compile time, from the argument tuple and the
//! requested return type, and every value is converted with `abi.toAbi`
//! on the way in and `abi.fromAbi` on the way out.

const std = @import("std");
const abi = @import("abi.zig");
const sel = @import("sel.zig");

const Sel = sel.Sel;
const Class = @import("class.zig").Class;

/// The C type of a send taking `Args` and returning `Return`, with the
/// receiver passed as `Receiver`.
fn SendFn(comptime Receiver: type, comptime Return: type, comptime Args: type) type {
    const fields = @typeInfo(Args).@"struct".field_types;
    var params: [fields.len + 2]type = undefined;
    params[0] = Receiver;
    params[1] = abi.Abi(Sel);
    for (fields, params[2..]) |F, *slot| slot.* = abi.Abi(F);
    const final = params;
    return abi.CFn(&final, abi.Abi(Return));
}

fn CArgs(comptime Receiver: type, comptime Args: type) type {
    const fields = @typeInfo(Args).@"struct".field_types;
    var types: [fields.len + 2]type = undefined;
    types[0] = Receiver;
    types[1] = abi.Abi(Sel);
    for (fields, types[2..]) |F, *slot| slot.* = abi.Abi(F);
    const final = types;
    return @Tuple(&final);
}

/// Sends `selector` to `receiver` with `args`, expecting `Return`.
pub inline fn send(
    receiver: abi.Id,
    comptime Return: type,
    selector: anytype,
    args: anytype,
) Return {
    return call(abi.Id, receiver, false, Return, selector, args);
}

/// Sends `selector` to `receiver`, starting the method lookup at
/// `superclass` rather than at the receiver's own class. This is
/// `[super ...]`: pass the superclass of the class whose method is making
/// the call, not the superclass of the receiver's class, or a subclass of
/// yours will recurse forever.
pub inline fn sendSuper(
    receiver: abi.Id,
    superclass: Class,
    comptime Return: type,
    selector: anytype,
    args: anytype,
) Return {
    var target: abi.Super = .{ .receiver = receiver, .super_class = superclass.value };
    return call(*abi.Super, &target, true, Return, selector, args);
}

inline fn call(
    comptime Receiver: type,
    receiver: Receiver,
    comptime to_super: bool,
    comptime Return: type,
    selector: anytype,
    args: anytype,
) Return {
    const Args = @TypeOf(args);
    if (@typeInfo(Args) != .@"struct" or !@typeInfo(Args).@"struct".is_tuple) {
        @compileError("the arguments to a message are a tuple, e.g. .{ a, b }; found " ++
            @typeName(Args));
    }
    const s = sel.resolve(selector, @typeInfo(Args).@"struct".field_types.len);

    const function: *const SendFn(Receiver, Return, Args) = @ptrCast(abi.trampoline(Return, to_super));

    var c_args: CArgs(Receiver, Args) = undefined;
    c_args[0] = receiver;
    c_args[1] = abi.toAbi(Sel, s);
    inline for (@typeInfo(Args).@"struct".field_types, 0..) |F, i| {
        c_args[i + 2] = abi.toAbi(F, args[i]);
    }
    return abi.fromAbi(Return, @call(.auto, function, c_args));
}
