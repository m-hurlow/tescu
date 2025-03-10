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
    return @intCast(std.time.microTimestamp());
}

const SIM_STATE = struct {
    const exhaust_temp: f32 = 600.0;
    const exhaust_mass_flow: f32 = 0.003;
    const air_temp: f32 = 300.0;
    var air_speed: f32 = 1.0;
};

pub fn read_thermocouple(thermocouple: u8) f32 {
    switch (thermocouple) {
        0 => {
            const air_mass_flow = 100000.0 / (287 * SIM_STATE.air_temp) * SIM_STATE.air_speed * 0.25 * std.math.pi * 0.075 * 0.075;
            const output_temp = (air_mass_flow * SIM_STATE.air_temp + SIM_STATE.exhaust_mass_flow * SIM_STATE.exhaust_temp) / (air_mass_flow + SIM_STATE.exhaust_mass_flow);
            return output_temp;
        },
        else => std.debug.print("Unknown thermocouple {}", .{thermocouple}),
    }
    return 0.0;
}
