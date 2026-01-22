const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "frontline",
        .linkage = .static,
        .target = target,
        .optimize = optimize,
    });

    const vdom_mod = b.createModule(.{
        .root_source_file = b.path("lib/vdom.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.addImport("vdom", vdom_mod);

    const js_mod = b.createModule(.{
        .root_source_file = b.path("lib/js_interop.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.addImport("js_interop", js_mod);

    const component_mod = b.createModule(.{
        .root_source_file = b.path("lib/component.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.addImport("component", component_mod);

    const signals_mod = b.createModule(.{
        .root_source_file = b.path("lib/signals.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.addImport("signals", signals_mod);

    b.installArtifact(lib, .{ .dest_dir = .prefix, .install_subdir = "lib" });
}
