const bclk = @import("bclk");

const std = @import("std");
const rl = @import("raylib");

// Import C time functions for timezone handling
const c = @cImport({
    @cInclude("time.h");
});


pub fn main(init: std.process.Init) !void {
    const io = init.io;

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit(); 
    const allocator = gpa.allocator();

    const screen_width = 450;
    const screen_height = 450;

    rl.initWindow(screen_width, screen_height, "Zig Binary Clock");
    defer rl.closeWindow(); // Ensures window closes on exit

    rl.setTargetFPS(60);


    // Main game loop
    while (!rl.windowShouldClose()) {
        // TODO: Get current time and convert to binary
        const timestamp = std.Io.Clock.real.now(io);
        const seconds = timestamp.toSeconds();

        const c_time: c.time_t = @intCast(seconds);
        const time_info = c.localtime(&c_time);

        const hour = time_info.*.tm_hour;
        const minute = time_info.*.tm_min;
        const second = @mod(seconds, 60);

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        const time_str = try std.fmt.allocPrintSentinel(allocator, "{d:02}:{d:02}:{d:02}", .{
            @as(u8, @intCast(hour)),
            @as(u8, @intCast(minute)),
            @as(u8, @intCast(second)),
        }, 0);
        defer allocator.free(time_str);

        rl.drawText(time_str, 10, 10, 20, rl.Color.white);
    }
}
