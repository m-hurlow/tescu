const hal = @import("../hal.zig").hal;
const events = @import("../events.zig");
const EventQueue = events.EventQueue;

var fan_speed: u16 = 0;
var desired_temp: f32 = 400;
const K = 2;

pub fn fan_control(queue: *EventQueue) void {
    const current_temp = hal.read_thermocouple(0);
    const err = current_temp - desired_temp;
    const accel = err * K;
    fan_speed += @intFromFloat(accel);
    hal.print("Current fan speed: ");
    hal.print_u64(fan_speed);
    hal.print("\n");
    hal.set_fan_speed(fan_speed);
    events.add_after_delay(queue, fan_control, 20 * 1000);
}
