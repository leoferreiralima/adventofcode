const std = @import("std");

const MUL = "mul(";
const DO = "do()";
const DONT = "don't()";

pub fn main() !void {
    const file = @embedFile("input");

    var lines = std.mem.splitSequence(u8, file, "\n");

    var result: usize = 0;
    var isDisabled = false;

    while (lines.next()) |line| {
        var i: usize = 0;

        while (i < line.len) : (i += 1) {
            if (std.mem.eql(u8, line[i..@min(line.len - 1, i + DO.len)], DO)) {
                isDisabled = false;
                i += DO.len;
            } else if (std.mem.eql(u8, line[i..@min(line.len - 1, i + DONT.len)], DONT)) {
                isDisabled = true;
                i += DONT.len;
            }

            if (isDisabled) {
                continue;
            }

            if (std.mem.eql(u8, line[i..@min(line.len - 1, i + MUL.len)], MUL)) {
                const allocator = std.heap.page_allocator;
                i += MUL.len;

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

                result += try std.fmt.parseInt(usize, leftNumber.items, 10) * try std.fmt.parseInt(usize, rightNumber.items, 10);
            }
        }
    }

    std.debug.print("\n{}\n", .{result});
}
