const irq = @import("irq.zig");
const console = @import("console.zig");

pub const THREAD_SIZE: usize = 4096;
const NUM_TASKS: usize = 64;

pub const TASK_RUNNING: u64 = 0;
pub const TASK_ZOMBIE: u64 = 1;
pub const TASK_SLEEPING: u64 = 2;

const CPUContext =  struct {
    x19: usize,
    x20: usize,
    x21: usize,
    x22: usize,
    x23: usize,
    x24: usize,
    x25: usize,
    x26: usize,
    x27: usize,
    x28: usize,
    fp: usize,
    sp: usize,
    pc: usize
};

pub const Task = struct {
    cpu_cxt: CPUContext,
    state: u64,
    counter: u64,
    priority: u64,
    preempt_count: u64,
    wake_ticks: u64
};

const init_task: Task = .{
    .cpu_cxt = .{
        .x19 = 0,
        .x20 = 0,
        .x21 = 0,
        .x22 = 0,
        .x23 = 0,
        .x24 = 0,
        .x25 = 0,
        .x26 = 0,
        .x27 = 0,
        .x28 = 0,
        .fp = 0,
        .sp = 0,
        .pc = 0
    },
    .state = TASK_RUNNING,
    .counter = 0,
    .priority = 1,
    .preempt_count = 0,
    .wake_ticks = 0
};

pub var current: *Task = @constCast(&init_task);
pub var tasks: [NUM_TASKS]?*Task = @splat(null);
pub var num_tasks: usize = 1;

pub fn initTasks() void {
    tasks[0] = current;
}

pub fn preemptDisable() void {
    current.*.preempt_count += 1;
}

pub fn preemptEnable() void {
    current.*.preempt_count -= 1;
}

pub extern fn cpu_switch_to(prev: *Task, next: *Task) void;

fn schedCallBack() void {
    preemptDisable();

    var next: usize = undefined;
    var curr: i32 = undefined;

    while (true) {
        curr = -1;
        next = 0;

        for (0..NUM_TASKS) |i| {
            const task_ptr: *Task = tasks[i] orelse continue;

            if (task_ptr.*.state == TASK_RUNNING and task_ptr.*.counter > curr) {
                curr = @as(i32, @intCast(task_ptr.*.counter));
                next = i;
            }
        }

        if (curr != 0) {
            break;
        }

        for (0..NUM_TASKS) |i| {
            const task_ptr: *Task = tasks[i] orelse continue;

            task_ptr.*.counter = (task_ptr.*.counter >> 1) + task_ptr.*.priority;
        }
    }

    console.print("Switching to task %d\n", .{next});
    switchTo(tasks[next].?);
    preemptEnable();
} 

pub fn schedule() void {
    current.*.counter = 0;
    schedCallBack();
}

pub fn timerTick() void {
    current.*.counter -= 1;

    if (current.*.counter > 0 or current.*.preempt_count > 0)
        return;

    current.*.counter = 0;

    irq.enable();
    schedCallBack();
    irq.disable();
}

fn switchTo(next: *Task) void {
    if (current == next)
        return;

    const prev: *Task = current;
    current = next;
    cpu_switch_to(prev, next);
}

export fn schedule_tail() void {
    preemptEnable();
}
