const std = @import("std");

extern "js" fn js_createElement(tag_ptr: [*]const u8, tag_len: usize, node_id: usize) usize;
extern "js" fn js_setAttribute(el_id: usize, name_ptr: [*]const u8, name_len: usize, value_ptr: [*]const u8, value_len: usize) void;
extern "js" fn js_setTextContent(el_id: usize, text_ptr: [*]const u8, text_len: usize) void;
extern "js" fn js_appendChild(parent_id: usize, child_id: usize) void;
extern "js" fn js_removeChild(parent_id: usize, child_id: usize) void;
extern "js" fn js_replaceChild(parent_id: usize, new_id: usize, old_id: usize) void;

pub fn createString(str: []const u8) struct { ptr: [*]const u8, len: usize } {
    return .{ .ptr = str.ptr, .len = str.len };
}

pub fn createElement(tag: []const u8, node_id: usize) usize {
    const s = createString(tag);
    return js_createElement(s.ptr, s.len, node_id);
}

pub fn setAttribute(el: usize, name: []const u8, value: []const u8) void {
    const name_s = createString(name);
    const value_s = createString(value);
    js_setAttribute(el, name_s.ptr, name_s.len, value_s.ptr, value_s.len);
}

pub fn setTextContent(el: usize, text: []const u8) void {
    const s = createString(text);
    js_setTextContent(el, s.ptr, s.len);
}

pub fn appendChild(parent: usize, child: usize) void {
    js_appendChild(parent, child);
}

pub fn removeChild(parent: usize, child: usize) void {
    js_removeChild(parent, child);
}

pub fn replaceChild(parent: usize, new: usize, old: usize) void {
    js_replaceChild(parent, new, old);
}
