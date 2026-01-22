const std = @import("std");

const VNode = @import("vdom.zig").VNode;
const Component = @import("component.zig").Component;

var greeting_component: ?*Component = null;
var counter_component: ?*Component = null;

fn renderGreeting(comp: *Component, allocator: std.mem.Allocator) !*VNode {
    const container = try VNode.createElement(allocator, "div");
    try container.setProp("style", "padding: 20px; background: rgba(255,255,255,0.1); border-radius: 12px;");

    const h2 = try VNode.createElement(allocator, "h2");
    try h2.setProp("style", "margin: 0 0 12px 0; font-size: 20px; color: white;");
    try h2.appendChild(try VNode.createText(allocator, "👋 Greeting Component"));
    try container.appendChild(h2);

    const message = try VNode.createElement(allocator, "p");
    try message.setProp("style", "font-size: 16px; color: rgba(255,255,255,0.8); line-height: 1.6;");
    try message.appendChild(try VNode.createText(allocator, "Hello from Zig/WebAssembly! This component demonstrates reusable UI building."));
    try container.appendChild(message);

    const button = try VNode.createElement(allocator, "button");
    try button.setProp("style", "margin-top: 16px; padding: 8px 16px; background: #10b981; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 14px;");
    try button.setProp("onclick", "module.instance.exports.updateGreeting()");
    try button.appendChild(try VNode.createText(allocator, "Change Message"));
    try container.appendChild(button);

    return container;
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

    const container = try VNode.createElement(allocator, "div");
    try container.setProp("style", "padding: 20px; background: rgba(255,255,255,0.1); border-radius: 12px;");

    const h2 = try VNode.createElement(allocator, "h2");
    try h2.setProp("style", "margin: 0 0 12px 0; font-size: 20px; color: white;");
    try h2.appendChild(try VNode.createText(allocator, "🔢 Counter Component"));
    try container.appendChild(h2);

    const row = try VNode.createElement(allocator, "div");
    try row.setProp("style", "display: flex; align-items: center; gap: 16px; font-size: 24px; color: white;");
    try row.appendChild(try VNode.createText(allocator, "Count: "));

    const value = try VNode.createElement(allocator, "span");
    try value.setProp("style", "font-size: 36px; font-weight: 700; color: #007bff; font-family: monospace; min-width: 60px; display: inline-block;");
    var buf: [32]u8 = undefined;
    const count_str = std.fmt.bufPrint(&buf, "{d}", .{count}) catch "0";
    try value.appendChild(try VNode.createText(allocator, count_str));
    try row.appendChild(value);

    try container.appendChild(row);

    const button = try VNode.createElement(allocator, "button");
    try button.setProp("style", "margin-top: 16px; padding: 12px 24px; background: #007bff; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 16px; font-weight: 500;");
    try button.setProp("onclick", "module.instance.exports.incrementCounter()");
    try button.appendChild(try VNode.createText(allocator, "Increment"));
    try container.appendChild(button);

    const button2 = try VNode.createElement(allocator, "button");
    try button2.setProp("style", "margin-left: 8px; padding: 12px 24px; background: #ef4444; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 16px; font-weight: 500;");
    try button2.setProp("onclick", "module.instance.exports.decrementCounter()");
    try button2.appendChild(try VNode.createText(allocator, "Decrement"));
    try container.appendChild(button2);

    return container;
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

    const greeting = try VNode.createElement(allocator, "h1");
    try greeting.setProp("style", "font-size: 48px; font-weight: 700; color: white; text-shadow: 0 2px 10px rgba(0,0,0,0.2); margin: 0 0 32px 0;");
    try greeting.appendChild(try VNode.createText(allocator, "Frontline"));
    greeting.mount(0);

    try VNode.createText(allocator, "").mount(0);

    const container = try VNode.createElement(allocator, "div");
    try container.setProp("style", "display: flex; flex-direction: column; gap: 24px; max-width: 400px; width: 100%;");

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
