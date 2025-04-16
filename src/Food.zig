const std = @import("std");
const rl = @import("raylib");

pub const Food = struct {
    size: f32,
	color: rl.Color,
	shape: rl.Vector2,

    pub fn init(x: i32, y: i32, size: f32, color: rl.Color) Food {
        return Food{
            .shape = .{
                .x = @as(f32, @floatFromInt(x)),
                .y = @as(f32, @floatFromInt(y)),
            },
            .size = size,
            .color = color,
        };
    }

    pub fn updatePosition(self: *Food, x: i32, y: i32) void {
        self.shape.x = @as(f32, @floatFromInt(x));
        self.shape.y = @as(f32, @floatFromInt(y));
    }

    pub fn draw(self: *Food) void {
        rl.drawCircleV(self.shape, self.size, self.color);
    }
};
