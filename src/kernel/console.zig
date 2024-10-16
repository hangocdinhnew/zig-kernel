const builtin = @import("builtin");
const limine = @import("limine");
const std = @import("std");

pub fn print(framebuffer: *limine.Framebuffer, text: []const u8, x: ?u8, y: ?u8) void {
    // Static cursor position
    var cursor_x: u64 = x orelse 1;
    var cursor_y: u64 = y orelse 1;

    const font_width: u64 = 8; // Font width for each character (fixed-size)
    const font_height: u64 = 16; // Font height for each character (fixed-size)

    for (text) |char| {
        if (char == '\n') {
            // Move cursor to the next line on newline character
            cursor_x = 0;
            cursor_y += font_height;
            continue;
        }

        // If we run out of horizontal space, move to the next line
        if (cursor_x >= framebuffer.width) {
            cursor_x = 0;
            cursor_y += font_height;
        }

        // If we run out of vertical space, stop printing
        if (cursor_y >= framebuffer.height) {
            break;
        }

        // Render the character here - this is where you'd plug in an actual font rendering system
        // Instead, we'll just use a simplified placeholder (white block for each character)

        // Pixel offset calculation (assuming a 32-bit color format, 4 bytes per pixel)
        for (0..font_height) |row| {
            for (0..font_width) |col| {
                const pixel_offset = (cursor_y + row) * framebuffer.pitch + (cursor_x + col) * 4;
                const color_value = 0xFFFFFF; // White color for simplicity

                // Write the pixel value to the framebuffer (assuming 32-bit color depth)
                @as(*u32, @ptrCast(@alignCast(framebuffer.address + pixel_offset))).* = color_value;
            }
        }

        // Move the cursor to the next character's position
        cursor_x += font_width;
    }
}
