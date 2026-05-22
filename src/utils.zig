pub fn delay(time: usize) void {
    var i: usize = time;
    while (i != 0) {
        i = i - 1;
    }
}

pub fn read32(addr: usize) u32 {
    const ptr = @as(*volatile u32, @ptrFromInt(addr));
    return ptr.*;
}

pub fn write32(addr: usize, value: u32) void {
    const ptr = @as(*volatile u32, @ptrFromInt(addr));
    ptr.* = value;
}

pub fn getEl() u32 {
    var el: u32 = 0;

    asm volatile (//syscall
        "mrs %[result], CurrentEL"
        : [result] "=r" (el)
        :
    );

    el = el >> 2;
    return el;
}
