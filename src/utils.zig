pub fn delay(time: c_ulong) void {
    var i: usize = time;
    while (i != 0) {
        i = i - 1;
    }
}

pub fn read32(addr: c_ulong) c_uint {
    const ptr = @as(*volatile u32, @ptrFromInt(addr));
    return ptr.*;
}

pub fn write32(addr: c_ulong, value: c_uint) void {
    const ptr = @as(*volatile u32, @ptrFromInt(addr));
    ptr.* = value;
}
