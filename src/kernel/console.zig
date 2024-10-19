const builtin = @import("builtin");
const limine = @import("limine");
const std = @import("std");
const font = @import("font8x8_basic.zig");

pub fn print(framebuffer: *limine.Framebuffer, text: []const u8, x: ?u8, y: ?u8) void {
    // Static cursor position
    var cursor_x: u64 = x orelse 1;
    var cursor_y: u64 = y orelse 1;

    const font_width: u64 = 8; // Font width for each character (fixed-size)
    const font_height: u64 = 8; // Adjusted to 8x8 font size

    for (text) |char| {
        if (char == '\n') {
            // Move cursor to the next line on newline character
            cursor_x = 0;
            cursor_y += font_height;
            continue;
        }

        // If we run out of horizontal space, move to the next line
        if (cursor_x + font_width > framebuffer.width) {
            cursor_x = 0;
            cursor_y += font_height;
        }

        // If we run out of vertical space, stop printing
        if (cursor_y + font_height > framebuffer.height) {
            break;
        }

        // Get the bitmap for the current character
        const char_bitmap = font.font8x8_basic[char & 0x7F]; // Masking with 0x7F to handle ASCII characters

        // Render the character pixel by pixel
        for (0..font_height) |row| {
            const row_bits = char_bitmap[row]; // Get the bits for the current row

            for (0..font_width) |col| {
                const is_pixel_set = (row_bits >> @as(u3, @intCast(col))) & 1; // Cast col to u3 before shifting

                if (is_pixel_set == 1) {
                    const pixel_offset = (cursor_y + row) * framebuffer.pitch + (cursor_x + col) * 4;
                    const color_value = 0xFFFFFF; // White color for simplicity

                    // Write the pixel value to the framebuffer (assuming 32-bit color depth)
                    @as(*u32, @ptrCast(@alignCast(framebuffer.address + pixel_offset))).* = color_value;
                }
            }
        }

        // Move the cursor to the next character's position
        cursor_x += font_width;
    }
}
