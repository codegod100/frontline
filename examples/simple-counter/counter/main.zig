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
        ui.prop("style", "display: flex; flex-direction: column; gap: 16px; padding: 24px; background: white; border: 1px solid #e5e7eb; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.08);"),
    }, &.{
        ui.h2(&.{ ui.prop("style", "margin: 0; font-size: 24px; font-weight: 600; color: #1f2937;") }, &.{ ui.text("Counter Component") }),
        ui.div(&.{ ui.prop("style", "display: flex; align-items: baseline; gap: 8px; font-size: 18px; color: #374151;") }, &.{ ui.text("Count: ") }),
        ui.span(&.{ ui.prop("style", "font-size: 28px; font-weight: 700; color: #007bff; font-family: monospace;") }, &.{ ui.text(count_str) }),
        ui.button(&.{
            ui.prop("style", "align-self: flex-start; padding: 12px 24px; font-size: 16px; font-weight: 500; background: #007bff; color: white; border: none; border-radius: 8px; cursor: pointer; transition: background 0.2s, transform 0.1s; box-shadow: 0 4px 12px rgba(0,123,255,0.3);"),
            ui.prop("onclick", "module.instance.exports.incrementCount()"),
        }, &.{ ui.text("Increment") }),
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
