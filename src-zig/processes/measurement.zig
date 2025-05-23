const hal = @import("../hal.zig").hal;
const events = @import("../events.zig");
const EventQueue = events.EventQueue;
const utility = @import("utility.zig");
const report = @import("report.zig");

//REMEMBER TO CHANGE THIS!
const PCM_TCS: [12]u8 = .{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 };

pub fn measurement(queue: *EventQueue) void {
    //Measure all the PCM thermocouples
    var temps: [12]f32 = undefined;
    for (PCM_TCS, 0..) |tc, i| {
        const tc_data = hal.read_thermocouple(tc);
        const tc_temp = utility.get_tc_temp(&tc_data);
        temps[i] = tc_temp;
    }
    //Report this over serial
    report.add_data(report.ReportItem{ .pcm_temps = temps });

    events.add_after_delay(queue, measurement, 1000 * 1000);
}
