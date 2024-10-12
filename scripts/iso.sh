mkdir -p out/isodir/boot/grub
cp zig-out/bin/kernel.elf out/isodir/boot/kernel.elf
cp misc/grub.cfg out/isodir/boot/grub/grub.cfg
grub-mkrescue -o out/kernel.iso out/isodir
