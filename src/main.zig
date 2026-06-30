const bclk = @import("bclk");

const std = @import("std");
const rl = @import("raylib");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const screen_width = 450;
    const screen_height = 450;

    rl.initWindow(screen_width, screen_height, "Zig Binary Clock");
    defer rl.closeWindow(); // Ensures window closes on exit

    rl.setTargetFPS(60);


    // Main game loop
    while (!rl.windowShouldClose()) {
        // TODO: Get current time and convert to binary
        const timestamp = std.Io.Clock.real.now(io);
        std.debug.print("Current Time: {d}\n", .{timestamp});

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        rl.drawText("Hello, Zig!", 190, 200, 20, rl.Color.light_gray);
    }
}
