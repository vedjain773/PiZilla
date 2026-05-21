const gpios = @import("gpio.zig");
const utils = @import("utils.zig");

pub fn init() void {
    var selector: c_uint = 0;

    selector = utils.read32(gpios.GPFSEL1);
    selector &= ~@as(c_uint, 7 << 12); // clear GPIO 14
    selector |= (2 << 12); // set GPIO 14 to work in ALT FUNC 5

    selector &= ~@as(c_uint, 7 << 15); // clear GPIO 15
    selector |= (2 << 15); // set GPIO 15 to work in ALT FUNC 5

    utils.write32(gpios.GPFSEL1, selector);

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

pub fn recv() c_char {
    while (true) {
        // if the data is ready to be read, break out of the loop
        if ((utils.read32(gpios.AUX_MU_LSR_REG) & 0x01) != 0) {
            break;
        }
    }

    return utils.read32(gpios.AUX_MU_IO_REG & 0xFF);
}

pub fn send(c: c_char) void {
    while (true) {
        // if the transmitter is empty, break from the loop
        if ((utils.read32(gpios.AUX_MU_LSR_REG) & 0x20) != 0) {
            break;
        }
    }

    utils.write32(gpios.AUX_MU_IO_REG, c);
}

pub fn sendInt(num: c_int) void {
    var no_of_digits: usize = 0;
    var no: c_int = num;

    while (no != 0) {
        no = @divFloor(no, 10);
        no_of_digits += 1;
    }

    var digits: [20]c_int = undefined;

    var i: usize = 0;
    no = num;
    while (i < no_of_digits) {
        const last_digit: c_int = @rem(no, 10);
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

pub fn sendHex(num: c_int) void {
    const selector: c_int = 0b1111;
    var no: c_int = num;

    var digits: [8]c_int = undefined;

    var i: usize = 0;
    while (i < 8) {
        const digit: c_int = no & selector;
        no = no >> 4;
        digits[7 - i] = digit;

        i += 1;
    }

    i = 0;
    while (i < 8) {
        if (digits[i] < 10) {
            sendInt(digits[i]);
        } else {
            const diff: c_int = digits[i] - 10;
            const ch: c_char = @intCast('A' + diff);
            send(ch);
        }

        i += 1;
    }
}

pub fn sendString(str: [*c]const u8) void {
    var i: usize = 0;

    while (str[i] != 0) : (i += 1) {
        send(str[i]);
    }
}
