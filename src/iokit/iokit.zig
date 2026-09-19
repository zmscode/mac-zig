//! [IOKit](https://developer.apple.com/documentation/iokit), the interface
//! to the device tree -- reached as `mac.iokit`, under `-Diokit`.
//!
//! IOKit is very large and most of it is about driver matching. What is
//! wrapped here is the part that answers questions about the machine:
//!
//! - `power` -- battery charge, mains or battery, time remaining.
//!
//! The rest is reachable through `mac.raw`, though note that only the
//! power-source headers are pulled into the translation unit, so the
//! device-registry calls are not there either. Adding them is a line in
//! `vendor/mac_translate.h`.

/// True when the package was built with `-Diokit` (the default).
pub const enabled = true;

pub const power = @import("power.zig");

test {
    _ = power;
}
