const schedule = @import("schedule.zig");
const mm = @import("mm.zig");
const entry = @import("entry.zig");
const print = @import("print.zig");

const Task = schedule.Task;

pub fn copyProcess(func: usize, arg: usize) i32 {
    schedule.preemptDisable();
    const proc: ?*Task = @as(?*Task, @ptrFromInt(mm.kMalloc()));

    const proc_ptr: *Task = proc orelse return -1;
    
    proc_ptr.*.priority = 1;
    proc_ptr.*.state = schedule.TASK_RUNNING;
    proc_ptr.*.counter = proc_ptr.*.priority;

    proc_ptr.*.preempt_count = 1;

    proc_ptr.*.cpu_cxt.x19 = func;
    proc_ptr.*.cpu_cxt.x20 = arg;
    proc_ptr.*.cpu_cxt.pc = @intFromPtr(&entry.ret_from_fork);
    proc_ptr.*.cpu_cxt.sp = @intFromPtr(proc_ptr) + schedule.THREAD_SIZE;

    const pid: usize = schedule.num_tasks;
    schedule.num_tasks += 1;
    schedule.tasks[pid] = proc_ptr;

    schedule.preemptEnable();
    return 0;
}
