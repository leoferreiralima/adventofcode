const std = @import("std");

const X_MAS = "MAS";

pub fn main() !void {
    const file = @embedFile("input");

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

    var count: usize = 0;

    for (lines.items, 0..) |line, row| {
        for (line, 0..) |char, column| {
            if (char == 'A') {
                count += try countXmas(row, column, &lines.items);
            }
        }
    }

    std.debug.print("{}\n", .{count});
}

fn countXmas(row: usize, column: usize, linesPtr: *[][]const u8) !usize {
    const r: isize = @intCast(row);
    const c: isize = @intCast(column);

    const lines = linesPtr.*;

    const upperLeft: u8 = if (isInBounds(r - 1, c - 1, linesPtr)) lines[@intCast(r - 1)][@intCast(c - 1)] else 0;
    const downLeft: u8 = if (isInBounds(r + 1, c - 1, linesPtr)) lines[@intCast(r + 1)][@intCast(c - 1)] else 0;
    const upperRight: u8 = if (isInBounds(r - 1, c + 1, linesPtr)) lines[@intCast(r - 1)][@intCast(c + 1)] else 0;
    const downRight: u8 = if (isInBounds(r + 1, c + 1, linesPtr)) lines[@intCast(r + 1)][@intCast(c + 1)] else 0;

    const hasDiagonal1 = (upperLeft == X_MAS[0] and downRight == X_MAS[2]) or (upperLeft == X_MAS[2] and downRight == X_MAS[0]);
    const hasDiagonal2 = (upperRight == X_MAS[0] and downLeft == X_MAS[2]) or (upperRight == X_MAS[2] and downLeft == X_MAS[0]);

    return if (hasDiagonal1 and hasDiagonal2) 1 else 0;
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
