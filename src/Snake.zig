const std = @import("std");
const rl = @import("raylib");

pub const Direction = enum { up, down, left, right };

pub const Snake = struct {
    pos: [256]rl.Vector2,
    dir: Direction,
    size: f32,
    color: rl.Color,
    length: usize,

    pub fn init(x: i32, y: i32, size: f32, dir: Direction, color: rl.Color) Snake {
        var snake = Snake{
            .pos = undefined,
            .dir = dir,
            .size = size,
            .color = color,
            .length = 1,
        };
        snake.pos[0].x = @as(f32, @floatFromInt(x));
        snake.pos[0].y = @as(f32, @floatFromInt(y));
        return snake;
    }

    pub fn rectangle(self: Snake) rl.Rectangle {
        return rl.Rectangle.init(self.pos[0].x, self.pos[0].y, self.size, self.size);
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

    pub fn step(self: *Snake) void {
        for (1..self.length) |i| {
            self.pos[self.length - i] = self.pos[self.length - i - 1];
        }
        switch (self.dir) {
            .up => self.pos[0].y -= self.size,
            .down => self.pos[0].y += self.size,
            .left => self.pos[0].x -= self.size,
            .right => self.pos[0].x += self.size,
        }
    }

    pub fn draw(self: *Snake) void {
        for (self.pos[0..self.length]) |p| {
            if (p.x == 0 and p.y == 0) continue;
            rl.drawRectangle(
                @as(i32, @intFromFloat(p.x)),
                @as(i32, @intFromFloat(p.y)),
                @as(i32, @intFromFloat(self.size)),
                @as(i32, @intFromFloat(self.size)),
                self.color,
            );
        }
    }
};
