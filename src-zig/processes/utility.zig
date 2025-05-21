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
    const tc_data = hal.read_thermocouple(0);
    hal.print("Outlet temp: ");
    hal.print_f32(get_tc_temp(&tc_data));
    hal.print("\n");
    events.add_after_delay(queue, read_outlet_temp, 1000 * 1000);
}

pub fn get_tc_temp(tc_data: *const hal.TcData) f32 {
    const sext_mask = 1 << 13;
    const sign_extended: i16 = @bitCast((tc_data.tc_temp ^ sext_mask) -% sext_mask);
    return @as(f32, @floatFromInt(sign_extended)) * 0.25;
}
