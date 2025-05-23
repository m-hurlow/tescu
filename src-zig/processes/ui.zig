const std = @import("std");
const hal = @import("../hal.zig").hal;
const events = @import("../events.zig");
const EventQueue = events.EventQueue;
const fan_control = @import("fan_control.zig");

var buf: [100]u8 = undefined;
var buf_pos: usize = 0;

pub fn ui(queue: *EventQueue) void {
    var char = hal.get_char();
    while (char != -2) {
        buf[buf_pos] = @truncate(@as(u32, @bitCast(char)));
        buf_pos += 1;

        if (buf[buf_pos - 1] == '\r') {
            //We have read an entire command at this point
            if (std.mem.eql(u8, "hello", buf[0 .. buf_pos - 1])) {
                hal.print("Hello there!\n");
            } else if (std.mem.startsWith(u8, &buf, "a ")) {
                //Auto fan control toggle
                if (buf[2] == '1') {
                    hal.print("Auto fan control on\n");
                    fan_control.auto = true;
                } else if (buf[2] == '0') {
                    hal.print("Auto fan control off\n");
                    fan_control.auto = false;
                }
            } else if (std.mem.startsWith(u8, &buf, "s ")) {
                //Set fan speed
                //Ignore if auto fan is on
                if (!fan_control.auto) {
                    const val = std.fmt.parseInt(u16, buf[2..7], 10) catch fan_control.fan_speed;
                    fan_control.fan_speed = val;
                }
            } else if (std.mem.eql(u8, "stop", buf[0 .. buf_pos - 1])) {
                hal.print("Stopping\n");
                fan_control.auto = false;
                fan_control.fan_speed = 0;
            }
            buf_pos = 0;
            break;
        } else {
            char = hal.get_char();
        }
    }

    events.add_after_delay(queue, ui, 100 * 1000);
}
