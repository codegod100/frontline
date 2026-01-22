const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
            .abi = .none,
        },
    });
    const release = b.option(bool, "release", "Build in release-small mode") orelse true;
    const optimize: std.builtin.OptimizeMode = if (release) .ReleaseSmall else .Debug;
    const strip = b.option(bool, "strip", "Strip debug symbols") orelse (optimize != .Debug);

    const frontline_mod = b.createModule(.{
        .root_source_file = b.path("../../lib/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    frontline_mod.strip = strip;

    const root_module = b.createModule(.{
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });
    root_module.strip = strip;
    root_module.export_symbol_names = &[_][]const u8{
        "run",
        "incrementCount",
        "alloc",
        "free",
        "init",
    };
    const exe = b.addExecutable(.{
        .name = "main",
        .root_module = root_module,
    });
    exe.root_module.addImport("frontline", frontline_mod);

    exe.rdynamic = false;
    exe.entry = .disabled;

    b.installArtifact(exe);
}
