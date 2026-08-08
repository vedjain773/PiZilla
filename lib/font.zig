const fb = @import("drivers").framebuffer;

const glyphs: [26]u64 = .{
    0x818181ff81422418,
    0x7f81817f418181ff,
    0xff010101010101ff,
    0x7f8181818181817f,
    0xff0101017f0101ff,
    0xff0101017f0101ff,
    0xff818181790101ff,
    0x81818181ff818181,
    0xff080808080808ff,
    0x0e090808080808ff,
    0x1109050303050911,
    0xff01010101010101,
    0x8181818199a5c381,
    0x81c1a19189858381,
    0xff818181818181ff,
    0x01010101ff8181ff,
    0xffc1a191818181ff,
    0x81412111ff8181ff,
    0xff808080ff0101ff,
    0x08080808080808ff,
    0x3c42818181818181,
    0x1824428181818181,
    0x81c3a59981818181,
    0x8142241818244281,
    0x0808080808142241,
    0xff020408382040ff,
};

const digit_glyphs: [10]u64 = .{
    0x3c42464a5262423c,
    0x3e080808080a0c08,
    0x7e0202027e40407e,
    0x7e4040407e40407e,
    0x404040407e424242,
    0x7e4040407e02027e,
    0x7e4242427e02027e,
    0x202020207820203e,
    0x3c4242423c42423c,
    0x3c4240407e42427e,
};

pub fn renderGlyph(x: u32, y: u32, id: usize) void {
    var fg: u64 = glyphs[id];
    const selector: u64 = 0x1;

    var i: usize = 0;

    while (i < 64): (i += 1) {
        if (fg & selector == 0x1) {
            const col: u32 = @truncate(i % 8);
            const row: u32 = @truncate(@divFloor(i, 8));
            fb.drawPixel(x + col, y + row);
        }
        
        fg = fg >> 1;
    }
}

pub fn renderDigit(x: u32, y: u32, id: u32) void {
    var ng: u64 = digit_glyphs[id];
    const selector: u64 = 0x1;

    var i: usize = 0;

    while (i < 64): (i += 1) {
        if (ng & selector == 0x1) {
            const col: u32 = @truncate(i % 8);
            const row: u32 = @truncate(@divFloor(i, 8));
            fb.drawPixel(x + col, y + row);
        }
        
        ng = ng >> 1;
    }

}

pub fn renderInt(x: u32, y: u32, num: u32) void {
    var no_of_digits: usize = 0;
    var no: u32 = num;
    
    if (no == 0) {
        renderDigit(x, y, 0);
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
    var x_s: u32 = x;
    while (i < no_of_digits): (i += 1) {
        renderDigit(x_s, y, digits[i]);
        x_s += 9;
    }
}

pub fn renderChar(x: u32, y: u32, ch: u8) void {
    const id: usize = @as(usize, ch) - 'A';
    renderGlyph(x, y, id);
}

pub fn renderStr(x: u32, y: u32, msg: []const u8) void {
    var i: usize = 0;
    var x_s: u32 = x;
    while (i < msg.len): (i += 1) {
        const ch: u8 = @intCast(msg[i]);
        renderChar(x_s, y, ch);
        x_s += 9;
    } 
}

pub fn clearGlyph(x: u32, y: u32) void {
    var i: usize = 0;

    while (i < 64): (i += 1) {
        const col: u32 = @truncate(i % 8);
        const row: u32 = @truncate(@divFloor(i, 8));
        fb.drawBlankPix(x + col, y + row);    
    }

}
