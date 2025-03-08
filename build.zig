const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const cross_target = b.resolveTargetQuery(.{ .abi = .eabi, .cpu_arch = .thumb, .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m0plus }, .os_tag = .freestanding });

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const native_lib = b.addStaticLibrary(.{
        .name = "tescu_native",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src-zig/root.zig"),
        .target = b.graph.host,
        .optimize = optimize,
    });
    native_lib.addIncludePath(b.path("src-c/"));
    const n_options = b.addOptions();
    n_options.addOption(bool, "pico", false);
    native_lib.root_module.addOptions("config", n_options);

    const native_exe = b.addExecutable(.{
        .name = "tescu_native",
        .root_source_file = b.path("src-zig/main.zig"),
        .target = b.graph.host,
        .optimize = optimize,
    });
    native_exe.root_module.addOptions("config", n_options);

    const cross_lib = b.addStaticLibrary(.{
        .name = "tescu",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src-zig/root.zig"),
        .target = cross_target,
        .optimize = optimize,
    });
    cross_lib.addIncludePath(b.path("src-c/"));
    const c_options = b.addOptions();
    c_options.addOption(bool, "pico", true);
    cross_lib.root_module.addOptions("config", c_options);

    b.installArtifact(native_lib);
    b.installArtifact(native_exe);
    b.installArtifact(cross_lib);

    const cmake_generate = b.addSystemCommand(&.{ "cmake", "-B", "./build" });
    cmake_generate.setName("cmake : generate project");

    const cmake_build = b.addSystemCommand(&.{ "cmake", "--build", "./build" });
    cmake_build.setName("cmake : build project");

    b.getInstallStep().dependOn(&cmake_build.step);
    cmake_build.step.dependOn(&cmake_generate.step);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(native_exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src-zig/root.zig"),
        .target = b.graph.host,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src-zig/main.zig"),
        .target = b.graph.host,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
