const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const file = @embedFile("input");

    var lines = std.mem.splitSequence(u8, file, "\n");

    var safeCount: usize = 0;

    while (lines.next()) |line| {
        var numbersIt = std.mem.splitSequence(u8, line, " ");

        var numbers = std.ArrayList(usize).init(allocator);

        defer numbers.deinit();

        while (numbersIt.next()) |numberAsString| {
            const number = try std.fmt.parseInt(usize, numberAsString, 10);

            try numbers.append(number);
        }

        const isSafe = try isIncreasingSafe(numbers.items, 0) or try isDecreasingSafe(numbers.items, 0);

        if (isSafe) {
            safeCount += 1;
        } else {
            std.debug.print("{s}\n", .{line});
        }
    }

    std.debug.print("\n{}\n", .{safeCount});
}

fn isIncreasingSafe(numbers: []const usize, badLevelCount: usize) !bool {
    if (badLevelCount > 1) {
        return false;
    }

    const allocator = std.heap.page_allocator;

    var i: usize = 1;

    while (i < numbers.len) : (i += 1) {
        const number = numbers[i];
        const last = numbers[i - 1];

        if (number <= last or number - last > 3) {
            return try isIncreasingSafe(try std.mem.concat(allocator, usize, &[_][]const usize{ numbers[0..i], numbers[i + 1 ..] }), badLevelCount + 1) or try isIncreasingSafe(try std.mem.concat(allocator, usize, &[_][]const usize{ numbers[0 .. i - 1], numbers[i..] }), badLevelCount + 1);
        }
    }

    return true;
}

fn isDecreasingSafe(numbers: []const usize, badLevelCount: usize) !bool {
    if (badLevelCount > 1) {
        return false;
    }

    const allocator = std.heap.page_allocator;

    var i: usize = 1;

    while (i < numbers.len) : (i += 1) {
        const number = numbers[i];
        const last = numbers[i - 1];

        if (last <= number or last - number > 3) {
            return try isDecreasingSafe(try std.mem.concat(allocator, usize, &[_][]const usize{ numbers[0..i], numbers[i + 1 ..] }), badLevelCount + 1) or try isDecreasingSafe(try std.mem.concat(allocator, usize, &[_][]const usize{ numbers[0 .. i - 1], numbers[i..] }), badLevelCount + 1);
        }
    }

    return true;
}
