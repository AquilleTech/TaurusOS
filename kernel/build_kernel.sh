#!/bin/bash
set -e

KERNEL_DIR="linux-6.12.87"
ARCH=arm64
CROSS=aarch64-linux-gnu-

echo "[*] Generating defconfig untuk QEMU ARM64 (virt machine)..."
cd "$KERNEL_DIR"

# Mulai dari defconfig standar ARM64
make ARCH=$ARCH CROSS_COMPILE=$CROSS defconfig

# Aktifkan config penting untuk QEMU virt + IoT
# Networking
scripts/config --enable CONFIG_VIRTIO_NET
scripts/config --enable CONFIG_VIRTIO_PCI
scripts/config --enable CONFIG_VIRTIO_BLK
# Serial console (wajib untuk -nographic)
scripts/config --enable CONFIG_SERIAL_AMBA_PL011
scripts/config --enable CONFIG_SERIAL_AMBA_PL011_CONSOLE
# Filesystem
scripts/config --enable CONFIG_EXT4_FS
scripts/config --enable CONFIG_TMPFS
# Minimalkan untuk compile lebih cepat
scripts/config --disable CONFIG_DEBUG_KERNEL
scripts/config --disable CONFIG_SOUND
scripts/config --disable CONFIG_USB_SUPPORT

# Sync config
make ARCH=$ARCH CROSS_COMPILE=$CROSS olddefconfig

echo "[*] Building kernel... (ini butuh ~30-50 menit)"
make ARCH=$ARCH CROSS_COMPILE=$CROSS -j$(nproc) Image

echo "[+] Kernel selesai: arch/arm64/boot/Image"
cd ..
