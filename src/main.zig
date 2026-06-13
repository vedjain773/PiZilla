const utils = @import("utils.zig");
const print = @import("print.zig");
const timer = @import("timer.zig");
const irq = @import("irq.zig");
const pong = @import("pong.zig");
const mm = @import("mm.zig");
const panic_handler = @import("panic.zig");

pub const panic = panic_handler.PanicHandler;

export fn kernel_main() void {
    const num: u32 = utils.getEl();

    print.setUart(print.UartType.full_uart);
    print.print("Exception-level: %d\n", .{num});

    irq.irq_vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable_irq(); 
   
    const A: usize = mm.kMalloc();
    const B: usize = mm.kMalloc();

    print.print("A: 0x%x\n", .{A});
    print.print("B: 0x%x\n", .{B});

    mm.kFree(A);
    const C: usize = mm.kMalloc();
    print.print("C: 0x%x\n", .{C});
    //pong.start();
}
