const taskf = @import("task.zig");

const Task = taskf.Task;
const State = taskf.State;

pub const WaitQueue = struct {
    head: ?*Task,
    tail: ?*Task,
    size: usize,

    pub fn isEmpty(self: *WaitQueue) bool {
        return self.size == 0;    
    }

    pub fn getSize(self: *WaitQueue) usize {
        return self.size;
    } 

    pub fn enqueue(self: *WaitQueue, task: *Task) void {
        task.wait_next = null;

        if (self.isEmpty()) {
            self.head = task;
            self.tail = task;
        } else {
            self.tail.?.wait_next = task;
            self.tail = task;
        }

        self.size += 1;
    }

    pub fn dequeue(self: *WaitQueue) ?*Task {
        if (self.isEmpty()) { return null; }

        const prev_head: *Task = self.head.?; 

        self.head = self.head.?.*.wait_next;
        
        if (self.size == 1) {
            self.tail = null;
        }

        prev_head.*.wait_next = null;
        
        self.size -= 1;
        return prev_head; 
    }
}; 
