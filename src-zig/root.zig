const std = @import("std");

const config = @import("config");

const hal = if (config.pico) @cImport({
    @cInclude("hal.h");
}) else @import("hal.zig");

pub export fn main_loop() void {
    while (true) {
        hal.set_led(true);
        hal.sleep(1000);
        hal.set_led(false);
        hal.sleep(1000);
    }
}
