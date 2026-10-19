const std = @import("std");

pub const Operation = enum { add, substract, multiply, divide };

pub fn calculate(expr: []const u8) !f64 {
    const trimmed = std.mem.trim(u8, expr, "\t\r\n");
    if (trimmed.len == 0) return error.InvalidInput;
    var op_index: ?usize = null;
    var found_op: Operation = .add;

    for (trimmed[1..], 1..) |char, i| {
        switch (char) {
            '+' => {
                op_index = i;
                found_op = .add;
                break;
            },
            '-' => {
                op_index = i;
                found_op = .substract;
                break;
            },
            '*' => {
                op_index = i;
                found_op = .multiply;
                break;
            },
            '/' => {
                op_index = i;
                found_op = .divide;
                break;
            },
            else => {},
        }
    }
    const idx = op_index orelse return error.InvalidInput;
    const left_str = std.mem.trim(u8, trimmed[0..idx], " ");
    const right_str = std.mem.trim(u8, trimmed[idx + 1 ..], " ");

    const num1 = try std.fmt.parseFloat(f64, left_str);
    const num2 = try std.fmt.parseFloat(f64, right_str);
    return switch (found_op) {
        .add => num1 + num2,
        .substract => num1 - num2,
        .multiply => num1 * num2,
        .divide => {
            if (num2 == 0) return error.DivisionByZero;
            return num1 / num2;
        },
    };
}
