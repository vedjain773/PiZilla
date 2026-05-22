pub fn delay(time: usize) void {
    var i: usize = time;
    while (i != 0) {
        i = i - 1;
    }
}

pub fn read32(addr: usize) i32 {
    const ptr = @as(*volatile i32, @ptrFromInt(addr));
    return ptr.*;
}

pub fn write32(addr: usize, value: i32) void {
    const ptr = @as(*volatile i32, @ptrFromInt(addr));
    ptr.* = value;
}

pub fn getEl() i32 {
    var el: i32 = 0;

    asm volatile (//syscall
        "mrs %[result], CurrentEL"
        : [result] "=r" (el)
        :
    );

    el = el >> 2;
    return el;
}
