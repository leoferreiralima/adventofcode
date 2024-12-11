const std = @import("std");

pub fn main() !void {
    const file = @embedFile("input");

    const split = std.mem.indexOf(u8, file, "\n\n") orelse return error.BadInput;

    const rules = file[0..split];
    const updates = file[split + 2 ..];

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var arena = std.heap.ArenaAllocator.init(allocator);

    defer arena.deinit();

    const arenaAllocator = arena.allocator();

    const rulesMap = try getRulesMap(arenaAllocator, rules);

    var updateLines = std.mem.tokenizeScalar(u8, updates, '\n');

    var seen = std.ArrayList(usize).init(allocator);
    defer seen.deinit();

    var count: usize = 0;

    while (updateLines.next()) |line| {
        seen.clearRetainingCapacity();
        var tokenizer = std.mem.tokenizeScalar(u8, line, ',');

        while (tokenizer.next()) |token| {
            const number = try std.fmt.parseInt(u32, token, 10);

            if (rulesMap.get(number)) |rule| {
                if (std.mem.indexOfAny(usize, rule, seen.items)) |_| {
                    break;
                }
            }

            try seen.append(number);
        } else {
            count += seen.items[@divExact(seen.items.len - 1, 2)];
        }
    }

    std.debug.print("{}\n", .{count});
}

fn getRulesMap(allocator: std.mem.Allocator, rules: []const u8) !std.AutoHashMap(usize, []usize) {
    var tokenizer = std.mem.tokenizeScalar(u8, rules, '\n');

    var leftArray = std.ArrayList(usize).init(allocator);
    var rightArray = std.ArrayList(usize).init(allocator);
    var rulesCountMap = std.AutoHashMap(usize, usize).init(allocator);

    while (tokenizer.next()) |rule| {
        const pipe = std.mem.indexOf(u8, rule, "|") orelse return error.BadInput;

        const left = try std.fmt.parseInt(usize, rule[0..pipe], 10);
        const right = try std.fmt.parseInt(usize, rule[pipe + 1 ..], 10);

        const count = try rulesCountMap.getOrPut(left);

        if (count.found_existing) {
            count.value_ptr.* += 1;
        } else {
            count.value_ptr.* = 1;
        }

        try leftArray.append(left);
        try rightArray.append(right);
    }

    var rulesMap = std.AutoHashMap(usize, []usize).init(allocator);

    var countIt = rulesCountMap.iterator();

    while (countIt.next()) |entry| {
        const slice = try allocator.alloc(usize, entry.value_ptr.*);
        try rulesMap.put(entry.key_ptr.*, slice);

        entry.value_ptr.* = 0;
    }

    for (leftArray.items, rightArray.items) |left, right| {
        const i = rulesCountMap.getPtr(left).?;

        const slice = rulesMap.get(left).?;

        slice[i.*] = right;

        i.* += 1;
    }

    return rulesMap;
}
