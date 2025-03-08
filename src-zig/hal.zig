const std = @import("std");

pub fn sleep(time: u32) void {
    std.Thread.sleep(time * 1000 * 1000);
}

pub fn set_led(state: bool) void {
    std.debug.print("led {s}\n", .{if (state) "on" else "off"});
}
