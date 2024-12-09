const std = @import("std");

pub fn main() !void {
    const file = @embedFile("day1.input");

    var lines = std.mem.splitSequence(u8, file, "\n");

    const allocator = std.heap.page_allocator;

    var left = std.ArrayList(isize).init(allocator);
    defer _ = left.deinit();

    var right = std.ArrayList(isize).init(allocator);
    defer _ = right.deinit();

    while (lines.next()) |line| {
        var parts = std.mem.splitSequence(u8, line, "   ");

        try left.append(try std.fmt.parseInt(isize, parts.next().?, 10));
        try right.append(try std.fmt.parseInt(isize, parts.next().?, 10));
    }

    std.mem.sort(isize, left.items, {}, std.sort.asc(isize));
    std.mem.sort(isize, right.items, {}, std.sort.asc(isize));

    var i: usize = 0;
    var sum: usize = 0;
    while (i < left.items.len) : (i += 1) {
        sum += @abs(right.items[i] - left.items[i]);
    }

    std.debug.print("{}\n", .{sum});
}
