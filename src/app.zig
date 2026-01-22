const std = @import("std");
const VNode = @import("vdom.zig").VNode;
const Component = @import("component.zig").Component;
const js = @import("js_interop.zig");

var counter_component: ?*Component = null;

fn renderCounter(comp: *Component, allocator: std.mem.Allocator) !*VNode {
    const count = Component.getState(i32, comp, "count");

    const container = try VNode.createElement(allocator, "div");
    try container.setProp("style", "padding: 20px; border: 1px solid #ccc; border-radius: 8px;");

    const title = try VNode.createElement(allocator, "h2");
    try title.appendChild(try VNode.createText(allocator, "Counter Component"));
    try container.appendChild(title);

    const count_display = try VNode.createElement(allocator, "p");
    try count_display.appendChild(try VNode.createText(allocator, "Count: "));
    try container.appendChild(count_display);

    const count_value = try VNode.createElement(allocator, "span");
    var buf: [32]u8 = undefined;
    const count_str = std.fmt.bufPrint(&buf, "{d}", .{count}) catch "0";
    try count_value.appendChild(try VNode.createText(allocator, count_str));
    try container.appendChild(count_value);

    const button = try VNode.createElement(allocator, "button");
    try button.setProp("style", "margin-top: 10px; padding: 8px 16px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer;");
    try button.appendChild(try VNode.createText(allocator, "Increment"));
    try container.appendChild(button);

    return container;
}

export fn incrementCount() void {
    if (counter_component) |comp| {
        const count = Component.getState(i32, comp, "count");
        Component.setState(i32, comp, "count", count + 1);
    }
}

export fn run() void {
    js.logMsg("Frontline Framework initialized");

    const allocator = std.heap.wasm_allocator;

    counter_component = Component.init(allocator, renderCounter) catch {
        js.logMsg("Failed to create component");
        return;
    };

    if (counter_component) |comp| {
        Component.createState(i32, comp, "count", 0) catch {
            js.logMsg("Failed to create state");
            return;
        };

        const root = renderCounter(comp, allocator) catch {
            js.logMsg("Failed to render");
            return;
        };

        root.mount(0);
        comp.root = root;
    }
}
