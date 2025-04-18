const std = @import("std");
const rl = @import("raylib");
const builtin = @import("builtin");
const Game = @import("Game.zig").Game;

pub fn main() anyerror!void {
    var game = Game.init(800, 450, 50);

    rl.setTraceLogLevel(if (builtin.mode == .Debug) .debug else .err);
    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(game.screen.width, game.screen.height, "thoaban");
    defer rl.closeWindow();
    rl.initAudioDevice();
    defer rl.closeAudioDevice();
    rl.setTargetFPS(60);

    try game.loop();
}
