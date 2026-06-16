const full_uart = @import("full_uart.zig");
const utils = @import("utils.zig");
const console = @import("console.zig");
const timer = @import("timer.zig");
const irq = @import("irq.zig");
const pong = @import("pong.zig");
const panic_handler = @import("panic.zig");
const fork = @import("fork.zig");
const scheduler = @import("scheduler.zig");

pub const panic = panic_handler.PanicHandler;

fn process(msg: []u8) noreturn {
    while (true) {
        for (msg) |c| {
            full_uart.send(c);
            utils.delay(1000000);
        }
    }
}

export fn kernel_main() noreturn {
    const num: u32 = utils.getEl();

    console.setUart(console.UartType.full_uart);
    console.print("Exception-level: %d\n", .{num});

    irq.vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable(); 
   
    //pong.start();
    scheduler.initTasks();

    var res: i32 = fork.copyProcess(@intFromPtr(&process), @intFromPtr("abcde"));
    if (res != 0) {
        console.print("Error while creating process 1", .{});
    }

    res = fork.copyProcess(@intFromPtr(&process), @intFromPtr("12345"));
    if (res != 0) {
        console.print("Error while creating process 2", .{});
    }

    while(true) {
        scheduler.schedule();
    }
}
