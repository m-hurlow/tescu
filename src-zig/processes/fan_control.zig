const std = @import("std");
const hal = @import("../hal.zig").hal;
const events = @import("../events.zig");
const EventQueue = events.EventQueue;
const utility = @import("utility.zig");

const report = @import("report.zig");

var fan_speed: u16 = 0;
var desired_temp: f32 = 400;

const K = 2;
const MIN_SPEED = 100;

pub fn fan_control(queue: *EventQueue) void {
    const tc_data = hal.read_thermocouple(0);
    const current_temp = utility.get_tc_temp(&tc_data);
    const err = current_temp - desired_temp;
    const accel = err * K;

    const desired_fan_speed = @as(f32, @floatFromInt(fan_speed)) + accel;
    fan_speed = @intFromFloat(std.math.clamp(desired_fan_speed, MIN_SPEED, std.math.maxInt(u16)));

    report.add_data(report.ReportItem{ .gas_temp = current_temp });
    report.add_data(report.ReportItem{ .fan_speed = fan_speed });

    hal.set_fan_speed(fan_speed);
    events.add_after_delay(queue, fan_control, 20 * 1000);
}
