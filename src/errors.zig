//! CoreGraphics has two failure channels, and this is both of them.
//!
//! Most of the framework reports failure by returning `NULL` and recording
//! nothing at all -- no code, no message, no thread-local slot to read after
//! the fact. `error.Failed` is that channel, and the call site is the only
//! context there will ever be.
//!
//! The corner of the framework that talks to the window server -- displays,
//! display configuration, event taps -- returns a `CGError` code instead.
//! Those are named, and they are worth telling apart: `error.IllegalArgument`
//! from a display call usually means a stale `Display`, while
//! `error.CannotComplete` usually means the user has not granted the
//! permission the call needs.

const std = @import("std");
const raw = @import("mac_raw");

pub const Error = error{
    /// A call that reports failure by returning null did so. Most of
    /// CoreFoundation and CoreGraphics report failure this way and record
    /// no further detail, so the call site is the only context there is.
    Failed,

    // The CGError codes. Everything below comes from a call that returns
    // one, which is a much smaller set of calls than the ones above.
    /// `kCGErrorFailure`. Prefixed so that it does not read as the
    /// null-return case above.
    CgFailure,
    IllegalArgument,
    InvalidConnection,
    InvalidContext,
    CannotComplete,
    NotImplemented,
    RangeCheck,
    TypeCheck,
    InvalidOperation,
    NoneAvailable,
    /// A `CGError` code this binding does not name.
    UnknownCgError,
};

/// Turns a null return into an error union. Every wrapper over a
/// create-or-null call goes through here.
///
/// Note the deliberate split: null that means *failure* becomes an error,
/// while null that means *absent* -- no palette on this surface, no data on
/// this context -- is returned as an optional instead. A `?T` from this
/// binding is a real answer; an error is a failure.
pub inline fn checkPtr(pointer: anytype) Error!@TypeOf(pointer.?) {
    return pointer orelse Error.Failed;
}

/// Turns a `bool` return into an error union, for the handful of calls that
/// report success that way.
pub inline fn check(ok: bool) Error!void {
    if (!ok) return Error.Failed;
}

/// Turns a `CGError` code into an error union.
pub fn checkCode(code: raw.CGError) Error!void {
    return switch (code) {
        raw.kCGErrorSuccess => {},
        raw.kCGErrorFailure => Error.CgFailure,
        raw.kCGErrorIllegalArgument => Error.IllegalArgument,
        raw.kCGErrorInvalidConnection => Error.InvalidConnection,
        raw.kCGErrorInvalidContext => Error.InvalidContext,
        raw.kCGErrorCannotComplete => Error.CannotComplete,
        raw.kCGErrorNotImplemented => Error.NotImplemented,
        raw.kCGErrorRangeCheck => Error.RangeCheck,
        raw.kCGErrorTypeCheck => Error.TypeCheck,
        raw.kCGErrorInvalidOperation => Error.InvalidOperation,
        raw.kCGErrorNoneAvailable => Error.NoneAvailable,
        else => Error.UnknownCgError,
    };
}

test "checkCode maps success and a named code" {
    try checkCode(raw.kCGErrorSuccess);
    try std.testing.expectError(Error.IllegalArgument, checkCode(raw.kCGErrorIllegalArgument));
    try std.testing.expectError(Error.UnknownCgError, checkCode(1234));
}

test "checkPtr turns null into an error and unwraps otherwise" {
    const absent: ?*const u8 = null;
    try std.testing.expectError(Error.Failed, checkPtr(absent));

    const byte: u8 = 7;
    const present: ?*const u8 = &byte;
    try std.testing.expectEqual(@as(u8, 7), (try checkPtr(present)).*);
}
