const std = @import("std");
const Allocator = std.mem.Allocator;
const VNode = @import("vdom.zig").VNode;
const Signal = @import("signals.zig").Signal;
const Computed = @import("signals.zig").Computed;
const js = @import("js_interop.zig");

const RenderFn = fn (*Component, Allocator) error{OutOfMemory}!*VNode;

pub const Component = struct {
    const Self = @This();

    allocator: Allocator,
    render_fn: *const RenderFn,
    state: std.StringHashMap(*anyopaque),
    root: ?*VNode,

    pub fn init(allocator: Allocator, render_fn: *const RenderFn) !*Self {
        const comp = try allocator.create(Self);
        comp.* = Self{
            .allocator = allocator,
            .render_fn = render_fn,
            .state = std.StringHashMap(*anyopaque).init(allocator),
            .root = null,
        };
        return comp;
    }

    pub fn createState(comptime T: type, self: *Self, name: []const u8, initial: T) !void {
        const signal = try Signal(T).init(self.allocator, initial);
        try self.state.put(name, signal);
    }

    pub fn getState(comptime T: type, self: *Self, name: []const u8) T {
        const signal: *Signal(T) = @ptrCast(@alignCast(self.state.get(name).?));
        return signal.get();
    }

    pub fn setState(comptime T: type, self: *Self, name: []const u8, value: T) void {
        const signal: *Signal(T) = @ptrCast(@alignCast(self.state.get(name).?));
        signal.set(value);
        self.update();
    }

    pub fn update(self: *Self) void {
        const render = self.render_fn;
        const new_root = render(self, self.allocator) catch return;
        if (self.root) |old| {
            js.removeChild(0, old.id);
            js.appendChild(0, new_root.id);
            new_root.mount(0);
        } else {
            new_root.mount(0);
        }
        self.root = new_root;
    }
};

const diff = @import("vdom.zig").diff;
