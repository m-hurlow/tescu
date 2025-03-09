const std = @import("std");
const pico_lib = @import("root.zig");

pub fn main() !void {
    pico_lib.mainLoop();
}
