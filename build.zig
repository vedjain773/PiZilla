const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{}); 

    const target = b.resolveTargetQuery(.{
        .cpu_arch = .aarch64,
        .os_tag = .freestanding,
        .abi = .none,
    });
    
    const lib_mod = b.addModule("lib", .{
        .root_source_file = b.path("src/lib/root.zig"),
        .target = target
    });

    const mm_mod = b.addModule("mm", .{
        .root_source_file = b.path("src/mm/root.zig"),
        .target = target
    });

    const irq_mod = b.addModule("irq", .{
        .root_source_file = b.path("src/irq/root.zig"),
        .target = target
    }); 

    const boot_mod = b.addModule("boot", .{
        .root_source_file = b.path("src/boot/root.zig"),
        .target = target
    });

    const drivers_mod = b.addModule("drivers", .{
        .root_source_file = b.path("src/drivers/root.zig"),
        .target = target
    });

    const sched_mod = b.addModule("sched", .{
        .root_source_file = b.path("src/sched/root.zig"),
        .target = target
    });

    lib_mod.addImport("drivers", drivers_mod);
    
    mm_mod.addImport("drivers", drivers_mod);

    irq_mod.addImport("drivers", drivers_mod);
    irq_mod.addImport("sched", sched_mod);
    irq_mod.addImport("lib", lib_mod);
        
    drivers_mod.addImport("lib", lib_mod);

    sched_mod.addImport("boot", boot_mod);
    sched_mod.addImport("irq", irq_mod);
    sched_mod.addImport("mm", mm_mod);

    const exe = b.addExecutable(.{
        .name = "kernel8.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "boot", .module = boot_mod },
                .{ .name = "irq", .module = irq_mod },
                .{ .name = "drivers", .module = drivers_mod },
                .{ .name = "sched", .module = sched_mod },
                .{ .name = "lib", .module = lib_mod }
            },
        }),
    });

    exe.setLinkerScript(b.path("linker.ld"));
    exe.root_module.strip = false;
    exe.pie = false;

    exe.root_module.addIncludePath(b.path("src"));

    exe.root_module.addCSourceFiles(.{
        .files = &[_][]const u8{
            "./asm/boot.S",
            "./asm/mm.S",
            "./asm/entry.S",
            "./asm/irq.S",
            "./asm/schedule.S",
            "./asm/atomic.S"
        },
        .flags = &[_][]const u8{ "-x", "assembler-with-cpp" },
    });

    b.installArtifact(exe);
}
