const uart = @import("mini_uart.zig");
const fuart = @import("uart.zig");

var is_mini: bool = false;

pub fn setUart(choice: u32) void {
    if (choice == 0) {
        is_mini = true;
        uart.init();
    } else {
        is_mini = false;
        fuart.init();
    }
}

fn callUart(c: u8, value: anytype) void {
    const ty: type = @TypeOf(value);
    const ty_info = @typeInfo(ty);
    const is_int: bool = ty == comptime_int or ty_info == .int;

    switch (c) {
        'd' => {
            if (is_int) {
                const val: u32 = @truncate(value);
                if (is_mini) {
                    uart.sendInt(val);   
                } else {
                    fuart.sendInt(val);
                }
            }
        },
        'x' => {
            if (is_int) {
                const val: u32 = @truncate(value);
                
                if (is_mini) {
                    uart.sendHex(val);
                } else {
                    fuart.sendHex(val);
                }
            }
        },
        's' => { 
            if (ty_info == .pointer) {
                const str: []const u8 = value; 
                
                if (is_mini) {
                    uart.sendString(str);
                } else {
                    fuart.sendStr(str);
                }
            }
        },
        'c' => {
            if (is_int) {
                const val: u8 = @truncate(value);
                
                if (is_mini) {
                    uart.send(val);
                } else {
                    fuart.send(val);
                }
            }
        },
        else => {
            if (ty_info == .pointer) {
                const str: []const u8 = value;
                
                if (is_mini) {
                    uart.sendString(str);
                } else {
                    fuart.sendStr(str);
                }
            }
        }
    }
}

pub fn print(comptime str: []const u8, args: anytype) void {

    comptime var next_arg: usize = 0;

    inline for (str, 0..) |c, i| {
        switch (c) {
            '%' => {
                const ch: u8 = @intCast(str[i+1]);
                callUart(ch, args[next_arg]);

                next_arg += 1;
            },
            else => {
                if (i > 0) {
                    if (str[i - 1] == '%') {
                        continue;
                    }
                }

                const ch: u8 = @intCast(c);
                
                if (is_mini) {
                    uart.send(ch);
                } else {
                    fuart.send(ch);
                }
            }
        }
    } 
}
