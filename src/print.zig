const uart = @import("mini_uart.zig");

pub fn print(str: [*c]const u8, ) void {
    var i: usize = 0;
    while (str[i] != 0) {
        const ch: c_char = @intCast(str[i]);
        
        if (ch == '{') {
            i += 1;

            if (str[i + 1] == 'd') {

            } else if (str[i + 1] == 'x') {

            } else if (str[i + 1] == 's') {

            } else if (str[i + 1] == 'c') {

            }

        } else {
            uart.send(ch);
        }

        i += 1;
    }
}
