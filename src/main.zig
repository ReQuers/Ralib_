// const rl = @import("raylib");

// pub fn main() !void {
//     rl.initWindow(900, 900, "Zig 0.17 + raylib");
//     defer rl.closeWindow();

//     rl.setTargetFPS(60);

//     while (!rl.windowShouldClose()) {
//         rl.beginDrawing();
//         defer rl.endDrawing();

//         rl.clearBackground(.white);
//         rl.drawText("It works!", 190, 200, 20, .light_gray);
//         rl.drawText("My own Text - Rey", 100, 100, 30, .black);
//     }
// }
const std = @import("std");
const rl = @import("raylib");
const calc = @import("calculator.zig");

const font_size = 20;

const TextField = struct {
    buf: [64]u8 = @splat(0),
    len: usize = 0,

    fn text(self: *const TextField) [:0]const u8 {
        return self.buf[0..self.len :0];
    }

    fn handleInput(self: *TextField) void {
        while (true) {
            const ch = rl.getCharPressed();
            if (ch == 0) break;
            if (ch >= 32 and ch < 127 and self.len < self.buf.len - 1) {
                self.buf[self.len] = @intCast(ch);
                self.len += 1;
                self.buf[self.len] = 0;
            }
        }
        const erase = rl.isKeyPressed(.backspace) or rl.isKeyPressedRepeat(.backspace);
        if (erase and self.len > 0) {
            self.len -= 1;
            self.buf[self.len] = 0;
        }
    }
};

fn button(rect: rl.Rectangle, label: [:0]const u8) bool {
    const hover = rl.checkCollisionPointRec(rl.getMousePosition(), rect);
    const pressed = hover and rl.isMouseButtonDown(.left);

    rl.drawRectangleRec(rect, if (pressed) .gray else if (hover) .light_gray else .ray_white);
    rl.drawRectangleLinesEx(rect, 2, .dark_gray);

    const text_w: f32 = @floatFromInt(rl.measureText(label, font_size));
    const tx: i32 = @intFromFloat(rect.x + (rect.width - text_w) / 2);
    const ty: i32 = @intFromFloat(rect.y + (rect.height - font_size) / 2);
    rl.drawText(label, tx, ty, font_size, .black);

    return hover and rl.isMouseButtonReleased(.left);
}
///////////
///
///
///
///
///
///////////

pub fn main() !void {
    rl.initWindow(900, 900, "Zig 0.17 + raylib GUI");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var expr_field: TextField = .{};
    var focused = false;

    var result_buf: [128]u8 = @splat(0);
    var output_msg: [:0]const u8 = "Enter Input";

    const field_rect: rl.Rectangle = .{ .x = 20, .y = 90, .width = 400, .height = 36 };
    const btn_rect: rl.Rectangle = .{ .x = 430, .y = 90, .width = 150, .height = 36 };
    //Update
    while (!rl.windowShouldClose()) {
        if (rl.isMouseButtonPressed(.left)) {
            focused = rl.checkCollisionPointRec(rl.getMousePosition(), field_rect);
        }
        if (focused) expr_field.handleInput();

        const clicked_but = button(btn_rect, "Calculate");
        const pressed_enter = focused and (rl.isKeyPressed(.enter) or rl.isKeyPressed(.kp_enter));

        if (clicked_but or pressed_enter) {
            const res = calc.calculate(expr_field.text());
            if (res) |value| {
                const printed = std.fmt.bufPrint(&result_buf, "Result : {d:.4}", .{value}) catch "too long";
                result_buf[printed.len] = 0;
                output_msg = result_buf[0..printed.len :0];
            } else |_| {
                output_msg = "invalid input";
            }
        }
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.ray_white);
        rl.drawText("Enter line", 20, 60, 16, .dark_gray);

        rl.drawRectangleRec(field_rect, .white);
        rl.drawRectangleLinesEx(field_rect, 2, if (focused) .blue else .gray);
        const shown = expr_field.text();
        rl.drawText(shown, 28, 98, font_size, .black);
        if (focused and @mod(rl.getTime(), 1.0) < 0.5) {
            rl.drawText("_", 28 + rl.measureText(shown, font_size), 98, font_size, .black);
        }
        rl.drawText(output_msg, 20, 160, font_size, .dark_blue);
    }
}
