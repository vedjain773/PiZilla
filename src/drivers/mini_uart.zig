const gpios = @import("gpio.zig");
const utils = @import("../utils.zig");

pub fn init() void {
    gpios.setGpioFunc(14, gpios.Funcs.ALT5);
    gpios.setGpioFunc(15, gpios.Funcs.ALT5);

    utils.write32(gpios.GPPUD, 0);
    utils.delay(150);
    utils.write32(gpios.GPPUDCLK0, (1 << 14) | (1 << 15));
    utils.delay(150);
    utils.write32(gpios.GPPUDCLK0, 0);

    utils.write32(gpios.AUX_ENABLES, 1);
    utils.write32(gpios.AUX_MU_CNTL_REG, 0);
    utils.write32(gpios.AUX_MU_IER_REG, 0);
    utils.write32(gpios.AUX_MU_LCR_REG, 3);
    utils.write32(gpios.AUX_MU_MCR_REG, 0);
    utils.write32(gpios.AUX_MU_BAUD, 270);

    utils.write32(gpios.AUX_MU_CNTL_REG, 3);
}

pub fn recv() u8 {
    while (true) {
        // if the data is ready to be read, break out of the loop
        if ((utils.read32(gpios.AUX_MU_LSR_REG) & 0x01) != 0) {
            break;
        }
    }

    return @truncate(utils.read32(gpios.AUX_MU_IO_REG) & 0xFF);
}

pub fn crec() u8 {
    if ((utils.read32(gpios.AUX_MU_LSR_REG) & 0x01) == 0) {
        return @as(u8, 0);
    } else {
        return @truncate(utils.read32(gpios.AUX_MU_IO_REG) & 0xFF);
    }
}

pub fn send(c: u8) void {
    while (true) {
        // if the transmitter is empty, break from the loop
        if ((utils.read32(gpios.AUX_MU_LSR_REG) & 0x20) != 0) {
            break;
        }
    }

    utils.write32(gpios.AUX_MU_IO_REG, c);
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
    while (i < no_of_digits): (i += 1) {
        const last_digit: u32 = @rem(no, 10);
        digits[i] = last_digit;
        no = @divFloor(no, 10);
    }

    i = 0;
    while (i < no_of_digits): (i += 1) {
        const ch: c_char = @intCast('0' + digits[no_of_digits - 1 - i]);
        send(ch);
    }
}

pub fn sendHex(num: u32) void {
    const selector: u32 = 0b1111;
    var no: u32 = num;
    var i: usize = 0;

    var digits: [8]u32 = .{0, 0, 0, 0, 0, 0, 0, 0};

    while (i < 8): (i += 1) {
        const digit: u32 = no & selector;
        no = no >> 4;
        digits[7 - i] = digit;
    }
    
    i = 0;
    while (i < 8): (i += 1) {
        if (digits[i] < 10) {
            sendInt(digits[i]);
        } else {
            const diff: u32 = digits[i] - 10;
            const ch: u8 = @intCast('A' + diff);
            send(ch);
        }
    }
}

pub fn sendStr(str: []const u8) void {
    var i: usize = 0;

    while (i < str.len) : (i += 1) {
        const ch: u8 = @intCast(str[i]);
        send(ch);
    }
}
