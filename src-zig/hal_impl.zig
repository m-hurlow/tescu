const std = @import("std");

pub fn sleep(time: u64) void {
    std.Thread.sleep(time * 1000);
}

pub fn set_led(state: bool) void {
    std.debug.print("led {s}\n", .{if (state) "on" else "off"});
}

pub fn print(comptime msg: []const u8) void {
    std.debug.print(msg, .{});
}

pub fn print_u64(val: u64) void {
    std.debug.print("{}", .{val});
}

pub fn get_time() u64 {
    return @intCast(std.time.timestamp());
}
