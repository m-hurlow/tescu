const std = @import("std");
const hal = @import("hal.zig").hal;

pub const EventQueue = std.PriorityQueue(Event, void, compEvent);

//Events are represented using a time and a callback function that is run at that time.
pub const Event = struct {
    time: u64,
    //Events may (will!) add other events to the queue.
    //To avoid compiler errors, this is an anonymous pointer that is cast to the
    //correct function pointer type when used. For reference, this should be
    //*const fn (queue: *EventQueue) void
    callback: *const anyopaque,
};

pub fn compEvent(context: void, a: Event, b: Event) std.math.Order {
    _ = context;
    return std.math.order(a.time, b.time);
}

pub fn add_after_delay(queue: *EventQueue, callback: *const fn (queue: *EventQueue) void, delay_us: u64) void {
    const new_event = Event{
        .time = hal.get_time() + delay_us,
        .callback = callback,
    };
    queue.add(new_event) catch {};
}
