const gpios = @import("gpio.zig");
const print = @import("print.zig");
const utils = @import("utils.zig");

const BASE: usize = gpios.BASE;

pub const TIMER_CS: usize = (BASE+0x00003000);
pub const TIMER_CLO: usize = (BASE+0x00003004);
pub const TIMER_CHI: usize = (BASE+0x00003008);
pub const TIMER_C0: usize = (BASE+0x0000300C);
pub const TIMER_C1: usize = (BASE+0x00003010);
pub const TIMER_C2: usize = (BASE+0x00003014);
pub const TIMER_C3: usize = (BASE+0x00003018);

pub const TIMER_CS_M0: u32 = (1 << 0);
pub const TIMER_CS_M1: u32 = (1 << 1);
pub const TIMER_CS_M2: u32 = (1 << 2);
pub const TIMER_CS_M3: u32 = (1 << 3);

const interval: u32 = 200000;
var curr_val: u32 = 0;

pub fn timerInit() void {
    curr_val = utils.read32(TIMER_CLO);
    curr_val += interval;
    utils.write32(TIMER_C1, curr_val);
}

pub fn handleTimerIrq() void {
    curr_val += interval;
    utils.write32(TIMER_C1, curr_val);

    utils.write32(TIMER_CS, TIMER_CS_M1);
    print.print("Timer interrupt received!\n", .{});
}
