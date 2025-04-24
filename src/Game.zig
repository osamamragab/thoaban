const std = @import("std");
const rl = @import("raylib");
const builtin = @import("builtin");
const Snake = @import("Snake.zig").Snake;
const Food = @import("Food.zig").Food;

const thth_sound_file = @embedFile("thth_sound");
const zawahif_sound_file = @embedFile("zawahif_sound");
const krudya_sound_file = @embedFile("krudya_sound");
const disconnected_sound_file = @embedFile("disconnected_sound");

pub const Screen = struct {
    width: i32,
    height: i32,
    padding: i32,
};

pub const Game = struct {
    screen: Screen,
    snake: Snake,
    food: Food,
    poison: Food,
    font: ?rl.Font,
    score: i32,
    score_best: i32,

    pub fn init(screenWidth: i32, screenHeight: i32, screenPadding: i32) Game {
        const snake = Snake.init(0, 0, 20, .right, .white);
        const food = Food.init(0, 0, 10, .red);
        const poison = Food.init(0, 0, 10, .dark_green);
        var game = Game{
            .snake = snake,
            .food = food,
            .poison = poison,
            .screen = .{
                .width = screenWidth,
                .height = screenHeight,
                .padding = screenPadding,
            },
            .font = null,
            .score = 0,
            .score_best = 0,
        };
        rl.setRandomSeed(std.crypto.random.int(u32));
        game.reset(true);
        return game;
    }

    inline fn middleVector2(v1: rl.Vector2, v2: rl.Vector2) rl.Vector2 {
        return v1.scale(0.5).subtract(v2.scale(0.5));
    }

    inline fn randomPosition(self: Game, pos: i32) i32 {
        return rl.getRandomValue(self.screen.padding * 2, pos - self.screen.padding * 2);
    }

    fn reset(self: *Game, hard: bool) void {
        if (hard) {
            if (self.score > self.score_best) {
                self.score_best = self.score;
            }
            self.score = 0;
            self.snake.length = 1;
            self.snake.pos[0].x = @as(f32, @floatFromInt(self.randomPosition(self.screen.width)));
            self.snake.pos[0].y = @as(f32, @floatFromInt(self.randomPosition(self.screen.height)));
            self.snake.setDirection(.right);
        }
        self.food.pos.x = @as(f32, @floatFromInt(self.randomPosition(self.screen.width)));
        self.food.pos.y = @as(f32, @floatFromInt(self.randomPosition(self.screen.height)));
        self.poison.pos.x = @as(f32, @floatFromInt(self.randomPosition(self.screen.width)));
        self.poison.pos.y = @as(f32, @floatFromInt(self.randomPosition(self.screen.height)));
        for (self.snake.pos[0..self.snake.length]) |p| {
            const rect = rl.Rectangle.init(p.x, p.y, self.snake.size, self.snake.size);
            while (rl.checkCollisionCircleRec(self.food.pos, self.food.size, rect)) {
                self.food.pos.x = @as(f32, @floatFromInt(self.randomPosition(self.screen.width)));
                self.food.pos.y = @as(f32, @floatFromInt(self.randomPosition(self.screen.height)));
            }
            while (rl.checkCollisionCircleRec(self.poison.pos, self.poison.size, rect)) {
                self.poison.pos.x = @as(f32, @floatFromInt(self.randomPosition(self.screen.width)));
                self.poison.pos.y = @as(f32, @floatFromInt(self.randomPosition(self.screen.height)));
            }
        }
    }

    fn lost(self: *Game) bool {
        const head = self.snake.pos[0];
        for (self.snake.pos[1..self.snake.length]) |p| {
            if (head.x == p.x and head.y == p.y) {
                return true;
            }
        }
        return head.x <= @as(f32, @floatFromInt(self.screen.padding)) + self.snake.size or
            head.y <= @as(f32, @floatFromInt(self.screen.padding)) + self.snake.size or
            head.x >= @as(f32, @floatFromInt(self.screen.width - self.screen.padding)) - self.snake.size or
            head.y >= @as(f32, @floatFromInt(self.screen.height - self.screen.padding)) - self.snake.size;
    }

    fn drawTextCenter(self: *Game, text: [:0]const u8, fontSize: f32, spacing: f32, tint: rl.Color, padding: ?rl.Vector2) void {
        var pos = middleVector2(
            .{
                .x = @as(f32, @floatFromInt(self.screen.width)),
                .y = @as(f32, @floatFromInt(self.screen.height)),
            },
            rl.measureTextEx(self.font.?, text, fontSize, spacing),
        );
        if (padding) |p| {
            pos.x += p.x;
            pos.y += p.y;
        }
        rl.drawTextEx(self.font.?, text, pos, fontSize, spacing, tint);
    }

    fn updateDirection(self: *Game) void {
        if (rl.isKeyDown(rl.KeyboardKey.up) or rl.isKeyDown(rl.KeyboardKey.w) or rl.isKeyDown(rl.KeyboardKey.k)) self.snake.setDirection(.up);
        if (rl.isKeyDown(rl.KeyboardKey.down) or rl.isKeyDown(rl.KeyboardKey.s) or rl.isKeyDown(rl.KeyboardKey.j)) self.snake.setDirection(.down);
        if (rl.isKeyDown(rl.KeyboardKey.left) or rl.isKeyDown(rl.KeyboardKey.a) or rl.isKeyDown(rl.KeyboardKey.h)) self.snake.setDirection(.left);
        if (rl.isKeyDown(rl.KeyboardKey.right) or rl.isKeyDown(rl.KeyboardKey.d) or rl.isKeyDown(rl.KeyboardKey.l)) self.snake.setDirection(.right);
    }

    pub fn loop(self: *Game) anyerror!void {
        var paused = false;
        var gameover = false;
        var frames_counter: i32 = 0;
        rl.setExitKey(.null);
        if (self.font == null) {
            self.font = try rl.getFontDefault();
        }

        const eatSoundWave = try rl.loadWaveFromMemory(".wav", thth_sound_file);
        defer rl.unloadWave(eatSoundWave);
        const eatSound = rl.loadSoundFromWave(eatSoundWave);
        defer rl.unloadSound(eatSound);

        const eat2SoundWave = try rl.loadWaveFromMemory(".wav", zawahif_sound_file);
        defer rl.unloadWave(eat2SoundWave);
        const eat2Sound = rl.loadSoundFromWave(eat2SoundWave);
        defer rl.unloadSound(eat2Sound);

        const gameoverSoundWave = try rl.loadWaveFromMemory(".wav", disconnected_sound_file);
        defer rl.unloadWave(gameoverSoundWave);
        const gameoverSound = rl.loadSoundFromWave(gameoverSoundWave);
        defer rl.unloadSound(gameoverSound);

        const poisonSoundWave = try rl.loadWaveFromMemory(".wav", krudya_sound_file);
        defer rl.unloadWave(poisonSoundWave);
        const poisonSound = rl.loadSoundFromWave(poisonSoundWave);
        defer rl.unloadSound(poisonSound);

        while (!rl.windowShouldClose()) {
            rl.beginDrawing();
            defer rl.endDrawing();
            rl.clearBackground(.black);
            rl.drawFPS(self.screen.width - 30, 10);

            if (rl.isWindowResized()) {
                self.screen.width = rl.getScreenWidth();
                self.screen.height = rl.getScreenHeight();
            }

            if ((rl.isKeyPressed(rl.KeyboardKey.left_control) or rl.isKeyPressed(rl.KeyboardKey.right_control)) and rl.isKeyPressed(rl.KeyboardKey.q)) {
                rl.closeWindow();
            }

            rl.drawText(
                rl.textFormat("Score: %d - Best: %d", .{ self.score, self.score_best }),
                10,
                10,
                24,
                .white,
            );

            rl.drawRectangleLines(
                self.screen.padding,
                self.screen.padding,
                self.screen.width - self.screen.padding * 2,
                self.screen.height - self.screen.padding * 2,
                .white,
            );

            if (gameover) {
                self.drawTextCenter("You lost bitch", 54, 1, .white, null);
                self.drawTextCenter("Press [Space] to continue", 17, 1, .gray, .{ .x = 0, .y = 70 });
                if (rl.isKeyDown(rl.KeyboardKey.space)) {
                    self.reset(true);
                    gameover = false;
                }
                continue;
            }

            if (paused) {
                if (rl.isKeyDown(rl.KeyboardKey.space)) {
                    paused = false;
                }
                self.drawTextCenter("Paused", 24, 1, .white, .{
                    .x = 0,
                    .y = -(@as(f32, @floatFromInt(self.screen.height)) / 2) + 20,
                });
                self.snake.draw();
                self.food.draw();
                self.poison.draw();
                continue;
            }

            if (self.lost()) {
                gameover = true;
                frames_counter = 0;
                if (!rl.isSoundPlaying(gameoverSound)) {
                    if (rl.isSoundPlaying(eatSound)) {
                        rl.stopSound(eatSound);
                    }
                    if (rl.isSoundPlaying(eat2Sound)) {
                        rl.stopSound(eat2Sound);
                    }
                    if (rl.isSoundPlaying(poisonSound)) {
                        rl.stopSound(poisonSound);
                    }
                    rl.playSound(gameoverSound);
                }
            }

            if (@rem(frames_counter, 5) == 0) {
                self.snake.step();
                const rect = self.snake.rectangle();
                if (rl.checkCollisionCircleRec(self.food.pos, self.food.size, rect)) {
                    self.score += 1;
                    self.snake.pos[self.snake.length].x = 0;
                    self.snake.pos[self.snake.length].y = 0;
                    self.snake.length += 1;
                    self.reset(false);
                    if (@rem(self.score, 2) == 0) {
                        if (rl.isSoundPlaying(eatSound)) {
                            rl.stopSound(eatSound);
                        }
                        if (!rl.isSoundPlaying(eat2Sound)) {
                            rl.playSound(eat2Sound);
                        }
                    } else {
                        if (rl.isSoundPlaying(eat2Sound)) {
                            rl.stopSound(eat2Sound);
                        }
                        if (!rl.isSoundPlaying(eatSound)) {
                            rl.playSound(eatSound);
                        }
                    }
                }
                if (rl.checkCollisionCircleRec(self.poison.pos, self.poison.size, rect)) {
                    gameover = true;
                    frames_counter = 0;
                    if (!rl.isSoundPlaying(poisonSound)) {
                        if (rl.isSoundPlaying(eatSound)) {
                            rl.stopSound(eatSound);
                        }
                        if (rl.isSoundPlaying(gameoverSound)) {
                            rl.stopSound(gameoverSound);
                        }
                        rl.playSound(poisonSound);
                    }
                }
            }

            self.snake.draw();
            self.food.draw();
            self.poison.draw();

            self.updateDirection();

            if (rl.isKeyDown(rl.KeyboardKey.escape)) {
                paused = true;
            }

            frames_counter += 1;
        }
    }
};
