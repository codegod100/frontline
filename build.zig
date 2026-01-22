const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_mod = b.createModule(.{
        .root_source_file = b.path("lib/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const lib = b.addLibrary(.{
        .name = "frontline",
        .root_module = root_mod,
        .linkage = .dynamic,
    });

    const vdom_mod = b.createModule(.{
        .root_source_file = b.path("lib/vdom.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("vdom", vdom_mod);

    const js_mod = b.createModule(.{
        .root_source_file = b.path("lib/js_interop.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("js_interop", js_mod);

    const component_mod = b.createModule(.{
        .root_source_file = b.path("lib/component.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("component", component_mod);

    const signals_mod = b.createModule(.{
        .root_source_file = b.path("lib/signals.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("signals", signals_mod);

    b.installArtifact(lib);
}
