const utils = @import("utils.zig");
const print = @import("print.zig");
const timer = @import("timer.zig");
const irq = @import("irq.zig");
const pong = @import("pong.zig");
const panic_handler = @import("panic.zig");

pub const panic = panic_handler.PanicHandler;

export fn kernel_main() noreturn {
    const num: u32 = utils.getEl();

    print.setUart(print.UartType.full_uart);
    print.print("Exception-level: %x\n", .{num});

    irq.irq_vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable_irq(); 
   
    print.print("Hello World!, %s\n", .{"Ved"});
    pong.start();    
}
