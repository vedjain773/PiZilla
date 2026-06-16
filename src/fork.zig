const scheduler = @import("scheduler.zig");
const mm = @import("mm.zig");
const entry = @import("entry.zig");

const Task = scheduler.Task;

pub fn copyProcess(func: usize, arg: usize) i32 {
    scheduler.preemptDisable();
    const proc: ?*Task = @as(?*Task, @ptrFromInt(mm.kMalloc()));

    const proc_ptr: *Task = proc orelse return -1;
    
    proc_ptr.*.priority = 1;
    proc_ptr.*.state = scheduler.State.TASK_RUNNING;
    proc_ptr.*.counter = proc_ptr.*.priority;

    proc_ptr.*.preempt_count = 1;

    proc_ptr.*.cpu_cxt.x19 = func;
    proc_ptr.*.cpu_cxt.x20 = arg;
    proc_ptr.*.cpu_cxt.pc = @intFromPtr(&entry.ret_from_fork);
    proc_ptr.*.cpu_cxt.sp = @intFromPtr(proc_ptr) + scheduler.THREAD_SIZE;

    const pid: usize = scheduler.num_tasks;
    scheduler.num_tasks += 1;
    scheduler.tasks[pid] = proc_ptr;

    scheduler.preemptEnable();
    return 0;
}
