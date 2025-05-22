const std = @import("std");
const rl = @import("raylib");
const events = @import("events.zig");
const EventQueue = events.EventQueue;

const c_hal = @cImport({
    @cInclude("hal.h");
});

pub const TcData = c_hal.TcData;

const HistoryBuffer = struct {
    current: u9,
    buf: [512]f32,

    const Self = @This();

    fn init() Self {
        return .{
            .current = 511,
            .buf = std.mem.zeroes([512]f32),
        };
    }
};

const timestep: u64 = 20;

pub fn init(queue: *EventQueue) void {
    rl.initWindow(320, 240, "TESCU");
    rl.setTargetFPS(60);
    events.add_after_delay(queue, update_sim, 0);
}

pub fn update_sim(queue: *EventQueue) void {
    //Update window
    rl.beginDrawing();
    defer rl.endDrawing();

    if (!rl.windowShouldClose()) {
        events.add_after_delay(queue, update_sim, timestep * 1000);
    } else {
        rl.closeWindow();
        std.process.exit(0);
    }

    //Update sim
    SIM_STATE.history.current = SIM_STATE.history.current +% 1;
    SIM_STATE.history.buf[SIM_STATE.history.current] = SIM_STATE.air_speed;
}

pub fn sleep(time: u64) void {
    std.Thread.sleep(time * 1000);
}

pub fn set_led(state: bool) void {
    std.debug.print("led {s}\n", .{if (state) "on" else "off"});
}

pub fn print(msg: []const u8) void {
    std.io.getStdOut().writeAll(msg) catch {};
}

pub fn print_u64(val: u64) void {
    std.debug.print("{}", .{val});
}

pub fn print_f32(val: f32) void {
    std.debug.print("{d:.6}", .{val});
}

pub fn get_time() u64 {
    return @intCast(std.time.microTimestamp());
}

const SIM_STATE = struct {
    const exhaust_temp: f32 = 600.0;
    const exhaust_mass_flow: f32 = 0.003;
    const air_temp: f32 = 300.0;
    var air_speed: f32 = 1.0;
    var history: HistoryBuffer = HistoryBuffer.init();
};

pub fn read_thermocouple(thermocouple: u8) TcData {
    switch (thermocouple) {
        0 => {
            //Use previous speed values to implement a delay from changing speed to observing a change in temperature
            const prev_vel = SIM_STATE.history.buf[SIM_STATE.history.current -% @as(u9, @intFromFloat(@floor(1.0 / @as(f32, @floatFromInt(timestep)))))];
            const air_mass_flow = 100000.0 / (287 * SIM_STATE.air_temp) * prev_vel * 0.25 * std.math.pi * 0.075 * 0.075;
            const output_temp = (air_mass_flow * SIM_STATE.air_temp + SIM_STATE.exhaust_mass_flow * SIM_STATE.exhaust_temp) / (air_mass_flow + SIM_STATE.exhaust_mass_flow);
            return TcData{ .tc_temp = @intFromFloat(output_temp / 0.25), .int_temp = 400 };
        },
        else => std.debug.print("Unknown thermocouple {}", .{thermocouple}),
    }
    return TcData{};
}

pub fn get_char() i32 {
    const char = rl.getCharPressed();
    return if (char == 0) -2 else char;
}

pub fn set_fan_speed(speed: u16) void {
    //Convert speed (range 0-65535) to an actual m/s speed
    //Simplified model of ESC/motor combo
    const actual_speed = @as(f32, @floatFromInt(speed)) * 1.526e-4;
    SIM_STATE.air_speed = actual_speed;
}
