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
            .second = @as(u8, @intCast(@mod(seconds, 60))),
        };
    }

    pub fn format(self: BTime, writer: *std.Io.Writer) !void {
        try writer.print("{d:02}:{d:02}:{d:02}", .{ self.hour, self.minute, self.second });
    }
};

pub fn main(init: std.process.Init) !void {
    const allocator = std.heap.page_allocator;
    const screen_width = 450;
    const screen_height = 450;

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
            time_str = try std.fmt.allocPrintSentinel(allocator, "{f}", .{time}, 0);
        }

        // TODO:  Make dynamic
        rl.drawText(time_str, (screen_width / 2) - 45, (screen_height) - 150, 30, rl.Color.white);
    }
}
