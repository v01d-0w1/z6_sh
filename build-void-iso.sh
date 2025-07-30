#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
ISO_NAME="void-custom.iso"
WORKDIR="custom_root"
ISO_DIR="iso"
SQUASHFS_IMG="$WORKDIR/custom_rootfs.squashfs"
LIVE_USER="z6"
INCLUDE_DIRS=(img z6_sh git_repo workspace)
EXCLUDE_PATTERNS=(Music encoder code dot)
SIZE_LIMIT=$((3800 * 1024 * 1024))  # ~3.8 GiB

# === Spinner Function ===
show_loading() {
    local msg="$1"
    local pid="$2"
    local delay=0.1
    local frames=( "==>     " " ===>    " "  ====>   " "   =====>  " "    ======> " "     =======>" )
    echo -n "$msg "
    while kill -0 "$pid" 2>/dev/null; do
        for frame in "${frames[@]}"; do
            printf "\r%s %s" "$msg" "$frame"
            sleep "$delay"
        done
    done
    printf "\r%s ✅ Done\n" "$msg"
}

# === Start ===
echo "=== Building Live ISO for user '$LIVE_USER' ==="
rm -rf "$WORKDIR" "$ISO_DIR" "$ISO_NAME"
mkdir -p "$WORKDIR/home/$LIVE_USER" "$ISO_DIR/boot/isolinux"

# === Copy included dirs ===
echo -e "\n📦 Included directories:"
for d in "${INCLUDE_DIRS[@]}"; do
    echo " - $d"
    cp -a "$HOME/$d" "$WORKDIR/home/$LIVE_USER/" 2>/dev/null || echo "   (skipped: $d not found)"
done

echo -e "\n🚫 Excluded patterns:"
for ex in "${EXCLUDE_PATTERNS[@]}"; do
    echo " - $ex"
done

# === Size check ===
echo -e "\n📏 Calculating total size..."
DU_TOTAL=$(du -sb "$WORKDIR" | cut -f1)
echo "   Raw size: $((DU_TOTAL / 1024 / 1024)) MiB"

if (( DU_TOTAL > SIZE_LIMIT )); then
    echo "❌ Directory too large (>3.8 GiB). Remove or exclude more."
    exit 1
fi

# === Compress Root FS ===
echo -e "\n📦 Creating SquashFS..."
(mksquashfs "$WORKDIR" "$SQUASHFS_IMG" -comp zstd -no-progress > /dev/null) &
show_loading "Compressing rootfs" $!

COMP_SIZE=$(stat -c%s "$SQUASHFS_IMG")
echo "   Compressed size: $((COMP_SIZE / 1024 / 1024)) MiB"

if (( COMP_SIZE >= 4 * 1024 * 1024 * 1024 )); then
    echo "❌ SquashFS image is ≥4 GiB. ISO-9660 standard cannot handle this."
    exit 1
fi

# === Kernel and Initrd ===
echo -e "\n🧠 Copying kernel and initrd..."

KERNEL_IMG=$(ls /boot/vmlinuz-* | head -n1)
INITRD_IMG=$(find /boot -name 'initrd*' | head -n1)

mkdir -p "$ISO_DIR/boot"
if [[ ! -r "$INITRD_IMG" ]]; then
    echo "🔐 Running with sudo to access initrd..."
    sudo cp "$INITRD_IMG" "$ISO_DIR/boot/initrd.img"
else
    cp "$INITRD_IMG" "$ISO_DIR/boot/initrd.img"
fi
cp "$KERNEL_IMG" "$ISO_DIR/boot/vmlinuz"

# === Syslinux Bootloader ===
echo -e "\n🧰 Copying Syslinux bootloader files..."
cp /usr/lib/syslinux/isolinux.bin "$ISO_DIR/boot/isolinux/"
cp /usr/lib/syslinux/ldlinux.c32 "$ISO_DIR/boot/isolinux/"
cp "$SQUASHFS_IMG" "$ISO_DIR/custom_rootfs.squashfs"

# === isolinux.cfg ===
cat > "$ISO_DIR/boot/isolinux/isolinux.cfg" <<EOF
UI menu.c32
PROMPT 0
TIMEOUT 50
DEFAULT void
LABEL void
  MENU LABEL Boot Void Live
  KERNEL /boot/vmlinuz
  INITRD /boot/initrd.img
  APPEND root=/dev/ram0 rootflags=loop ro quiet
EOF

# === Create ISO ===
echo -e "\n💿 Building ISO image..."
xorriso -as mkisofs \
  -o "$ISO_NAME" \
  -isohybrid-mbr /usr/lib/syslinux/isohdpfx.bin \
  -c boot.cat \
  -b boot/isolinux/isolinux.bin \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -R -J \
  "$ISO_DIR"

echo -e "\n✅ ISO build complete: $ISO_NAME"

