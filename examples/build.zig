const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "main",
        .target = target,
        .optimize = optimize,
    });

    const root_module = b.createModule(.{
        .root_source_file = b.path("../frontline/src/js_interop.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module = root_module;

    exe.rdynamic = true;
    exe.entry = .disabled;

    b.installArtifact(exe, .{ .dest_dir = .prefix, .install_subdir = "bin" });
}
