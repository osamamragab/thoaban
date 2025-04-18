const std = @import("std");
const rl = @import("raylib");

pub const Food = struct {
    pos: rl.Vector2,
    size: f32,
    color: rl.Color,

    pub fn init(x: i32, y: i32, size: f32, color: rl.Color) Food {
        return Food{
            .pos = .{
                .x = @as(f32, @floatFromInt(x)),
                .y = @as(f32, @floatFromInt(y)),
            },
            .size = size,
            .color = color,
        };
    }

    pub fn draw(self: *Food) void {
        rl.drawCircle(
            @as(i32, @intFromFloat(self.pos.x)),
            @as(i32, @intFromFloat(self.pos.y)),
            self.size,
            self.color,
        );
    }
};
