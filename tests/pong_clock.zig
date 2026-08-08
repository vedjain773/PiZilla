const console = @import("drivers").console;

const fork = @import("sched").fork;

const pong = @import("../apps/pong.zig");
const clock = @import("../apps/clock.zig");

pub fn run() void {
    fork.copyProcess(@intFromPtr(&pong.start), @intFromPtr("pong")) 
        catch console.print("Error while trying to start process 1\n", .{});

    fork.copyProcess(@intFromPtr(&clock.update), @intFromPtr("clock"))
        catch console.print("Error while trying to start process 2\n", .{});
}
