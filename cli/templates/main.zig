const std = @import("std");
const frontline = @import("frontline");
const VNode = frontline.VNode;
const Component = frontline.Component;
const ui = frontline.ui;

var counter_component: ?*Component = null;

fn renderCounter(comp: *Component, allocator: std.mem.Allocator) !*VNode {
    const count = Component.getState(i32, comp, "count");

    var buf: [32]u8 = undefined;
    const count_str = std.fmt.bufPrint(&buf, "{d}", .{count}) catch "0";

    return ui.build(allocator, ui.node("div", &.{
        ui.prop("class", "counter-card"),
    }, &.{
        ui.h2(&.{ui.prop("class", "counter-title")}, &.{ui.text("Counter Component")}),
        ui.div(&.{ui.prop("class", "count-row")}, &.{ui.text("Count: ")}),
        ui.span(&.{ui.prop("class", "count-value")}, &.{ui.text(count_str)}),
        ui.button(&.{
            ui.prop("class", "increment-btn"),
            ui.prop("onclick", "window.wasmModule.exports.incrementCount()"),
        }, &.{ui.text("Increment")}),
    }));
}

export fn incrementCount() void {
    if (counter_component) |comp| {
        const count = Component.getState(i32, comp, "count");
        Component.setState(i32, comp, "count", count + 1);
    }
}

export fn run() void {
    const allocator = std.heap.wasm_allocator;

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

        root.mount(0);
        comp.root = root;
        comp.parent_id = 0;
    }
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
