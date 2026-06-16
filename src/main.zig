const full_uart = @import("full_uart.zig");
const utils = @import("utils.zig");
const print = @import("print.zig");
const timer = @import("timer.zig");
const irq = @import("irq.zig");
const pong = @import("pong.zig");
const panic_handler = @import("panic.zig");
const fork = @import("fork.zig");
const schedule = @import("schedule.zig");

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

    print.setUart(print.UartType.full_uart);
    print.print("Exception-level: %d\n", .{num});

    irq.irq_vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable_irq(); 
   
    //pong.start();
    schedule.initTasks();

    var res: i32 = fork.copyProcess(@intFromPtr(&process), @intFromPtr("abcde"));
    if (res != 0) {
        print.print("Error while creating process 1", .{});
    }

    res = fork.copyProcess(@intFromPtr(&process), @intFromPtr("12345"));
    if (res != 0) {
        print.print("Error while creating process 2", .{});
    }

    while(true) {
        schedule.schedule();
    }
}
