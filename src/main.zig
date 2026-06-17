const console = @import("console.zig");
const utils = @import("utils.zig");
const timer = @import("timer.zig");
const irq = @import("irq.zig");
const pong = @import("pong.zig");
const clock = @import("clock.zig");
const panic_handler = @import("panic.zig");
const fork = @import("fork.zig");
const scheduler = @import("scheduler.zig");

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
