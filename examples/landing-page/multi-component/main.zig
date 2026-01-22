const std = @import("std");
const frontline = @import("frontline");
const ui = frontline.ui;

export fn run() void {
    const allocator = std.heap.wasm_allocator;

    const app = try ui.build(allocator, ui.node("div", &.{
        ui.prop("style", "display: flex; flex-direction: column; gap: 24px; max-width: 400px; width: 100%;"),
    }, &.{
        ui.div(&.{ ui.prop("style", "text-align: center; margin-bottom: 16px;") }, &.{
            ui.h1(&.{ ui.prop("style", "font-size: 48px; font-weight: 700; color: white; text-shadow: 0 2px 10px rgba(0,0,0,0.2); margin: 0;") }, &.{ ui.text("Frontline") }),
            ui.p(&.{ ui.prop("style", "font-size: 18px; color: rgba(255,255,255,0.8); margin: 8px 0 0 0;") }, &.{ ui.text("Zig/WebAssembly Frontend Framework") }),
        }),
        ui.text(""),
    }));

    const features = try ui.build(allocator, ui.node("div", &.{
        ui.prop("style", "display: grid; gap: 16px;"),
    }, &.{}));

    const feature_list = [_]struct {
        icon: []const u8,
        title: []const u8,
        desc: []const u8,
    }{
        .{ .icon = "⚡", .title = "Compile to WASM", .desc = "Zig code compiles directly to WebAssembly" },
        .{ .icon = "🔄", .title = "Reactive State", .desc = "Svelte-like signals for state management" },
        .{ .icon = "🌲", .title = "Virtual DOM", .desc = "Efficient DOM updates with diffing" },
        .{ .icon = "🧩", .title = "Component-Based", .desc = "Build reusable UI components" },
    };

    for (feature_list) |feature| {
        const item = try ui.build(allocator, ui.node("div", &.{
            ui.prop("style", "background: rgba(255,255,255,0.1); padding: 20px; border-radius: 12px;"),
        }, &.{
            ui.span(&.{ ui.prop("style", "font-size: 32px; display: block; margin-bottom: 8px;") }, &.{ ui.text(feature.icon) }),
            ui.h3(&.{ ui.prop("style", "margin: 0 0 8px 0; font-size: 18px; font-weight: 600; color: white;") }, &.{ ui.text(feature.title) }),
            ui.p(&.{ ui.prop("style", "margin: 0; color: rgba(255,255,255,0.7); line-height: 1.5;") }, &.{ ui.text(feature.desc) }),
        }));

        try features.appendChild(item);
    }

    try app.appendChild(features);

    app.mount(0);
}

export fn alloc(size: usize) [*]u8 {
    const ptr = std.heap.wasm_allocator.alloc(u8, size) catch @panic("allocation failed");
    return ptr.ptr;
}

export fn free(ptr: [*]u8, size: usize) void {
    std.heap.wasm_allocator.free(ptr[0..size]);
}

export fn init() void {
    @setRuntimeSafety(false);
}
