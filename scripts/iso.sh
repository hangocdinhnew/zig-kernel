rm -rf zig-cache/iso_root
mkdir -p zig-cache/iso_root
cp -v zig-out/bin/kernel.elf zig-cache/iso_root/kernel.elf
cp -v misc/limine.conf zig-cache/limine/limine-bios.sys zig-cache/limine/limine-bios-cd.bin zig-cache/limine/limine-uefi-cd.bin zig-cache/iso_root
mkdir -p zig-cache/iso_root/EFI/BOOT
cp -v zig-cache/limine/BOOTX64.EFI zig-cache/iso_root/EFI/BOOT
cp -v zig-cache/limine/BOOTIA32.EFI zig-cache/iso_root/EFI/BOOT
mkdir out
xorriso -as mkisofs -b limine-bios-cd.bin -no-emul-boot -boot-load-size 4 -boot-info-table --efi-boot limine-uefi-cd.bin -efi-boot-part --efi-boot-image --protective-msdos-label zig-cache/iso_root -o out/mystupidkernel.iso
./zig-cache/limine/limine bios-install out/mystupidkernel.iso
