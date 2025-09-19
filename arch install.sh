#!/bin/bash
# === Arch Install Script Dell 3500 NVMe ===
# !!! ATENȚIE: FORMATTEAZĂ PARTIȚIILE !!!

set -e

# === SETĂRI INIȚIALE ===
timedatectl set-ntp true
loadkeys en 2>/dev/null || true

# === FORMATĂRI ===
echo "[*] Formatez partițiile..."
mkfs.fat -F32 /dev/nvme0n1p1
mkswap /dev/nvme0n1p2
mkfs.ext4 /dev/nvme0n1p3

# === MONTARE ===
echo "[*] Montez partițiile..."
mount /dev/nvme0n1p3 /mnt
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi
swapon /dev/nvme0n1p2

# === INSTALARE PACHETE DE BAZĂ ===
echo "[*] Instalez pachetele de bază..."
pacstrap /mnt base linux linux-firmware vim networkmanager grub efibootmgr

# === FSTAB ===
echo "[*] Generez fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# === CONFIGURARE ÎN CHROOT ===
echo "[*] Configurez sistemul în chroot..."
arch-chroot /mnt /bin/bash <<'EOF'
ln -sf /usr/share/zoneinfo/Europe/Bucharest /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "archlaptop" > /etc/hostname
systemctl enable NetworkManager
passwd   # aici setezi parola root manual când rulează scriptul

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EOF

echo "=== INSTALARE TERMINATĂ ==="
echo "Rulează: umount -R /mnt && reboot"
