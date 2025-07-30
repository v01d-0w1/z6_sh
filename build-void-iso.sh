
#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
ISO_NAME="Z6.iso"
WORKDIR="custom_root"
ISO_DIR="iso"
SQUASHFS_IMG="$WORKDIR/custom_rootfs.squashfs"
LIVE_USER="z6"
INCLUDE_DIRS=(img z6_sh git_repo workspace)
EXCLUDE_PATTERNS=(Music encoder code dot)
SIZE_LIMIT=$((3800 * 1024 * 1024))  # ~3.8 GiB

# === Functions ===
loading_bar() {
    local pid=$1
    local msg="$2"
    local bar=""
    local i=0
    local chars="===========>"
    echo -n "$msg "
    while kill -0 "$pid" 2>/dev/null; do
        bar="${chars:0:$((i % ${#chars}))}"
        printf "\r%s [%s]" "$msg" "$bar"
        i=$((i + 1))
        sleep 0.1
    done
    printf "\r%s [%s] :)\n" "$msg" "$chars"
}

run_with_animation() {
    local cmd="$1"
    local msg="$2"
    bash -c "$cmd" &
    loading_bar $! "$msg"
}

# === Start ===
echo "=== Building Z6 Live ISO for user '$LIVE_USER' ==="
rm -rf "$WORKDIR" "$ISO_DIR" "$ISO_NAME"
mkdir -p "$WORKDIR/home/$LIVE_USER" "$ISO_DIR/boot/isolinux" "$ISO_DIR/EFI/boot"

echo
echo "Included directories:"
for d in "${INCLUDE_DIRS[@]}"; do
    echo " - $d"
    cp -a "$HOME/$d" "$WORKDIR/home/$LIVE_USER/" 2>/dev/null || echo "   (skipped: $d not found)"
done

echo
echo "Excluded patterns:"
for ex in "${EXCLUDE_PATTERNS[@]}"; do
    echo " - $ex"
done

echo
echo "Calculating total size..."
DU_TOTAL=$(du -sb "$WORKDIR" | cut -f1)
echo " Raw size: $((DU_TOTAL / 1024 / 1024)) MiB"

if (( DU_TOTAL > SIZE_LIMIT )); then
    echo "X Directory too large (>3.8 GiB). Please remove files or exclude more."
    exit 1
fi

echo
echo "Creating SquashFS image..."
run_with_animation "mksquashfs '$WORKDIR' '$SQUASHFS_IMG' -comp zstd -no-progress" "Compressing rootfs..."

COMP_SIZE=$(stat -c%s "$SQUASHFS_IMG")
echo " Compressed size: $((COMP_SIZE / 1024 / 1024)) MiB"

if (( COMP_SIZE >= 4 * 1024 * 1024 * 1024 )); then
    echo "X SquashFS image is ≥4 GiB. ISO-9660 will not support this."
    exit 1
fi

# Copy Kernel and Initrd
KERNEL_IMG=$(ls /boot/vmlinuz-* | head -n1)
INITRD_IMG=$(ls /boot/initrd* | head -n1)

echo
echo "Copying Kernel and Initrd..."
cp "$KERNEL_IMG" "$ISO_DIR/boot/vmlinuz"
if [[ ! -r "$INITRD_IMG" ]]; then
    echo "Using sudo to copy initrd.img..."
    sudo cp "$INITRD_IMG" "$ISO_DIR/boot/initrd.img"
    sudo chown "$USER:$USER" "$ISO_DIR/boot/initrd.img"
else
    cp "$INITRD_IMG" "$ISO_DIR/boot/initrd.img"
fi

chmod -R a+r "$ISO_DIR/boot"

# Syslinux Boot (BIOS)
cp /usr/lib/syslinux/isolinux.bin "$ISO_DIR/boot/isolinux/"
cp /usr/lib/syslinux/ldlinux.c32 "$ISO_DIR/boot/isolinux/"

cat > "$ISO_DIR/boot/isolinux/isolinux.cfg" <<EOF
UI menu.c32
PROMPT 0
TIMEOUT 50
DEFAULT void

LABEL void
  MENU LABEL Boot Z6 Live
  KERNEL /boot/vmlinuz
  INITRD /boot/initrd.img
  APPEND ro rd.live.image root=live:CDLABEL=Z6 quiet
EOF

# GRUB EFI Boot
cat > "$ISO_DIR/EFI/boot/grub.cfg" <<EOF
set default=0
set timeout=1

menuentry "Z6 Live (Void)" {
    linux /boot/vmlinuz ro rd.live.image root=live:CDLABEL=Z6 quiet
    initrd /boot/initrd.img
}
EOF

grub-mkstandalone \
  -O x86_64-efi \
  -o "$ISO_DIR/EFI/boot/bootx64.efi" \
  --locales="" --fonts="" \
  "boot/grub/grub.cfg=$ISO_DIR/EFI/boot/grub.cfg"

cp "$SQUASHFS_IMG" "$ISO_DIR/custom_rootfs.squashfs"

echo
echo "Building final ISO..."
xorriso -as mkisofs \
  -o "$ISO_NAME" \
  -isohybrid-mbr /usr/lib/syslinux/isohdpfx.bin \
  -c boot.cat \
  -b boot/isolinux/isolinux.bin \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e EFI/boot/bootx64.efi \
    -no-emul-boot \
  -isohybrid-gpt-basdat \
  -V Z6 \
  -R -J -joliet-long \
  "$ISO_DIR"

echo
echo "ISO build complete: $ISO_NAME :)"
