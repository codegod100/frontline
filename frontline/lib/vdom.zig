const std = @import("std");
const js = @import("js_interop.zig");

var next_id: usize = 1;

pub const VNode = struct {
    const Self = @This();

    kind: VNodeKind,
    id: usize,
    children: std.ArrayList(*VNode),
    props: std.StringHashMap([]const u8),
    text: ?[]const u8,
    node_allocator: std.mem.Allocator,

    pub const VNodeKind = enum {
        element,
        text,
        component,
    };

    pub fn createElement(allocator: std.mem.Allocator, tag: []const u8) !*VNode {
        const node_id = next_id;
        next_id += 1;
        const node = try allocator.create(VNode);
        node.* = VNode{
            .kind = .element,
            .id = node_id,
            .children = std.ArrayList(*VNode).initCapacity(allocator, 0) catch @panic("allocation failed"),
            .props = std.StringHashMap([]const u8).init(allocator),
            .text = null,
            .node_allocator = allocator,
        };
        _ = js.createElement(tag, node_id);
        return node;
    }

    pub fn createText(allocator: std.mem.Allocator, text: []const u8) !*VNode {
        const node = try allocator.create(VNode);
        node.* = VNode{
            .kind = .text,
            .id = 0,
            .children = std.ArrayList(*VNode).initCapacity(allocator, 0) catch @panic("allocation failed"),
            .props = std.StringHashMap([]const u8).init(allocator),
            .text = text,
            .node_allocator = allocator,
        };
        return node;
    }

    pub fn setProp(self: *VNode, name: []const u8, value: []const u8) !void {
        try self.props.put(name, value);
        js.setAttribute(self.id, name, value);
    }

    pub fn appendChild(self: *VNode, child: *VNode) !void {
        try self.children.append(self.node_allocator, child);
    }

    pub fn mount(self: *VNode, parent_id: usize) void {
        if (self.kind == .element) {
            js.appendChild(parent_id, self.id);
            for (self.children.items) |child| {
                child.mount(self.id);
            }
        } else if (self.kind == .text) {
            if (self.text) |text| {
                js.setTextContent(parent_id, text);
            }
        }
    }
};

pub fn diff(old: *const VNode, new: *const VNode) !void {
    if (old.kind != new.kind) {
        js.replaceChild(0, new.id, old.id);
        return;
    }

    switch (new.kind) {
        .text => {
            if (old.text != null and new.text != null) {
                if (!std.mem.eql(u8, old.text.?, new.text.?)) {
                    js.setTextContent(old.id, new.text.?);
                }
            }
        },
        .element => {
            var entry = new.props.iterator();
            while (entry.next()) |kv| {
                js.setAttribute(new.id, kv.key_ptr.*, kv.value_ptr.*);
            }
        },
        .component => {},
    }
}
