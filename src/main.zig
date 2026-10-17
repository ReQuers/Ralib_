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

pub fn main() !void {
    rl.initWindow(640, 360, "Zig 0.17 + raylib GUI");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var name: TextField = .{};
    var focused = false;
    var clicks: u32 = 0;

    const field_rect: rl.Rectangle = .{ .x = 20, .y = 90, .width = 300, .height = 36 };
    const btn_rect: rl.Rectangle = .{ .x = 20, .y = 150, .width = 140, .height = 36 };

    //Update
    while (!rl.windowShouldClose()) {
        if (rl.isMouseButtonPressed(.left)) {
            focused = rl.checkCollisionPointRec(rl.getMousePosition(), field_rect);
        }
        if (focused) name.handleInput();

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.ray_white);
        rl.drawText("Your name:", 20, 60, font_size, .dark_gray);

        rl.drawRectangleRec(field_rect, .white);
        rl.drawRectangleLinesEx(field_rect, 2, if (focused) .blue else .gray);
        const shown = name.text();
        rl.drawText(shown, 28, 98, font_size, .black);
        if (focused and @mod(rl.getTime(), 1.0) < 0.5) {
            rl.drawText("_", 28 + rl.measureText(shown, font_size), 98, font_size, .black);
        }

        if (button(btn_rect, "Click me")) clicks += 1;

        var out: [128]u8 = undefined;
        const printed = std.fmt.bufPrint(&out, "Hello, {s}! Clicks: {d}", .{ shown, clicks }) catch "too long";
        out[printed.len] = 0;
        const msg: [:0]const u8 = out[0..printed.len :0];

        rl.drawText(msg, 20, 220, font_size, .dark_blue);
    }
}
