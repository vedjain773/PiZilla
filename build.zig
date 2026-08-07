const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .aarch64,
        .os_tag = .freestanding,
        .abi = .none,
    });

    const exe = b.addExecutable(.{
        .name = "kernel8.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = .Debug,
        }),
    });

    exe.setLinkerScript(b.path("src/linker.ld"));
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
