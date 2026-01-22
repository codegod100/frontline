const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
            .abi = .none,
        },
    });
    const optimize = b.standardOptimizeOption(.{});

    const frontline_mod = b.createModule(.{
        .root_source_file = b.path("../../lib/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const root_module = b.createModule(.{
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const exe = b.addExecutable(.{
        .name = "main",
        .root_module = root_module,
    });
    exe.root_module.addImport("frontline", frontline_mod);

    exe.rdynamic = true;
    exe.entry = .disabled;

    b.installArtifact(exe);
}
