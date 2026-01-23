const std = @import("std");

const FileSpec = struct {
    path: []const u8,
    contents: []const u8,
};

const template_files = [_]FileSpec{
    .{ .path = "build.zig", .contents = @embedFile("templates/build.zig") },
    .{ .path = "index.html", .contents = @embedFile("templates/index.html") },
    .{ .path = "main.zig", .contents = @embedFile("templates/main.zig") },
    .{ .path = "lib/app.js", .contents = @embedFile("templates/lib/app.js") },
    .{ .path = "lib/wasm-loader.js", .contents = @embedFile("templates/lib/wasm-loader.js") },
    .{ .path = "lib/component.zig", .contents = @embedFile("templates/lib/component.zig") },
    .{ .path = "lib/js_interop.zig", .contents = @embedFile("templates/lib/js_interop.zig") },
    .{ .path = "lib/root.zig", .contents = @embedFile("templates/lib/root.zig") },
    .{ .path = "lib/signals.zig", .contents = @embedFile("templates/lib/signals.zig") },
    .{ .path = "lib/ui.zig", .contents = @embedFile("templates/lib/ui.zig") },
    .{ .path = "lib/vdom.zig", .contents = @embedFile("templates/lib/vdom.zig") },
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout = std.fs.File.stdout().deprecatedWriter();
    const stderr = std.fs.File.stderr().deprecatedWriter();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2 or std.mem.eql(u8, args[1], "-h") or std.mem.eql(u8, args[1], "--help")) {
        try printUsage(stdout);
        return;
    }

    const project_path = args[1];
    if (project_path.len == 0) {
        try stderr.writeAll("Project path cannot be empty.\n");
        try printUsage(stderr);
        return error.InvalidArgument;
    }

    const cwd = std.fs.cwd();

    const existing_dir = cwd.openDir(project_path, .{}) catch |err| switch (err) {
        error.FileNotFound => null,
        else => return err,
    };
    if (existing_dir) |dir| {
        var dir_mut = dir;
        dir_mut.close();
        try stderr.print("Path already exists: {s}\n", .{project_path});
        return error.PathAlreadyExists;
    }

    try cwd.makePath(project_path);
    var out_dir = try cwd.openDir(project_path, .{ .iterate = true });
    defer out_dir.close();

    for (template_files) |file_spec| {
        if (std.fs.path.dirname(file_spec.path)) |dir_name| {
            try out_dir.makePath(dir_name);
        }

        var out_file = try out_dir.createFile(file_spec.path, .{ .truncate = true });
        defer out_file.close();
        try out_file.writeAll(file_spec.contents);
    }

    try stdout.print("Created Frontline example at {s}\n", .{project_path});
}

fn printUsage(writer: anytype) !void {
    try writer.writeAll(
        "Usage: frontline <path>\n" ++
            "Creates a Frontline example project in <path>.\n",
    );
}
