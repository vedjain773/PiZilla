const uart = @import("mini_uart.zig");
const utils = @import("utils.zig");
const print = @import("print.zig");
const timer = @import("timer.zig");
const irq = @import("irq.zig");
const framebuffer = @import("framebuffer.zig");

export fn kernel_main() void {
    uart.init();

    const num: u32 = utils.getEl();
    print.print("Hello World!\nCurrent exception layer: %d\r\n", .{num});

    framebuffer.init_fb();

    irq.irq_vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable_irq();
}
