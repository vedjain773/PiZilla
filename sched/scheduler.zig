const irq = @import("irq").irq;
const console = @import("drivers").console;

pub const THREAD_SIZE: usize = 4096;
const NUM_TASKS: usize = 64;

pub const State = enum {
    TASK_RUNNING,
    TASK_ZOMBIE,
    TASK_SLEEPING
};

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
    state: State,
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
    .state = State.TASK_RUNNING,
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

            if (task_ptr.*.state == State.TASK_RUNNING and task_ptr.*.counter > curr) {
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

    switchTo(tasks[next].?);
    preemptEnable();
} 

pub fn schedule() void {
    current.*.counter = 0;
    schedCallBack();
}

pub fn timerTick() void {
    for (0..NUM_TASKS) |i| {
        const task_ptr: *Task = tasks[i] orelse continue;

        if (task_ptr.*.state == State.TASK_SLEEPING) {
            task_ptr.*.wake_ticks -= 1;

            if (task_ptr.*.wake_ticks <= 0) {
                task_ptr.*.state = State.TASK_RUNNING;
            }
        }
    }

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

pub fn sleep(ticks: u32) void {
    current.*.state = State.TASK_SLEEPING;
    current.*.wake_ticks = ticks;
    schedCallBack();
}

export fn schedule_tail() void {
    preemptEnable();
}

export fn exit_process() void {
    current.*.state = State.TASK_ZOMBIE;
}
