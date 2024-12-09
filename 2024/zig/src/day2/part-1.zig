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

        const isIncreasing = numbers.items[1] > numbers.items[0];
        var isSafe = true;

        var i: usize = 1;

        while (i < numbers.items.len) : (i += 1) {
            const number = numbers.items[i];
            const last = numbers.items[i - 1];

            if (number == last) {
                isSafe = false;
                break;
            } else if (isIncreasing) {
                if (number < last or number - last > 3) {
                    isSafe = false;
                    break;
                }
            } else {
                if (number > last or last - number > 3) {
                    isSafe = false;
                    break;
                }
            }
        }

        if (isSafe) {
            safeCount += 1;
        } else {
            std.debug.print("{s}\n", .{line});
        }
    }

    std.debug.print("\n{}\n", .{safeCount});
}
