const gpios = @import("gpio.zig");
const utils = @import("utils.zig");

const base = gpios.BASE;
const uart_base = base + 0x00201000;

const UART_DR: usize = uart_base + 0x0;
const UART_FR: usize = uart_base + 0x18;
const UART_IBRD: usize = uart_base + 0x24;
const UART_FBRD: usize = uart_base + 0x28;
const UART_LCRH: usize = uart_base + 0x2c;
const UART_CR: usize = uart_base + 0x30;
const UART_IMSC: usize = uart_base + 0x38;
const UART_ICR: usize = uart_base + 0x44;

pub fn init() void {
    gpios.setGpioFunc(14, gpios.Funcs.ALT0);
    gpios.setGpioFunc(15, gpios.Funcs.ALT0);

    utils.write32(gpios.GPPUD, 0);
    utils.delay(150);
    utils.write32(gpios.GPPUDCLK0, (1 << 14) | (1 << 15));
    utils.delay(150);
    utils.write32(gpios.GPPUDCLK0, 0);

    utils.write32(UART_CR, 0);
    
    //clear all interrupts
    const clr_int: u32 = 0x7FF; 
    utils.write32(UART_ICR, clr_int);

    utils.write32(UART_IBRD, 26);
    utils.write32(UART_FBRD, 3);

    //enable FIFO and 8bit-words
    utils.write32(UART_LCRH, 0b01110000);
    
    //enable UART, TXE, RXE
    const cfg: u32 = 0b1100000001;
    utils.write32(UART_CR, cfg);
}

pub fn recv() u8 {
    while (true) {
        if ((utils.read32(UART_FR) & 0x40) != 0) {
            break;
        }
    }
    
    return @truncate(utils.read32(UART_DR) & 0xFF);
}

pub fn send(ch: u8) void {
     while (true) {
        if ((utils.read32(UART_FR) & 0x80) != 0) {
            break;
        }
     } 
    
    utils.write32(UART_DR, ch);
}

pub fn sendInt(num: u32) void {
    var no_of_digits: usize = 0;
    var no: u32 = num;
    
    if (no == 0) {
        send('0');
        return;
    }

    while (no != 0) {
        no = @divFloor(no, 10);
        no_of_digits += 1;
    }

    var digits: [20]u32 = undefined;

    var i: usize = 0;
    no = num;
    while (i < no_of_digits) {
        const last_digit: u32 = @rem(no, 10);
        digits[i] = last_digit;
        no = @divFloor(no, 10);
        i += 1;
    }

    i = 0;
    while (i < no_of_digits) {
        const ch: c_char = @intCast('0' + digits[no_of_digits - 1 - i]);
        send(ch);
        i += 1;
    }
}

pub fn sendHex(num: u32) void {
    const selector: u32 = 0b1111;
    var no: u32 = num;
    var i: usize = 0;

    var digits: [8]u32 = .{0, 0, 0, 0, 0, 0, 0, 0};

    while (i < 8) {
        const digit: u32 = no & selector;
        no = no >> 4;
        digits[7 - i] = digit;

        i += 1;
    }
    
    i = 0;
    while (i < 8) {
        if (digits[i] < 10) {
            sendInt(digits[i]);
        } else {
            const diff: u32 = digits[i] - 10;
            const ch: u8 = @intCast('A' + diff);
            send(ch);
        }

        i += 1;
    }
}

pub fn sendStr(str: []const u8) void {
    var i: usize = 0;

    while (i < str.len) : (i += 1) {
        send(str[i]);
    }
}


