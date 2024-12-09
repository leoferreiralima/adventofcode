const std = @import("std");

pub fn main() !void {
    const file = @embedFile("input");

    var lines = std.mem.splitSequence(u8, file, "\n");

    var result: usize = 0;
    while (lines.next()) |line| {
        var i: usize = 0;

        while (i < line.len - 4) : (i += 1) {
            if (std.mem.eql(u8, line[i .. i + 4], "mul(")) {
                const allocator = std.heap.page_allocator;
                i += 4;

                var leftNumber = std.ArrayList(u8).init(allocator);
                defer leftNumber.deinit();

                while (line[i] >= '0' and line[i] <= '9') : (i += 1) {
                    try leftNumber.append(line[i]);
                }

                if (leftNumber.items.len == 0) {
                    continue;
                }

                if (line[i] != ',') {
                    continue;
                }

                i += 1;

                var rightNumber = std.ArrayList(u8).init(allocator);
                defer rightNumber.deinit();
                while (line[i] >= '0' and line[i] <= '9') : (i += 1) {
                    try rightNumber.append(line[i]);
                }

                if (rightNumber.items.len == 0) {
                    continue;
                }

                if (line[i] != ')') {
                    continue;
                }

                std.debug.print("{s} * {s}\n", .{ leftNumber.items, rightNumber.items });

                result += try std.fmt.parseInt(usize, leftNumber.items, 10) * try std.fmt.parseInt(usize, rightNumber.items, 10);
            }
        }
    }

    std.debug.print("\n{}\n", .{result});
}
