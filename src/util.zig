const std = @import("std");
const rl = @import("raylib");

pub inline fn ntof32(n: anytype) f32 {
    return switch (@typeInfo(@TypeOf(n))) {
        .float, .comptime_float => @floatCast(n),
        .int, .comptime_int => @floatFromInt(n),
        else => @compileError("ntof32: expected numeric type, got " ++ @typeName(n)),
    };
}

pub inline fn randomFloat(rand: std.Random, min: f32, max: f32) f32 {
    return min + rand.float(f32) * (max - min);
}

pub inline fn randomPosition(rand: std.Random, dim: rl.Vector2, padding: f32) rl.Vector2 {
    return .{
        .x = randomFloat(rand, padding, dim.x - padding),
        .y = randomFloat(rand, padding, dim.y - padding),
    };
}

pub inline fn middleVector2(v1: rl.Vector2, v2: rl.Vector2) rl.Vector2 {
    return v1.scale(0.5).subtract(v2.scale(0.5));
}
