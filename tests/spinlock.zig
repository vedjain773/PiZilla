const console = @import("drivers").console;

const scheduler = @import("sched").scheduler;
const atomic = @import("sched").atomic;
const fork = @import("sched").fork;

const irq = @import("irq").irq;

var sl = atomic.SpinLock.init();
var shared_counter: usize = 0;

fn task1() noreturn {
    while (true) {
        const prev_state = sl.lock(); 
        shared_counter += 1;

        console.print("Counter T1: %d\n", .{shared_counter});
        sl.unlock(prev_state);

        scheduler.sleep(5); 
    }
}

fn task2() noreturn {
    while (true) {
        const prev_state = sl.lock(); 
        shared_counter += 1;
        
        console.print("Counter T2: %d\n", .{shared_counter});
        sl.unlock(prev_state);

        scheduler.sleep(5); 
    }
}

pub fn run() void {
    fork.copyProcess(@intFromPtr(&task1), @intFromPtr("task1"))
        catch console.print("Failed to create task 1\n", .{});

    fork.copyProcess(@intFromPtr(&task2), @intFromPtr("task2"))
        catch console.print("Failed to create task 2\n", .{});
}
