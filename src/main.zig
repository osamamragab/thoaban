const std = @import("std");
const rl = @import("raylib");
const util = @import("util.zig");
const Snake = @import("Snake.zig").Snake;
const Food = @import("Food.zig").Food;
const mem = std.mem;
const fmt = std.fmt;

pub fn main() anyerror!void {
    const screenWidth: i32 = 800;
    const screenHeight: i32 = 450;
    var screenDim = rl.Vector2.init(screenWidth, screenHeight);
    const screenPadding = 30;
    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    var score: i32 = 0;
	var scoreBest: i32 = 0;

    rl.setConfigFlags(.{
        .window_resizable = true,
        .window_transparent = true,
    });
    rl.initWindow(screenWidth, screenHeight, "snakegame");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var snake = Snake.init(
        util.randomPosition(rand, screenDim, screenPadding),
        .right,
        20,
    );
    var food = Food.init(
        util.randomPosition(rand, screenDim, screenPadding),
        10,
    );

    var scoreBuf: [200]u8 = undefined;

    const defaultFont = try rl.getFontDefault();
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.black);
        rl.drawFPS(@as(i32, @intFromFloat(screenDim.x)) - screenPadding * 3, screenPadding);

        if (rl.isWindowResized()) {
            screenDim.x = @as(f32, @floatFromInt(rl.getScreenWidth()));
            screenDim.y = @as(f32, @floatFromInt(rl.getScreenHeight()));
        }

        const scoreText = try fmt.bufPrintZ(&scoreBuf, "Score: {d} - Best: {d}", .{score, scoreBest});
        rl.drawText(scoreText, 10, 10, 24, .white);

        if (snake.pos.x <= 0 or snake.pos.y <= 0 or snake.pos.x >= screenDim.x - snake.size or snake.pos.y >= screenDim.y - snake.size) {
            const loserText = "You lost bitch";
            const loserPos = util.middleVector2(screenDim, rl.measureTextEx(defaultFont, loserText, 54, 1));
            rl.drawTextEx(defaultFont, loserText, loserPos, 54, 1, .white);
            const actionText = "Press [Space] to continue";
            const actionPos = rl.Vector2.init(screenDim.x / 2 - @as(f32, @floatFromInt(rl.measureText(actionText, 17))) / 2, loserPos.y + 70);
            rl.drawTextEx(defaultFont, actionText, actionPos, 17, 1, .gray);
            if (rl.isKeyDown(rl.KeyboardKey.space)) {
				if (score > scoreBest) scoreBest = score;
				score = 0;
                snake.pos = util.randomPosition(rand, screenDim, screenPadding + 50);
                food.pos = util.randomPosition(rand, screenDim, screenPadding);
            }
            continue;
        }

        const speed = 3 + @as(f32, @floatFromInt(score)) / 5;
        switch (snake.dir) {
            .up => snake.pos.y -= speed,
            .down => snake.pos.y += speed,
            .left => snake.pos.x -= speed,
            .right => snake.pos.x += speed,
        }

        const snakeRec = rl.Rectangle.init(snake.pos.x, snake.pos.y, snake.size, snake.size);
        rl.drawCircleV(food.pos, food.size, .white);
        rl.drawRectangleRec(snakeRec, .white);

        if (rl.checkCollisionCircleRec(food.pos, food.size, snakeRec)) {
            score += 1;
            food.pos = util.randomPosition(rand, screenDim, screenPadding);
        }

        if (rl.isKeyDown(rl.KeyboardKey.up) or rl.isKeyDown(rl.KeyboardKey.w) or rl.isKeyDown(rl.KeyboardKey.k)) snake.setDirection(.up);
        if (rl.isKeyDown(rl.KeyboardKey.down) or rl.isKeyDown(rl.KeyboardKey.s) or rl.isKeyDown(rl.KeyboardKey.j)) snake.setDirection(.down);
        if (rl.isKeyDown(rl.KeyboardKey.left) or rl.isKeyDown(rl.KeyboardKey.a) or rl.isKeyDown(rl.KeyboardKey.h)) snake.setDirection(.left);
        if (rl.isKeyDown(rl.KeyboardKey.right) or rl.isKeyDown(rl.KeyboardKey.d) or rl.isKeyDown(rl.KeyboardKey.l)) snake.setDirection(.right);
        if ((rl.isKeyPressed(rl.KeyboardKey.left_control) or rl.isKeyPressed(rl.KeyboardKey.right_control)) and rl.isKeyPressed(rl.KeyboardKey.q)) rl.closeWindow();
    }
}

fn loop() void {}
