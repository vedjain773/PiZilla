const console = @import("console.zig");
const utils = @import("utils.zig");
const timer = @import("irq/timer.zig");
const irq = @import("irq/irq.zig");
const pong = @import("apps/pong.zig");
const clock = @import("apps/clock.zig");
const panic_handler = @import("panic.zig");
const fork = @import("sched/fork.zig");
const scheduler = @import("sched/scheduler.zig");

pub const panic = panic_handler.PanicHandler;

export fn kernel_main() noreturn {
    const num: u32 = utils.getEl();

    console.setUart(console.UartType.mini_uart);
    console.print("Exception-level: %d\n", .{num});

    irq.vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable();  
   
    //pong.start();
    scheduler.initTasks();

    fork.copyProcess(@intFromPtr(&pong.start), @intFromPtr("abcde")) 
        catch console.print("Error while trying to start process 1\n", .{});
   
    fork.copyProcess(@intFromPtr(&clock.update), @intFromPtr("clock"))
        catch console.print("Error while trying to start process 2\n", .{});
    
    while(true) {
        scheduler.schedule();
    }
}
