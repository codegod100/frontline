const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn Signal(comptime T: type) type {
    return struct {
        value: T,
        subscribers: std.ArrayList(*fn (T) void),
        allocator: Allocator,

        pub fn init(allocator: Allocator, initial: T) !*@This() {
            const signal = try allocator.create(@This());
            signal.* = @This(){
                .value = initial,
                .subscribers = std.ArrayList(*fn (T) void).initCapacity(allocator, 0) catch @panic("allocation failed"),
                .allocator = allocator,
            };
            return signal;
        }

        pub fn get(self: *@This()) T {
            return self.value;
        }

        pub fn set(self: *@This(), new_value: T) void {
            self.value = new_value;
            for (self.subscribers.items) |sub| {
                sub(new_value);
            }
        }

        pub fn subscribe(self: *@This(), callback: *fn (T) void) void {
            self.subscribers.append(self.allocator, callback) catch @panic("subscription failed");
        }
    };
}

pub fn Computed(comptime T: type) type {
    return struct {
        compute_fn: *const fn () T,
        cache: T,
        dirty: bool,
        dependencies: std.ArrayList(*anyopaque),

        pub fn init(compute_fn: *const fn () T) @This() {
            return .{
                .compute_fn = compute_fn,
                .cache = compute_fn(),
                .dirty = false,
                .dependencies = std.ArrayList(*anyopaque).initCapacity(std.heap.wasm_allocator, 0) catch @panic("allocation failed"),
            };
        }

        pub fn get(self: *@This()) T {
            if (self.dirty) {
                self.cache = self.compute_fn();
                self.dirty = false;
            }
            return self.cache;
        }
    };
}
