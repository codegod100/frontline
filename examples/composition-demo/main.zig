const std = @import("std");
const frontline = @import("frontline");
const VNode = frontline.VNode;
const Component = frontline.Component;
const ui = frontline.ui;

var greeting_component: ?*Component = null;
var counter_component: ?*Component = null;

fn renderGreeting(comp: *Component, allocator: std.mem.Allocator) !*VNode {
    const messages = [_][]const u8{
        "Hello from Zig/WebAssembly! This component demonstrates reusable UI building.",
        "Welcome to the future of web development! ⚡",
        "Building modern UIs with Zig and WebAssembly. 🚀",
        "Components compile directly to WASM for maximum performance! 🌲",
    };
    const message_index = Component.getState(i32, comp, "message_index");
    const normalized_index = @mod(message_index, @as(i32, @intCast(messages.len)));
    const message_text = messages[@as(usize, @intCast(normalized_index))];

    return ui.build(allocator, ui.node("div", &.{
        ui.cls("card"),
    }, &.{
        ui.h2(&.{ ui.cls("card-title") }, &.{ ui.text("👋 Greeting Component") }),
        ui.p(&.{ ui.cls("card-body") }, &.{ ui.text(message_text) }),
        ui.button(&.{
            ui.cls("btn btn-dark"),
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
        state = @mod(state + 1, @as(i32, @intCast(messages.len)));
        Component.setState(i32, comp, "message_index", state);
    }
}

fn renderCounter(comp: *Component, allocator: std.mem.Allocator) !*VNode {
    const count = Component.getState(i32, comp, "count");

    var buf: [32]u8 = undefined;
    const count_str = std.fmt.bufPrint(&buf, "{d}", .{count}) catch "0";

    return ui.build(allocator, ui.node("div", &.{
        ui.cls("card"),
    }, &.{
        ui.h2(&.{ ui.cls("card-title") }, &.{ ui.text("🔢 Counter Component") }),
        ui.div(&.{ ui.cls("counter-row") }, &.{
            ui.text("Current count"),
            ui.span(&.{ ui.cls("count-pill") }, &.{ ui.text(count_str) }),
        }),
        ui.div(&.{ ui.cls("actions") }, &.{
            ui.button(&.{
                ui.cls("btn btn-primary"),
                ui.prop("onclick", "window.wasmModule.exports.incrementCounter()"),
            }, &.{ ui.text("Increment") }),
            ui.button(&.{
                ui.cls("btn btn-warm"),
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

    const app = ui.build(allocator, ui.node("div", &.{
        ui.cls("app"),
    }, &.{})) catch return;

    const shell = ui.build(allocator, ui.node("div", &.{
        ui.cls("shell"),
    }, &.{})) catch return;

    const header = ui.build(allocator, ui.node("div", &.{
        ui.cls("header"),
    }, &.{
        ui.span(&.{ ui.cls("badge") }, &.{ ui.text("Composition Demo") }),
        ui.h1(&.{ ui.cls("title") }, &.{ ui.text("Build interfaces from small, reusable parts.") }),
        ui.p(&.{ ui.cls("tagline") }, &.{ ui.text("This demo shows two self-contained components sharing the same runtime and state model.") }),
    })) catch return;

    shell.appendChild(header) catch return;

    const container = ui.build(allocator, ui.node("div", &.{
        ui.cls("grid"),
    }, &.{})) catch return;

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

        comp.root = root;
        comp.parent_id = container.id;
        container.appendChild(root) catch return;
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

        comp.root = root;
        comp.parent_id = container.id;
        container.appendChild(root) catch return;
    }

    shell.appendChild(container) catch return;
    app.appendChild(shell) catch return;
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
