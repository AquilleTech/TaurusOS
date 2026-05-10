#!/bin/bash
set -e

BUSYBOX_DIR="busybox-1.36.1"
ROOTFS_DIR="$(pwd)/rootfs_out"
ARCH=arm64
CROSS=aarch64-linux-gnu-

echo "[*] Build BusyBox static ARM64..."
cd "$BUSYBOX_DIR"

make ARCH=$ARCH CROSS_COMPILE=$CROSS defconfig

# Wajib: static agar tidak butuh shared library
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
# Matikan fitur yang tidak perlu
sed -i 's/CONFIG_TC=y/# CONFIG_TC is not set/' .config

make ARCH=$ARCH CROSS_COMPILE=$CROSS -j$(nproc)
make ARCH=$ARCH CROSS_COMPILE=$CROSS \
     CONFIG_PREFIX="$ROOTFS_DIR" install

cd ..

echo "[*] Buat struktur direktori rootfs..."
mkdir -p "$ROOTFS_DIR"/{proc,sys,dev,tmp,etc,root,var/log}

echo "[*] Copy init script..."
cp rootfs/init "$ROOTFS_DIR/init"
chmod +x "$ROOTFS_DIR/init"

# Buat /etc/passwd minimal
cat > "$ROOTFS_DIR/etc/passwd" << 'EOF'
root:x:0:0:root:/root:/bin/sh
EOF

# Buat /etc/hostname
echo "myos" > "$ROOTFS_DIR/etc/hostname"

echo "[*] Buat initramfs.cpio.gz..."
cd "$ROOTFS_DIR"
find . | cpio -H newc -o 2>/dev/null | gzip -9 > "$(pwd)/../initramfs.cpio.gz"
cd ..

echo "[+] Selesai! initramfs.cpio.gz siap."
ls -lh initramfs.cpio.gz
