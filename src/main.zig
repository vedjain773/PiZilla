const uart = @import("mini_uart.zig");

export fn kernel_main() void {
    uart.init();
    uart.sendString("Hello World!\r\n");
}
