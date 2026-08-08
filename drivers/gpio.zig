const utils = @import("lib").utils;

pub const BASE: usize = 0x3F000000;

pub const GPFSEL1: usize = (BASE + 0x00200004);
pub const GPSET0: usize = (BASE + 0x0020001C);
pub const GPSET1: usize = (BASE + 0x00200020);
pub const GPCLR0: usize = (BASE + 0x00200028);
pub const GPCLR1: usize = (BASE + 0x002000C);
pub const GPPUD: usize = (BASE + 0x00200094);
pub const GPPUDCLK0: usize = (BASE + 0x00200098);

pub const AUX_ENABLES: usize = (BASE + 0x00215004);
pub const AUX_MU_IO_REG: usize = (BASE + 0x00215040);
pub const AUX_MU_IER_REG: usize = (BASE + 0x00215044);
pub const AUX_MU_IIR_REG: usize = (BASE + 0x00215048);
pub const AUX_MU_LCR_REG: usize = (BASE + 0x0021504C);
pub const AUX_MU_MCR_REG: usize = (BASE + 0x00215050);
pub const AUX_MU_LSR_REG: usize = (BASE + 0x00215054);
pub const AUX_MU_MSR_REG: usize = (BASE + 0x00215058);
pub const AUX_MU_SCRATCH: usize = (BASE + 0x0021505C);
pub const AUX_MU_CNTL_REG: usize = (BASE + 0x00215060);
pub const AUX_MU_STAT_REG: usize = (BASE + 0x00215064);
pub const AUX_MU_BAUD: usize = (BASE + 0x00215068);

pub const Funcs = enum(u32) {
    INPUT = 0,
    OUTPUT = 1,
    ALT0 = 4,
    ALT1 = 5,
    ALT2 = 6,
    ALT3 = 7,
    ALT4 = 3,
    ALT5 = 2
};

pub fn setGpioFunc(gpio_pin: u32, func: Funcs) void {

    if (gpio_pin > 53) {
        return;
    }

    const multiplier: u32 = gpio_pin / 10;
    const last_digit: u32 = gpio_pin % 10;

    const FSEL_ADDR: usize = BASE + multiplier * 4;
    const start: u5 = @intCast(last_digit * 3);

    var selector: u32 = utils.read32(FSEL_ADDR);
    const shift_val: u32 = @intFromEnum(func);

    const sev: usize = 7;
    selector &= ~@as(u32, @intCast(sev << start));
    selector |= (shift_val << start);

    utils.write32(FSEL_ADDR, selector);
}

pub fn setGpio(gpio_pin: u32) void {
    if (gpio_pin > 53) {
        return;
    }

    const one: usize = 1;
    if (gpio_pin < 32) {
        const shift_amt: u6 = @intCast(gpio_pin);

        var selector: u32 = utils.read32(GPSET0);
        selector |= @as(u32, @intCast(one << shift_amt));
        utils.write32(GPSET0, selector);
    } else {
        const shift_amt: u6 = @intCast(gpio_pin - 31);
        
        var selector: u32 = utils.read32(GPSET1);
        selector |= @as(u32, @intCast(one << shift_amt)); 
        utils.write32(GPSET1, selector);
    }
}

pub fn clrGpio(gpio_pin: u32) void {
    if (gpio_pin > 53) {
        return;
    }

    const one: usize = 1;

    if (gpio_pin < 32) {
        const shift_amt: u6 = @intCast(gpio_pin);

        var selector: u32 = utils.read32(GPCLR0);
        selector |= @as(u32, @intCast(one << shift_amt));
        utils.write32(GPCLR0, selector);
    } else {
        const shift_amt: u6 = @intCast(gpio_pin - 31);

        var selector: u32 = utils.read32(GPCLR1);
        selector |= @as(u32, @intCast(one << shift_amt));
        utils.write32(GPCLR1, selector);
    }

}
