const std = @import("std");

var directions = [4][2]i2{ .{ -1, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 } };

pub fn main() !void {
    const input = @embedFile("input");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    const result = try process(allocator, input);

    std.debug.print("{}\n", .{result});
}

fn process(allocator: std.mem.Allocator, input: []const u8) !u32 {
    var path = std.AutoHashMap([2]isize, void).init(allocator);
    defer path.deinit();

    var newObstacles = std.AutoHashMap([2]isize, void).init(allocator);
    defer newObstacles.deinit();

    var obstacles = std.AutoHashMap([2]isize, void).init(allocator);
    defer obstacles.deinit();

    var it = std.mem.tokenizeScalar(u8, input, '\n');

    var guardCoords = [_]isize{ 0, 0 };

    var r: usize = 0;
    while (it.next()) |line| : (r += 1) {
        for (line, 0..) |char, c| {
            if (char == '^') {
                guardCoords[0] = @intCast(r);
                guardCoords[1] = @intCast(c);

                try path.put(guardCoords, {});
            }

            if (char == '#') {
                try obstacles.put([_]isize{ @intCast(r), @intCast(c) }, {});
            }
        }
    }

    var directionIdx: usize = 0;

    var direction = directions[0];

    const maxRow = r;
    const maxColumn = std.mem.indexOfScalar(u8, input, '\n').? - 1;

    while (isInBounds(guardCoords, maxRow, maxColumn)) : ({
        direction = directions[@mod(directionIdx, directions.len)];

        guardCoords[0] += direction[0];
        guardCoords[1] += direction[1];
    }) {
        const newCoord = [_]isize{ guardCoords[0] + direction[0], guardCoords[1] + direction[1] };

        if (obstacles.contains(newCoord)) {
            directionIdx += 1;
        }

        if (path.contains(guardCoords)) {
            try newObstacles.put(newCoord, {});
        }

        try path.put(guardCoords, {});

        std.debug.print("{any}\n", .{guardCoords});
    }

    var itBacktrack = std.mem.tokenizeScalar(u8, input, '\n');

    var i: isize = 0;

    while (itBacktrack.next()) |line| : (i += 1) {
        for (line, 0..) |char, j| {
            const coords = [_]isize{ i, @intCast(j) };
            if (newObstacles.contains(coords)) {
                std.debug.print("O", .{});
            } else if (path.contains(coords)) {
                std.debug.print("X", .{});
            } else {
                std.debug.print("{c}", .{char});
            }
        }

        std.debug.print("\n", .{});
    }

    return newObstacles.count() + 1;
}

fn isInBounds(coords: [2]isize, maxRow: usize, maxColumn: usize) bool {
    if (coords[0] < 0 or coords[0] >= maxRow) {
        return false;
    }

    if (coords[1] < 0 or coords[1] >= maxColumn) {
        return false;
    }

    return true;
}

const expect = std.testing.expect;
const testing_allocator = std.testing.allocator;

test "process" {
    const input = @embedFile("test");

    const result = try process(testing_allocator, input);

    std.debug.print("{}\n", .{result});

    try expect(result == 6);
}
