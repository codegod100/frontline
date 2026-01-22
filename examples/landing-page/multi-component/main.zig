const std = @import("std");
const VNode = @import("vdom.zig").VNode;
const Component = @import("component.zig").Component;

export fn run() void {
    const allocator = std.heap.wasm_allocator;

    const app = try VNode.createElement(allocator, "div");
    try app.setProp("style", "display: flex; flex-direction: column; gap: 24px; max-width: 400px; width: 100%;");

    const header = try VNode.createElement(allocator, "div");
    try header.setProp("style", "text-align: center; margin-bottom: 16px;");

    const h1 = try VNode.createElement(allocator, "h1");
    try h1.setProp("style", "font-size: 48px; font-weight: 700; color: white; text-shadow: 0 2px 10px rgba(0,0,0,0.2); margin: 0;");
    try h1.appendChild(try VNode.createText(allocator, "Frontline"));
    try header.appendChild(h1);

    const tagline = try VNode.createElement(allocator, "p");
    try tagline.setProp("style", "font-size: 18px; color: rgba(255,255,255,0.8); margin: 8px 0 0 0;");
    try tagline.appendChild(try VNode.createText(allocator, "Zig/WebAssembly Frontend Framework"));
    try header.appendChild(tagline);

    try app.appendChild(header);

    try app.appendChild(try VNode.createText(allocator, ""));

    const features = try VNode.createElement(allocator, "div");
    try features.setProp("style", "display: grid; gap: 16px;");

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
        const item = try VNode.createElement(allocator, "div");
        try item.setProp("style", "background: rgba(255,255,255,0.1); padding: 20px; border-radius: 12px;");

        const icon = try VNode.createElement(allocator, "span");
        try icon.setProp("style", "font-size: 32px; display: block; margin-bottom: 8px;");
        try icon.appendChild(try VNode.createText(allocator, feature.icon));
        try item.appendChild(icon);

        const title = try VNode.createElement(allocator, "h3");
        try title.setProp("style", "margin: 0 0 8px 0; font-size: 18px; font-weight: 600; color: white;");
        try title.appendChild(try VNode.createText(allocator, feature.title));
        try item.appendChild(title);

        const desc = try VNode.createElement(allocator, "p");
        try desc.setProp("style", "margin: 0; color: rgba(255,255,255,0.7); line-height: 1.5;");
        try desc.appendChild(try VNode.createText(allocator, feature.desc));
        try item.appendChild(desc);

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
