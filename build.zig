const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "frontline",
        .target = target,
        .optimize = optimize,
    });

    const vdom_mod = b.createModule(.{
        .root_source_file = b.path("lib/vdom.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.root_module = vdom_mod;

    const js_mod = b.createModule(.{
        .root_source_file = b.path("lib/js_interop.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.root_module = js_mod;

    const component_mod = b.createModule(.{
        .root_source_file = b.path("lib/component.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.root_module = component_mod;

    const signals_mod = b.createModule(.{
        .root_source_file = b.path("lib/signals.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.root_module = signals_mod;

    b.installArtifact(lib, .{ .dest_dir = .prefix, .install_subdir = "lib" });
}
