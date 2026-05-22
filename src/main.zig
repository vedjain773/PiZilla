const uart = @import("mini_uart.zig");
const print = @import("print.zig");

export fn kernel_main() void {
    uart.init();
    print.print("Hello World %s ! %d \r\n", .{"from Zig", 5});
}
