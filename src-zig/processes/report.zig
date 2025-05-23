const hal = @import("../hal.zig").hal;
const events = @import("../events.zig");
const EventQueue = events.EventQueue;
const config = @import("config");

var report = Report{
    .gas_temp = 0,
    .amp_temp = 0,
    .fan_speed = 0,
    .pcm_temps = undefined,
};

pub fn send_report(queue: *EventQueue) void {
    const time = hal.get_time();

    //Manually format the report as JSON
    hal.print("!!report {\"gas_temp\": ");
    hal.print_f32(report.gas_temp);
    hal.print(", \"amp_temp\": ");
    hal.print_f32(report.amp_temp);
    hal.print(", \"fan_speed\": ");
    hal.print_u64(report.fan_speed);
    hal.print(", \"timestamp_us\": ");
    hal.print_u64(time);
    hal.print(", \"pcm_temps\": [");

    for (report.pcm_temps, 0..) |temp, i| {
        hal.print_f32(temp);
        if (i != 11) {
            hal.print(", ");
        }
    }

    hal.print("] }\n");

    events.add_after_delay(queue, send_report, 1000 * 1000);
}

pub fn add_data(item: ReportItem) void {
    switch (item) {
        .gas_temp => |temp| report.gas_temp = temp,
        .amp_temp => |temp| report.amp_temp = temp,
        .fan_speed => |speed| report.fan_speed = speed,
        .pcm_temps => |temps| report.pcm_temps = temps,
    }
}

pub const ReportItem = union(enum) {
    gas_temp: f32,
    amp_temp: f32,
    fan_speed: u16,
    pcm_temps: [12]f32,
};

pub const Report = struct {
    gas_temp: f32,
    amp_temp: f32,
    pcm_temps: [12]f32,
    fan_speed: u16,
};
