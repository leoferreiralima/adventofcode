const std = @import("std");

const X_MAS = "MAS";
const DIRECTIONS = [_][2]i8{
    .{ 0, 1 }, // UP
    .{ 0, -1 }, // DOWN
    .{ 1, 0 }, // RIGHT
    .{ -1, 0 }, // LEFT
    .{ 1, 1 }, // UP RIGHT
    .{ 1, -1 }, // DOWN RIGHT
    .{ -1, 1 }, // UP LEFT
    .{ -1, -1 }, // DOWN LEFT
};

pub fn main() !void {
    const file = @embedFile("test");

    var linesIterator = std.mem.splitSequence(u8, file, "\n");

    var allocator = std.heap.page_allocator;

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var result = std.ArrayList([]u8).init(allocator);
    defer result.deinit();

    while (linesIterator.next()) |line| {
        try lines.append(line);

        try result.append(try repeat('.', line.len, &allocator));
    }

    var backtrack = std.ArrayList([2]usize).init(allocator);
    defer backtrack.deinit();

    var count: usize = 0;

    for (lines.items, 0..) |line, row| {
        for (line, 0..) |char, column| {
            if (char == 'X') {
                count += try countXmas(row, column, &lines.items, &backtrack);
            }
        }
    }

    std.debug.print("{}\n", .{count});

    for (backtrack.items) |item| {
        const row = item[0];
        const column = item[1];
        result.items[row][column] = lines.items[row][column];
    }

    for (result.items) |line| {
        std.debug.print("{s}\n", .{line});
    }
}

fn countXmas(row: usize, column: usize, lines: *[][]const u8, backtrack: *std.ArrayList([2]usize)) !usize {
    var count: usize = 0;
    for (DIRECTIONS) |dir| {
        var i: usize = 0;
        var r: isize = @intCast(row);
        var c: isize = @intCast(column);

        while (isInBounds(r, c, lines) and X_MAS[i] == lines.*[@intCast(r)][@intCast(c)]) : ({
            c += dir[0];
            r += dir[1];
            i += 1;
        }) {
            try backtrack.append([_]usize{ @intCast(r), @intCast(c) });
        }

        if (i == X_MAS.len) {
            count += 1;
        } else {
            while (i > 0) : (i -= 1) {
                _ = backtrack.pop();
            }
        }
    }

    return count;
}

fn isInBounds(row: isize, column: isize, lines: *[][]const u8) bool {
    if (row < 0 or row >= lines.len) {
        return false;
    }

    if (column < 0 or column >= lines.*[0].len) {
        return false;
    }

    return true;
}

fn repeat(char: u8, count: usize, allocator: *std.mem.Allocator) ![]u8 {
    var buffer = try allocator.alloc(u8, count);

    var index: usize = 0;
    for (count) |_| {
        buffer[index] = char;
        index += 1;
    }

    return buffer;
}
