const hal = @import("../hal.zig").hal;
const events = @import("../events.zig");
const EventQueue = events.EventQueue;
const fan_control = @import("fan_control.zig").fan_control;

pub fn ui(queue: *EventQueue) void {
    switch (hal.get_char()) {
        0x73 => {
            events.add_after_delay(queue, fan_control, 0);
        },
        else => {},
    }

    events.add_after_delay(queue, ui, 100 * 1000);
}
