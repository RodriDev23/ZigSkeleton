const std = @import("std");

fn create_build_file(user_input: []u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Allocate memory for the path with /src/build.zig
    const full_path_formatted = try std.fmt.allocPrint(allocator, "{s}/build.zig", .{user_input});
    defer allocator.free(full_path_formatted); // Free this memory

    // Create file
    var file_create = try std.fs.cwd().createFile(full_path_formatted, .{});
    defer file_create.close();

    // First variable having the name
    const file_content_b_d = try std.fmt.allocPrint(allocator, "    .name = \"{s}\",\n", .{user_input}); // Added quotes
    defer allocator.free(file_content_b_d); // Free memory from the long text

    const file_content_a = "const std = @import(\"std\");\n" ++
        "pub fn build(b: *std.Build) void {\n" ++
        "    const target = b.standardTargetOptions(.{});\n" ++
        "    const optimize = b.standardOptimizeOption(.{});\n" ++
        "    const lib = b.addStaticLibrary(.{\n";

    const file_content_c = ".root_source_file = b.path(\"src/root.zig\"),\n" ++
        "        .target = target,\n" ++
        "        .optimize = optimize,\n" ++
        "    });\n" ++
        "    b.installArtifact(lib);\n" ++
        "    const exe = b.addExecutable(.{\n" ++
        "        .name = \"testing\",  // Add the name field here\n" ++
        "        .root_source_file = b.path(\"src/main.zig\"),\n" ++
        "        .target = target,\n" ++
        "        .optimize = optimize,\n" ++
        "    });\n";

    const file_content_e =
        "    b.installArtifact(exe);\n" ++
        "    const run_cmd = b.addRunArtifact(exe);\n" ++
        "    run_cmd.step.dependOn(b.getInstallStep());\n" ++
        "    if (b.args) |args| {\n" ++
        "        run_cmd.addArgs(args);\n" ++
        "    }\n" ++
        "    const run_step = b.step(\"run\", \"Run the app\");\n" ++
        "    run_step.dependOn(&run_cmd.step);\n" ++
        "    const exe_unit_tests = b.addTest(.{\n" ++
        "        .root_source_file = b.path(\"src/main.zig\"),\n" ++
        "        .target = target,\n" ++
        "        .optimize = optimize,\n" ++
        "    });\n" ++
        "    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);\n" ++
        "    const test_step = b.step(\"test\", \"Run unit tests\");\n" ++
        "    test_step.dependOn(&run_exe_unit_tests.step);\n" ++
        "}\n";

    // Correctly concatenate all file contents
    const slices: []const []const u8 = &[_][]const u8{
        file_content_a,
        file_content_b_d,
        file_content_c,
        file_content_e,
    };

    const result = try std.mem.concat(allocator, u8, slices);
    defer allocator.free(result); // Free the concatenated result
    try file_create.writeAll(result); // Write the result to the file
}

fn create_root_file(user_input: []u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Allocate memory for the path with /src/build.zig
    const full_path_formatted = try std.fmt.allocPrint(allocator, "{s}/src/root.zig", .{user_input});
    defer allocator.free(full_path_formatted); // Free this memory

    var file = try std.fs.cwd().createFile(full_path_formatted, .{});
    defer file.close();
    const content = "const std = @import(\"std\");\n" ++
        "const testing = std.testing;\n\n" ++
        "export fn add(a: i32, b: i32) i32 {\n" ++
        "    return a + b;\n" ++
        "}\n\n" ++
        "test \"basic add functionality\" {\n" ++
        "    try testing.expect(add(3, 7) == 10);\n" ++
        "}\n";
    try file.writeAll(content);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var input_buf: [100]u8 = undefined;
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    try stdout.print("Write a name for your project\n", .{});

    if (try stdin.readUntilDelimiterOrEof(input_buf[0..], '\n')) |user_input| {
        const allocator = gpa.allocator();
        const cwd = std.fs.cwd();

        const full_path_formatted_w_src = try std.fmt.allocPrint(allocator, "{s}/src", .{user_input});
        defer allocator.free(full_path_formatted_w_src); // Free this memory

        try cwd.makePath(full_path_formatted_w_src);

        // Allocate memory for the path with /src/main.zig
        const full_path_formatted = try std.fmt.allocPrint(allocator, "{s}/src/main.zig", .{user_input});
        defer allocator.free(full_path_formatted); // Free this memory

        try stdout.print("Project Created Successfully!\n", .{});

        // Create file and write content
        var file_create = try std.fs.cwd().createFile(full_path_formatted, .{});
        defer file_create.close();

        const program =
            "const std = @import(\"std\");\n" ++
            "\n" ++
            "pub fn main() void {\n" ++
            "    std.debug.print(\"Hello, from ZigSkeleton\\n\", .{});\n" ++
            "}\n";

        try file_create.writeAll(program);
        try create_root_file(user_input);
        try create_build_file(user_input);
    }
}
