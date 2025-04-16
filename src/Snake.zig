const rl = @import("raylib");

pub const Direction = enum { up, down, left, right };

pub const Snake = struct {
    pos: rl.Vector2,
    dir: Direction,
    size: f32,
    score: i32,
    speed: f32,
    color: rl.Color,

    pub fn init(pos: rl.Vector2, dir: Direction, size: f32, color: rl.Color) Snake {
        return Snake{
            .pos = pos,
            .dir = dir,
            .size = size,
            .score = 0,
            .speed = 3,
            .color = color,
        };
    }

    pub fn setDirection(self: *Snake, dir: Direction) void {
        if (self.dir == dir) return;
        switch (dir) {
            .left, .right => {
                if (self.dir == .up or self.dir == .down) {
                    self.dir = dir;
                }
            },
            .up, .down => {
                if (self.dir == .left or self.dir == .right) {
                    self.dir = dir;
                }
            },
        }
    }
};
