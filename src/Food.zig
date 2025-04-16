const rl = @import("raylib");

pub const Food = struct {
    pos: rl.Vector2,
    size: f32,
    color: rl.Color,

    pub fn init(pos: rl.Vector2, size: f32, color: rl.Color) Food {
        return Food{ .pos = pos, .size = size, .color = color };
    }

    pub fn fromPoints(x: f32, y: f32, size: f32) Food {
        return Food{ .pos = rl.Vector2.init(x, y), .size = size };
    }

    pub fn draw(self: Food) void {
        rl.drawCircle(self.x, self.y, self.size, .white);
    }
};
