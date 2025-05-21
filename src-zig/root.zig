const std = @import("std");
const config = @import("config");

const events = @import("events.zig");
const EventQueue = events.EventQueue;
const Event = events.Event;

const hal = @import("hal.zig").hal;

const processes = @import("processes/root.zig");

pub export fn mainLoop() void {
    var buffer: [8192]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const alloc = fba.allocator();

    var queue = EventQueue.init(alloc, {});
    defer queue.deinit();

    hal.init(&queue);

    //Add our starter events
    events.add_after_delay(&queue, processes.utility.ledOn, 0);
    // events.add_after_delay(&queue, processes.utility.read_outlet_temp, 1000 * 1000);
    events.add_after_delay(&queue, processes.fan_control, 1000 * 1000);
    events.add_after_delay(&queue, processes.report.send_report, 5000 * 1000);

    while (true) {
        //The code is event-driven; if there are no events in the queue,
        //none will ever be added and we have a deadlock.
        const next_event = queue.removeOrNull() orelse {
            hal.print("FATAL: empty queue!\n");
            while (true) {}
        };
        const current_time = hal.get_time();
        //Sleep until the next event is ready.
        if (next_event.time > current_time) {
            const dt = next_event.time - current_time;
            hal.sleep(dt);
        }

        //We should now be at the right time, so run the event.
        const callback: *const fn (queue: *EventQueue) void = @alignCast(@ptrCast(next_event.callback));
        callback(&queue);
    }
}
