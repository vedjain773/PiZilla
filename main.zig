const timer = @import("irq").timer;
const irq = @import("irq").irq;

const console = @import("drivers").console;

const utils = @import("lib").utils;

const fork = @import("sched").fork;
const scheduler = @import("sched").scheduler;

const panic_handler = @import("panic.zig");
const test_spin = @import("tests/spinlock.zig");
const pong_clock = @import("tests/pong_clock.zig");

pub const panic = panic_handler.PanicHandler;

export fn kernel_main() noreturn {
    const num: u32 = utils.getEl();

    console.setUart(console.UartType.mini_uart);
    console.print("Exception-level: %d\n", .{num});

    irq.vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable();  

    scheduler.initTasks(); 

    test_spin.run(); 
        
    while(true) {
        scheduler.schedule();
    }
}
