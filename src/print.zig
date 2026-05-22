const uart = @import("mini_uart.zig");

fn callUart(c: c_char, value: anytype) void {
    const ty: type = @TypeOf(value);
    const ty_info = @typeInfo(ty);
    const is_int: bool = ty == comptime_int or ty_info == .int;

    switch (c) {
        'd' => {
            if (is_int) {
                const val: c_int = @as(c_int, value);
                uart.sendInt(val);   
            }
        },
        'x' => {
            if (is_int) {
                uart.sendHex(value);
            }
        },
        's' => { 
            if (ty_info == .pointer) {
                const str: []const u8 = value; 
                uart.sendString(str);
            }
        },
        'c' => {
            if (is_int and ty != c_int) {
                const val: c_char = @truncate(value);
                uart.send(val);
            }
        },
        else => {
            if (ty_info == .pointer) {
                const str: []const u8 = value;
                uart.sendString(str);
            }
        }
    }
}

pub fn print(comptime str: []const u8, args: anytype) void {

    comptime var next_arg: usize = 0;

    inline for (str, 0..) |c, i| {
        switch (c) {
            '%' => {
                const ch: c_char = @intCast(str[i+1]);
                callUart(ch, args[next_arg]);

                next_arg += 1;
            },
            else => {
                if (i > 0) {
                    if (str[i - 1] == '%') {
                        continue;
                    }
                }

                const ch: c_char = @intCast(c);
                uart.send(ch);
            }
        }
    } 
}
