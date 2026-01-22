const std = @import("std");
const frontline = @import("frontline");
const ui = frontline.ui;

export fn run() void {
    runImpl() catch @panic("run failed");
}

fn runImpl() !void {
    const allocator = std.heap.wasm_allocator;

    const app = try ui.build(allocator, ui.node("div", &.{
        ui.prop("style", "min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 56px 24px; box-sizing: border-box;"),
    }, &.{}));

    const shell = try ui.build(allocator, ui.node("div", &.{
        ui.prop("style", "width: min(100%, 980px); background: rgba(255,255,255,0.9); border: 1px solid rgba(15,23,42,0.08); border-radius: 28px; padding: 40px; box-shadow: 0 30px 80px rgba(15,23,42,0.15);"),
    }, &.{}));

    const header = try ui.build(allocator, ui.node("div", &.{
        ui.prop("style", "display: grid; gap: 16px; text-align: left;"),
    }, &.{
        ui.span(&.{ ui.prop("style", "align-self: start; display: inline-flex; padding: 6px 14px; border-radius: 999px; background: #111827; color: #f8fafc; font-size: 12px; letter-spacing: 0.12em; text-transform: uppercase; font-weight: 600;") }, &.{ ui.text("Frontline") }),
        ui.h1(&.{ ui.prop("style", "font-size: 44px; font-weight: 700; color: #111827; letter-spacing: -0.02em; margin: 0;") }, &.{ ui.text("Ship Zig apps that feel native on the web.") }),
        ui.p(&.{ ui.prop("style", "font-size: 18px; color: #475569; margin: 0; max-width: 560px; line-height: 1.6;") }, &.{ ui.text("Frontline blends Zig, WebAssembly, and a tiny runtime so you can build fast, reactive frontends without a JavaScript toolchain.") }),
        ui.div(&.{ ui.prop("style", "display: flex; flex-wrap: wrap; gap: 12px; margin-top: 8px;") }, &.{
            ui.a(&.{
                ui.prop("href", "#"),
                ui.prop("style", "text-decoration: none; padding: 12px 20px; border-radius: 999px; background: #0f172a; color: #f8fafc; font-size: 14px; font-weight: 600; letter-spacing: 0.02em; display: inline-flex; align-items: center;"),
            }, &.{ ui.text("Get started") }),
            ui.a(&.{
                ui.prop("href", "#"),
                ui.prop("style", "text-decoration: none; padding: 12px 20px; border-radius: 999px; border: 1px solid rgba(15,23,42,0.2); color: #0f172a; font-size: 14px; font-weight: 600; letter-spacing: 0.02em; display: inline-flex; align-items: center;"),
            }, &.{ ui.text("Read the docs") }),
        }),
    }));

    try shell.appendChild(header);

    const features = try ui.build(allocator, ui.node("div", &.{
        ui.prop("style", "display: grid; gap: 16px; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); margin-top: 28px;"),
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
            ui.prop("style", "background: white; padding: 18px; border-radius: 16px; border: 1px solid rgba(15,23,42,0.06); box-shadow: 0 12px 30px rgba(15,23,42,0.08);"),
        }, &.{
            ui.span(&.{ ui.prop("style", "font-size: 28px; display: block; margin-bottom: 8px;") }, &.{ ui.text(feature.icon) }),
            ui.h3(&.{ ui.prop("style", "margin: 0 0 8px 0; font-size: 18px; font-weight: 600; color: #0f172a;") }, &.{ ui.text(feature.title) }),
            ui.p(&.{ ui.prop("style", "margin: 0; color: #475569; line-height: 1.5;") }, &.{ ui.text(feature.desc) }),
        }));

        try features.appendChild(item);
    }

    try shell.appendChild(features);
    try app.appendChild(shell);

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
