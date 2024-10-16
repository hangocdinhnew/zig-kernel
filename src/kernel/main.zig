const lib = @import("lib.zig");

// The following will be our kernel's entry point.
export fn _start() callconv(.C) noreturn {
    // Ensure the bootloader actually understands our base revision (see spec).
    if (!lib.base_revision.is_supported()) {
        lib.done();
    }

    // Ensure we got a framebuffer.
    if (lib.framebuffer_request.response) |framebuffer_response| {
        if (framebuffer_response.framebuffer_count < 1) {
            lib.done();
        }

        // Get the first framebuffer's information.
        const framebuffer = framebuffer_response.framebuffers()[0];

        lib.console.print(framebuffer, "Hello, World!", 50, 50);
    }

    // We're done, just hang...
    lib.done();
}
