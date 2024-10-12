const std = @import("std");

pub fn build(b: *std.Build) void {
    var disabled_features = std.Target.Cpu.Feature.Set.empty;
    var enabled_features = std.Target.Cpu.Feature.Set.empty;

    disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.mmx));
    disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.sse));
    disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.sse2));
    disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.avx));
    disabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.avx2));
    enabled_features.addFeature(@intFromEnum(std.Target.x86.Feature.soft_float));

    const target_query = std.Target.Query{
        .cpu_arch = std.Target.Cpu.Arch.x86,
        .os_tag = std.Target.Os.Tag.freestanding,
        .abi = std.Target.Abi.none,
        .cpu_features_sub = disabled_features,
        .cpu_features_add = enabled_features,
    };
    const optimize = b.standardOptimizeOption(.{});

    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = b.path("src/kernel/main.zig"),
        .target = b.resolveTargetQuery(target_query),
        .optimize = optimize,
        .code_model = .kernel,
    });

    kernel.setLinkerScript(b.path("src/linker.ld"));
    b.installArtifact(kernel);

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.step);

    const iso_cmd = b.addSystemCommand(&.{ "bash", "scripts/iso.sh" });
    iso_cmd.step.dependOn(kernel_step);
    const iso_step = b.step("make-iso", "Prepare GRUB for the .elf file");
    iso_step.dependOn(&iso_cmd.step);

    const run_iso_cmd = b.addSystemCommand(&.{ "bash", "scripts/run_iso.sh" });
    run_iso_cmd.step.dependOn(kernel_step);
    run_iso_cmd.step.dependOn(iso_step);
    const run_iso_step = b.step("run-iso", "Run ISO file in an emulator");
    run_iso_step.dependOn(&run_iso_cmd.step);

    const run_uefi_cmd = b.addSystemCommand(&.{ "bash", "scripts/run-uefi.sh" });
    run_uefi_cmd.step.dependOn(kernel_step);
    run_uefi_cmd.step.dependOn(iso_step);
    const run_uefi_step = b.step("run-uefi", "Run ISO file in an emulator with UEFI firmware");
    run_uefi_step.dependOn(&run_uefi_cmd.step);

    const clean_cmd = b.addSystemCommand(&.{ "bash", "scripts/clean.sh" });
    const clean_step = b.step("clean", "Remove all generated files");
    clean_step.dependOn(&clean_cmd.step);
}
