const std = @import("std");

const events = @import("events.zig");
const EventQueue = events.EventQueue;
const Event = events.Event;

const hal = @import("hal.zig").hal;

fn ledOn(queue: *EventQueue) void {
    hal.set_led(true);
    events.add_after_delay(queue, ledOff, 1000 * 1000);
}

fn ledOff(queue: *EventQueue) void {
    hal.set_led(false);
    events.add_after_delay(queue, ledOn, 1000 * 1000);
}

pub export fn mainLoop() void {
    var buffer: [4096]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const alloc = fba.allocator();

    var queue = EventQueue.init(alloc, {});
    defer queue.deinit();

    //Add our starter event
    const starter = Event{
        .time = hal.get_time(),
        .callback = ledOn,
    };
    queue.add(starter) catch {};

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
