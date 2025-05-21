const hal = @import("../hal.zig").hal;
const events = @import("../events.zig");
const EventQueue = events.EventQueue;

pub fn ledOn(queue: *EventQueue) void {
    hal.set_led(true);
    events.add_after_delay(queue, ledOff, 500 * 1000);
}

pub fn ledOff(queue: *EventQueue) void {
    hal.set_led(false);
    events.add_after_delay(queue, ledOn, 500 * 1000);
}

pub fn read_outlet_temp(queue: *EventQueue) void {
    const temp = hal.read_thermocouple(0);
    hal.print("Outlet temp: ");
    hal.print_u64(@intFromFloat(temp));
    hal.print("\n");
    events.add_after_delay(queue, read_outlet_temp, 1000 * 1000);
}
