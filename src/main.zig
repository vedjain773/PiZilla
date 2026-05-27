const uart = @import("mini_uart.zig");
const fuart = @import("uart.zig");
const utils = @import("utils.zig");
const print = @import("print.zig");
const timer = @import("timer.zig");
const irq = @import("irq.zig");
const pong = @import("pong.zig");

export fn kernel_main() noreturn {
    const num: u32 = utils.getEl();

    print.setUart(1);
    print.print("Exception-level: %x\n", .{num});

    print.setUart(0);
    print.print("Exception-level: %x\n", .{num});

    irq.irq_vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable_irq(); 
    
    pong.start();
}
