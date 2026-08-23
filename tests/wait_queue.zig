const console = @import("drivers").console;

const scheduler = @import("sched").scheduler;
const task = @import("sched").task;
const wq = @import("sched").wq;
const fork = @import("sched").fork;

const irq = @import("irq").irq;

const Task = task.Task;
const State = task.State;
const WaitQueue = wq.WaitQueue;

var counter: usize = 0;

var wait: WaitQueue = .{
    .head = null,
    .tail = null,
    .size = 0
}; 

fn task1() noreturn {
    while (true) {
        console.print("Task 1 before wait\n", .{});
        scheduler.wait(&wait);
        console.print("Task 1 after wait\n", .{});

        scheduler.sleep(1); 
    }
}

fn task2() noreturn {
    while (true) {
        console.print("Task 2 running\n", .{});
        scheduler.sleep(10);
        counter += 1;

        if (counter == 10) {
            console.print("Waking up task 1...\n", .{});
            scheduler.wakeOne(&wait);
            counter = 0;
        }

        scheduler.sleep(1);
    }
}


pub fn run() void { 
    fork.copyProcess(@intFromPtr(&task1), @intFromPtr("task1"))
        catch console.print("Failed to create task 1\n", .{});

    fork.copyProcess(@intFromPtr(&task2), @intFromPtr("task2"))
        catch console.print("Failed to create task 2\n", .{}); 
}
