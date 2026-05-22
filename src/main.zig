const uart = @import("mini_uart.zig");
const utils = @import("utils.zig");
const print = @import("print.zig");

export fn kernel_main() void {
    uart.init();

    const num: c_int = utils.getEl();
    print.print("Hello World!\nCurrent exception layer: %d\r\n", .{num});
}
