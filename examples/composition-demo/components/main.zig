const std = @import("std");
const frontline = @import("frontline");
const VNode = frontline.VNode;
const Component = frontline.Component;
const ui = frontline.ui;

var greeting_component: ?*Component = null;
var counter_component: ?*Component = null;

fn renderGreeting(comp: *Component, allocator: std.mem.Allocator) !*VNode {
    return ui.build(allocator, ui.node("div", &.{
        ui.prop("style", "padding: 20px; background: rgba(255,255,255,0.1); border-radius: 12px;"),
    }, &.{
        ui.h2(&.{ ui.prop("style", "margin: 0 0 12px 0; font-size: 20px; color: white;") }, &.{ ui.text("👋 Greeting Component") }),
        ui.p(&.{ ui.prop("style", "font-size: 16px; color: rgba(255,255,255,0.8); line-height: 1.6;") }, &.{ ui.text("Hello from Zig/WebAssembly! This component demonstrates reusable UI building.") }),
        ui.button(&.{
            ui.prop("style", "margin-top: 16px; padding: 8px 16px; background: #10b981; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 14px;"),
            ui.prop("onclick", "window.wasmModule.exports.updateGreeting()"),
        }, &.{ ui.text("Change Message") }),
    }));
}

export fn updateGreeting() void {
    if (greeting_component) |comp| {
        const messages = [_][]const u8{
            "Hello from Zig/WebAssembly! This component demonstrates reusable UI building.",
            "Welcome to the future of web development! ⚡",
            "Building modern UIs with Zig and WebAssembly. 🚀",
            "Components compile directly to WASM for maximum performance! 🌲",
        };
        var state = Component.getState(i32, comp, "message_index");
        state = (state + 1) % messages.len;
        Component.setState(i32, comp, "message_index", state);
    }
}

fn renderCounter(comp: *Component, allocator: std.mem.Allocator) !*VNode {
    const count = Component.getState(i32, comp, "count");

    var buf: [32]u8 = undefined;
    const count_str = std.fmt.bufPrint(&buf, "{d}", .{count}) catch "0";

    return ui.build(allocator, ui.node("div", &.{
        ui.prop("style", "padding: 20px; background: rgba(255,255,255,0.1); border-radius: 12px;"),
    }, &.{
        ui.h2(&.{ ui.prop("style", "margin: 0 0 12px 0; font-size: 20px; color: white;") }, &.{ ui.text("🔢 Counter Component") }),
        ui.div(&.{ ui.prop("style", "display: flex; align-items: center; gap: 16px; font-size: 24px; color: white;") }, &.{
            ui.text("Count: "),
            ui.span(&.{ ui.prop("style", "font-size: 36px; font-weight: 700; color: #007bff; font-family: monospace; min-width: 60px; display: inline-block;") }, &.{ ui.text(count_str) }),
        }),
        ui.div(&.{ ui.prop("style", "margin-top: 16px; display: flex; gap: 8px; flex-wrap: wrap;") }, &.{
            ui.button(&.{
                ui.prop("style", "padding: 12px 24px; background: #007bff; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 16px; font-weight: 500;"),
                ui.prop("onclick", "window.wasmModule.exports.incrementCounter()"),
            }, &.{ ui.text("Increment") }),
            ui.button(&.{
                ui.prop("style", "padding: 12px 24px; background: #ef4444; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 16px; font-weight: 500;"),
                ui.prop("onclick", "window.wasmModule.exports.decrementCounter()"),
            }, &.{ ui.text("Decrement") }),
        }),
    }));
}

export fn incrementCounter() void {
    if (counter_component) |comp| {
        const count = Component.getState(i32, comp, "count");
        Component.setState(i32, comp, "count", count + 1);
    }
}

export fn decrementCounter() void {
    if (counter_component) |comp| {
        const count = Component.getState(i32, comp, "count");
        Component.setState(i32, comp, "count", count - 1);
    }
}

export fn run() void {
    const allocator = std.heap.wasm_allocator;

    const greeting = try ui.build(allocator, ui.node("h1", &.{
        ui.prop("style", "font-size: 48px; font-weight: 700; color: white; text-shadow: 0 2px 10px rgba(0,0,0,0.2); margin: 0 0 32px 0;"),
    }, &.{ ui.text("Frontline") }));
    greeting.mount(0);

    const spacer = try ui.build(allocator, ui.node("span", &.{}, &.{ ui.text("") }));
    spacer.mount(0);

    const container = try ui.build(allocator, ui.node("div", &.{
        ui.prop("style", "display: flex; flex-direction: column; gap: 24px; max-width: 400px; width: 100%;"),
    }, &.{}));

    greeting_component = Component.init(allocator, renderGreeting) catch {
        return;
    };

    if (greeting_component) |comp| {
        Component.createState(i32, comp, "message_index", 0) catch {
            return;
        };

        const root = renderGreeting(comp, allocator) catch {
            return;
        };

        try container.appendChild(root);
    }

    counter_component = Component.init(allocator, renderCounter) catch {
        return;
    };

    if (counter_component) |comp| {
        Component.createState(i32, comp, "count", 0) catch {
            return;
        };

        const root = renderCounter(comp, allocator) catch {
            return;
        };

        try container.appendChild(root);
    }

    container.mount(0);
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
