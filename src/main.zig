const uart = @import("mini_uart.zig");
const utils = @import("utils.zig");
const print = @import("print.zig");
const timer = @import("timer.zig");
const irq = @import("irq.zig");
const pong = @import("pong.zig");

export fn kernel_main() noreturn {
    uart.init();

    const num: u32 = utils.getEl();
    print.print("Hello World!\nCurrent exception layer: %d\r\n", .{num});

    irq.irq_vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable_irq();

    pong.start();
}
