const gpios = @import("gpio.zig");
const utils = @import("utils.zig");

const BASE = gpios.BASE;

const MAILBOX_BASE: usize = (BASE+0x0000b880);

const MAILBOX_READ: usize = (MAILBOX_BASE);
const MAILBOX_STATUS: usize = (MAILBOX_BASE+0x00000018);
const MAILBOX_WRITE: usize = (MAILBOX_BASE+0x00000020);

const MAILBOX_EMPTY: usize = 0x40000000;
const MAILBOX_FULL: usize = 0x80000000;

pub const REQUEST_CODE: u32 = 0x00000000;
pub const REQUEST_SUCCEED: u32 = 0x80000000;
pub const REQUEST_FAILED: u32 = 0x80000001;
pub const END_TAG: u32 = 0x00000000;

pub const MAILBOX_CH_POWER: u32 = 0;
pub const MAILBOX_CH_FB: u32 = 1;
pub const MAILBOX_CH_VUART: u32 = 2;
pub const MAILBOX_CH_VCHIQ: u32 = 3;
pub const MAILBOX_CH_LEDS: u32 = 4;
pub const MAILBOX_CH_BTNS: u32 = 5;
pub const MAILBOX_CH_TOUCH: u32 = 6;
pub const MAILBOX_CH_COUNT: u32 = 7;
pub const MAILBOX_CH_PROP: u32 = 8;

pub fn mailboxCall(mb_buf: [*]u32, ch: u32) bool {
    const to_and: u32 = @intCast(0xF);
    const mb_buff_i: u32 = @intCast(@intFromPtr(&mb_buf[0]));

    const r: u32 = ((mb_buff_i & ~to_and) | (ch & to_and));

    while ((utils.read32(MAILBOX_STATUS) & MAILBOX_FULL) != 0) {
        //wait
    }

    utils.write32(MAILBOX_WRITE, r);

    while (true) {
        while ((utils.read32(MAILBOX_STATUS) & MAILBOX_EMPTY) != 0) {
            //wait
        }

        if (r == utils.read32(MAILBOX_READ)) {
            return (mb_buf[1] == REQUEST_SUCCEED);
        }
    }

    return false;
}
