const hal = @import("../hal.zig").hal;
const events = @import("../events.zig");
const EventQueue = events.EventQueue;

var setpoint: u16 = 0;

pub fn fan_control(queue: *EventQueue) void {
    setpoint += 1;
    hal.print("Current fan setpoint: ");
    hal.print_u64(setpoint);
    hal.print("\n");
    hal.set_fan_speed(setpoint);
    events.add_after_delay(queue, fan_control, 20 * 1000);
}
