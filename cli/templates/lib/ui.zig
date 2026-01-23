const std = @import("std");
const VNode = @import("vdom.zig").VNode;

pub const Prop = struct {
    name: []const u8,
    value: []const u8,
};

pub const Node = struct {
    tag: []const u8,
    props: []const Prop = &.{},
    children: []const Child = &.{},
};

pub const Child = union(enum) {
    text: []const u8,
    node: Node,
    vnode: *VNode,
};

const BuildError = error{OutOfMemory};

pub fn prop(name: []const u8, value: []const u8) Prop {
    return .{ .name = name, .value = value };
}

pub fn node(tag: []const u8, props: []const Prop, children: []const Child) Node {
    return .{ .tag = tag, .props = props, .children = children };
}

pub fn el(tag: []const u8, props: []const Prop, children: []const Child) Child {
    return .{ .node = node(tag, props, children) };
}

pub fn text(value: []const u8) Child {
    return .{ .text = value };
}

pub fn cls(value: []const u8) Prop {
    return prop("class", value);
}

pub fn div(props: []const Prop, children: []const Child) Child {
    return el("div", props, children);
}

pub fn h1(props: []const Prop, children: []const Child) Child {
    return el("h1", props, children);
}

pub fn h2(props: []const Prop, children: []const Child) Child {
    return el("h2", props, children);
}

pub fn h3(props: []const Prop, children: []const Child) Child {
    return el("h3", props, children);
}

pub fn p(props: []const Prop, children: []const Child) Child {
    return el("p", props, children);
}

pub fn span(props: []const Prop, children: []const Child) Child {
    return el("span", props, children);
}

pub fn a(props: []const Prop, children: []const Child) Child {
    return el("a", props, children);
}

pub fn button(props: []const Prop, children: []const Child) Child {
    return el("button", props, children);
}

pub fn from(vnode: *VNode) Child {
    return .{ .vnode = vnode };
}

pub fn build(allocator: std.mem.Allocator, spec: Node) BuildError!*VNode {
    const element = try VNode.createElement(allocator, spec.tag);
    for (spec.props) |entry| {
        try element.setProp(entry.name, entry.value);
    }
    for (spec.children) |child| {
        try appendChild(allocator, element, child);
    }
    return element;
}

fn appendChild(allocator: std.mem.Allocator, parent: *VNode, child: Child) BuildError!void {
    switch (child) {
        .text => |value| {
            const text_node = try VNode.createText(allocator, value);
            try parent.appendChild(text_node);
        },
        .node => |spec| {
            const child_node = try build(allocator, spec);
            try parent.appendChild(child_node);
        },
        .vnode => |child_node| {
            try parent.appendChild(child_node);
        },
    }
}
