const print = @import("print.zig");
const muart = @import("mini_uart.zig");
const fuart = @import("full_uart.zig");

pub const PanicHandler = struct {
    pub fn call(msg: []const u8, ret_addr: ?usize) noreturn {
        _ = ret_addr;

        print.setUart(print.UartType.full_uart);
        print.print("Panic!: ", .{});
        
        for (msg) |c| {
            fuart.send(c);
        }
        
        print.print("\n", .{});
        while (true) {}
    }

    pub fn castToNull() noreturn {
        while (true) {}
    }

    pub fn copyLenMismatch() noreturn {
        while (true) {}
    }
    
    pub fn corruptSwitch() noreturn {
        while (true) {}
    }

    pub fn divideByZero() noreturn {
        while (true) {}
    }

    pub fn exactDivisionRemainder() noreturn {
        while (true) {}
    }

    pub fn forLenMismatch() noreturn {
        while (true) {}
    }

    pub fn inactiveUnionField(active: anytype, accessed: @TypeOf(active)) noreturn {
        _ = accessed;
        while (true) {}
    }

    pub fn incorrectAlignment() noreturn {
        while (true) {}
    }

    pub fn integerOutOfBounds() noreturn {
        while (true) {}
    }

    pub fn integerOverflow() noreturn {
        while (true) {}
    }

    pub fn integerPartOutOfBounds() noreturn {
        while (true) {}
    }

    pub fn invalidEnumValue() noreturn {
        while (true) {}
    }

    pub fn invalidErrorCode() noreturn {
        while (true) {}
    }

    pub fn memcpyAlias() noreturn {
        while (true) {}
    }

    pub fn noreturnReturned() noreturn {
        while (true) {}
    }

    pub fn outOfBounds(index: usize, len: usize) noreturn {
        _ = index;
        _ = len;
        while (true) {}
    }

    pub fn reachedUnreachable() noreturn {
        while (true) {}
    }

    pub fn sentinelMismatch(expected: anytype, found: @TypeOf(expected)) noreturn {
        _ = found;
        while (true) {}
    }

    pub fn shiftRhsTooBig() noreturn {
        while (true) {}
    }

    pub fn shlOverflow() noreturn {
        while (true) {}
    }

    pub fn shrOverflow() noreturn {
        while (true) {}
    }

    pub fn sliceCastLenRemainder(src_len: usize) noreturn {
        _ = src_len;
        while (true) {}
    }
    pub fn startGreaterThanEnd(start: usize, end: usize) noreturn {
        _ = start;
        _ = end;
        while (true) {}
    }
    pub fn unwrapError(err: anyerror) noreturn {
        _ = err;
        while (true) {}
    }
    pub fn unwrapNull() noreturn {
        while (true) {}
    }
};
