const std = @import("std");
const rl = @import("raylib");

pub const Direction = enum { up, down, left, right };

pub const Snake = struct {
    dir: Direction,
    size: i32,
    speed: f32,
    color: rl.Color,
    shape: rl.Rectangle,

    pub fn init(x: i32, y: i32, size: i32, dir: Direction, color: rl.Color) Snake {
        const xf = @as(f32, @floatFromInt(x));
        const yf = @as(f32, @floatFromInt(y));
        const sf = @as(f32, @floatFromInt(size));
        return Snake{
            .dir = dir,
            .size = size,
            .speed = 3,
            .color = color,
            .shape = rl.Rectangle.init(xf, yf, sf, sf),
        };
    }

    pub fn updatePosition(self: *Snake, x: i32, y: i32) void {
        self.shape.x = @as(f32, @floatFromInt(x));
        self.shape.y = @as(f32, @floatFromInt(y));
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

    pub fn step(self: *Snake, score: i32) void {
        const speed = 3 + @as(f32, @floatFromInt(score)) / 5;
        switch (self.dir) {
            .up => self.shape.y -= speed,
            .down => self.shape.y += speed,
            .left => self.shape.x -= speed,
            .right => self.shape.x += speed,
        }
    }

    pub fn draw(self: *Snake) void {
        rl.drawRectangleRec(self.shape, self.color);
    }
};
