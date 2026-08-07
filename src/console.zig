const muart = @import("drivers/mini_uart.zig");
const fuart = @import("drivers/full_uart.zig");

//var is_mini: bool = false;

const UartDriver = struct {
    send: *const fn (c: u8) void,
    sendInt: *const fn (num: u32) void,
    sendHex: *const fn (num: u32) void,
    sendStr: *const fn (str: []const u8) void,
};

pub const UartType = enum {full_uart, mini_uart};

var active_uart_driver: UartDriver = .{
    .send = fuart.send,
    .sendInt = fuart.sendInt,
    .sendHex = fuart.sendHex,
    .sendStr = fuart.sendStr
};

pub fn setUart(choice: UartType) void {
    switch (choice) {
        .mini_uart => {
            muart.init();
            active_uart_driver = .{
                .send = muart.send,
                .sendInt = muart.sendInt,
                .sendHex = muart.sendHex,
                .sendStr = muart.sendStr
            }; 
        },

        .full_uart => {
            fuart.init();
            active_uart_driver = .{
                .send = fuart.send,
                .sendInt = fuart.sendInt,
                .sendHex = fuart.sendHex,
                .sendStr = fuart.sendStr
            };
        },
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
                active_uart_driver.sendInt(val);
            }
        },
        'x' => {
            if (is_int) {
                const val: u32 = @truncate(value);
                active_uart_driver.sendHex(val);    
            }
        },
        's' => { 
            if (ty_info == .pointer) {
                const str: []const u8 = value; 
                active_uart_driver.sendStr(str);
            }
        },
        'c' => {
            if (is_int) {
                const val: u8 = @truncate(value);
                active_uart_driver.send(val);    
            }
        },
        else => {
            if (ty_info == .pointer) {
                const str: []const u8 = value; 
                active_uart_driver.sendStr(str);
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
                
                active_uart_driver.send(ch); 
            }
        }
    } 
}
