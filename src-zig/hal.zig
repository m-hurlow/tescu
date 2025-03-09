const config = @import("config");

//Import a different HAL library whether we are on desktop or the Pico.
pub const hal = if (config.pico) @cImport({
    @cInclude("hal.h");
}) else @import("hal_impl.zig");
