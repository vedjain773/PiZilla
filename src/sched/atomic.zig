pub extern fn load(addr: *usize) usize;
pub extern fn store(addr: *usize, value: usize) void;
pub extern fn compare_and_swap(addr: *usize, old: usize, new: usize) bool;
