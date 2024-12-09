const std = @import("std");

pub fn main() !void {
    const file = @embedFile("day1.input");

    var lines = std.mem.splitSequence(u8, file, "\n");

    const allocator = std.heap.page_allocator;

    var left = std.ArrayList(usize).init(allocator);
    defer _ = left.deinit();

    var ocurrencies = std.AutoHashMap(usize, usize).init(
        allocator,
    );
    defer ocurrencies.deinit();

    while (lines.next()) |line| {
        var parts = std.mem.splitSequence(u8, line, "   ");

        const right = try std.fmt.parseInt(usize, parts.next().?, 10);

        try left.append(try std.fmt.parseInt(usize, parts.next().?, 10));

        const occurrency = ocurrencies.get(right);
        if (occurrency) |value| {
            try ocurrencies.put(right, value + 1);
        } else {
            try ocurrencies.put(right, 1);
        }
    }

    var sum: usize = 0;
    for (left.items) |value| {
        if (ocurrencies.get(value)) |occurrency| {
            sum += value * occurrency;
        }
    }

    std.debug.print("{}\n", .{sum});
}
