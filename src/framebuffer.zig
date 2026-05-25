const print = @import("print.zig");
const mailbox = @import("mailbox.zig");

const ALLOC: u32 = 0x00040001;
const RELEASE: u32 = 0x00048001;
const BLANK_SCREEN: u32 = 0x00040002;
const SET_PHYHW: u32 = 0x00048003;
const SET_VIRTHW: u32 = 0x00048004;
const SET_DEPTH: u32 = 0x00048005;
const SET_PIXODR: u32 = 0x00048006;
const GET_PITCH: u32 = 0x00040008;

var height: u32 = 0;
var width: u32 = 0;
var pitch: u32 = 0;
var isrgb: u32 = 0;
var fb: [*]u32 = undefined; 

pub fn init_fb() void {
    var mb_buf: [30]u32 align(16) = undefined;
    const mb_ptr: *[30]u32 = &mb_buf;

    mb_ptr[0] = 30 * 4;
    mb_ptr[1] = mailbox.REQUEST_CODE;

    mb_ptr[2] = SET_PHYHW;
    mb_ptr[3] = 8;
    mb_ptr[4] = 0;
    mb_ptr[5] = 640;
    mb_ptr[6] = 480;

    mb_ptr[7] = SET_VIRTHW;
    mb_ptr[8] = 8;
    mb_ptr[9] = 0;
    mb_ptr[10] = 640;
    mb_ptr[11] = 480;

    mb_ptr[12] = SET_DEPTH;
    mb_ptr[13] = 4;
    mb_ptr[14] = 0;
    mb_ptr[15] = 32;

    mb_ptr[16] = SET_PIXODR;
    mb_ptr[17] = 4;
    mb_ptr[18] = 0;
    mb_ptr[19] = 1;

    mb_ptr[20] = ALLOC;
    mb_ptr[21] = 8;
    mb_ptr[22] = 0;
    mb_ptr[23] = 4096;
    mb_ptr[24] = 0;

    mb_ptr[25] = GET_PITCH;
    mb_ptr[26] = 4;
    mb_ptr[27] = 0;
    mb_ptr[28] = 0;

    mb_ptr[29] = mailbox.END_TAG;

    if (mailbox.mailboxCall(mb_ptr, mailbox.MAILBOX_CH_PROP)) {
        mb_ptr[23] &= 0x3fffffff;
        width = mb_ptr[5];
        height = mb_ptr[6];
        pitch = mb_ptr[28];
        isrgb = mb_ptr[19];
        fb = @ptrFromInt(mb_buf[23]);

        print.print("Width: %d\n", .{width});
        print.print("Height: %d\n", .{height});
        print.print("Pitch: %d\n", .{pitch});
        print.print("isRGB: %d\n", .{isrgb});
    }
}

pub fn drawPixel(x: u32, y: u32) void {
    if (x > width or y > height)
        return;

    const offset: u32 = (y * 640) + x;
    fb[offset] = 0xffffffff;
}

pub fn drawLineH(x1: u32, x2: u32, y: u32) void {
    for (x1..x2) |i| {
        const i_32: u32 = @intCast(i);
        drawPixel(i_32, y);
    }
}

pub fn drawLineV(y1: u32, y2: u32, x: u32) void {
    for (y1..y2) |j| {
        const j_u32: u32 = @intCast(j);
        drawPixel(x, j_u32);
    }
}

pub fn drawRectangle(x1: u32, y1: u32, x2: u32, y2: u32) void {
    drawLineH(x1, x2, y1);
    drawLineH(x1, x2, y2);

    drawLineV(y1, y2, x1);
    drawLineV(y1, y2, x2);
}
