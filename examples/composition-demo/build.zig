const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.dependency("frontline", .{
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "main",
        .target = target,
        .optimize = optimize,
    });

    exe.root_module = b.createModule(.{
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("frontline", lib.module("frontline"));

    exe.rdynamic = true;
    exe.entry = .disabled;

    b.installArtifact(exe, .{ .dest_dir = .prefix, .install_subdir = "bin" });
}
