const bclk = @import("bclk");
const std = @import("std");
const rl = @import("raylib");

// Import C time functions from C time.h
const c = @cImport({
    @cInclude("time.h");
});

const BTime = struct {
    hour: u8,
    minute: u8,
    second: u8,

    fn get(timestamp: std.Io.Timestamp) BTime {
        const seconds = timestamp.toSeconds();
        const c_time: c.time_t = @intCast(seconds);
        const time_info = c.localtime(&c_time);

        return BTime{
            .hour = @as(u8, @intCast(time_info.*.tm_hour)),
            .minute = @as(u8, @intCast(time_info.*.tm_min)),
            .second = @as(u8, @intCast(time_info.*.tm_sec)),
        };
    }

    pub fn format(self: BTime, writer: anytype) !void {
        try writer.print("{d:02}:{d:02}:{d:02}", .{ self.hour, self.minute, self.second });
    }
};

pub fn main(init: std.process.Init) !void {
    const allocator = std.heap.page_allocator;

    const screen_width = 800;
    const screen_height = 800;
    const cell_size: f32 = @floatFromInt(screen_width / 40);
    const spacing: f32 = (cell_size * 2) + cell_size / 2; // Cell size + spacing between cells
    const grid_width = 5.0 * spacing;
    const grid_height = 3.0 * spacing;
    const start_x: f32 = (@as(f32, @floatFromInt(screen_width)) - grid_width) / 2.0;
    const start_y: f32 = (@as(f32, @floatFromInt(screen_height)) - grid_height) / 2.0;

    var update_timer: f32 = 0; // Timer to track when to update the time display
    var timestamp = std.Io.Clock.real.now(init.io);
    var time: BTime = BTime.get(timestamp);
    var time_str = try std.fmt.allocPrintSentinel(allocator, "{f}", .{time}, 0);
    defer allocator.free(time_str);

    rl.initWindow(screen_width, screen_height, "Zig Binary Clock");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    // Main game loop
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        update_timer += rl.getFrameTime();
        if (update_timer >= 1.0) {
            update_timer = 0;

            timestamp = std.Io.Clock.real.now(init.io);
            time = BTime.get(timestamp);

            allocator.free(time_str); // Free the previous time string before allocating a new one
            time_str = try std.fmt.allocPrintSentinel(allocator, "{f}", .{time}, 0);
        }

        const digits = [_]u8{
            time.hour / 10, time.hour % 10, // Col 0 & 1
            time.minute / 10, time.minute % 10, // Col 2 & 3
            time.second / 10, time.second % 10, // Col 4 & 5
        };

        for (digits, 0..) |digit, col| {
            for (0..4) |row| {
                if (col == 0 and row < 2) continue; // Hour tens
                if (col == 2 and row == 0) continue; // Minute tens
                if (col == 4 and row == 0) continue; // Second tens

                const x = start_x + (@as(f32, @floatFromInt(col)) * spacing);
                const y = start_y + (@as(f32, @floatFromInt(row)) * spacing);

                const bit_index: u3 = @intCast(3 - row);
                const active = ((digit >> bit_index) & 1) == 1;

                const color = if (active) rl.Color.ray_white else rl.Color.ray_white.alpha(0.2);
                rl.drawRectangle(@intFromFloat(x - cell_size), @intFromFloat(y - cell_size), @intFromFloat(cell_size * 2), @intFromFloat(cell_size * 2), color);
            }
        }
        rl.drawText(time_str, (screen_width / 2) - 45, @intFromFloat(start_y + (4 * spacing)), 30, rl.Color.white);
    }
}
