const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("upstream", .{});

    const ubootenv = b.addLibrary(.{
        .name = "ubootenv",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/crc32.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    ubootenv.root_module.addIncludePath(b.path("include"));
    ubootenv.root_module.addCMacro("VERSION", "\"0.3.8\"");
    ubootenv.root_module.addCMacro("NO_YAML_SUPPORT", "");
    ubootenv.root_module.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = &ubootenv_sources,
    });
    ubootenv.installHeader(upstream.path("src/libuboot.h"), "libuboot.h");
    b.installArtifact(ubootenv);

    const fw_printenv = b.addExecutable(.{
        .name = "fw_printenv",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    fw_printenv.root_module.linkLibrary(ubootenv);
    fw_printenv.root_module.addCSourceFile(.{
        .file = upstream.path("src/fw_printenv.c"),
        .flags = &.{"-Wno-date-time"},
    });
    b.installArtifact(fw_printenv);

    const crc32_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/crc32.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_crc32_tests = b.addRunArtifact(crc32_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_crc32_tests.step);
}

const ubootenv_sources = [_][]const u8{
    "uboot_env.c",
    "uboot_mtd.c",
    "extended_config.c",
    "fwu_mdata.c",
    "common.c",
};
