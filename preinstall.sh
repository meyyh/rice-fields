#!/bin/bash

DEBUG=false

if [[ "$1" == "-d" ]]; then
    DEBUG=true
fi

PLATFORM=$(cat /sys/firmware/efi/fw_platform_size)
if [ "$PLATFORM" != 64 ]; then
    echo not in 64bit uefi mode
    exit 1
fi

echo "Available disks:"
lsblk -d -o NAME,SIZE,MODEL

read -p "Enter the disk name: " DISK

DISK="/dev/$DISK"

#how did this work again
if lsblk "$DISK" &>/dev/null; then
    echo "You selected: $DISK"
else
    echo "Invalid disk."
    exit 1
fi



DISK_TYPE=$(sfdisk -l "$DISK" | grep "Disklabel type:" | awk '{print $3}')

if [ "$DISK_TYPE" != "gpt" ]; then
    echo "Selected disk is not gpt."
    exit 1
fi


read START END SECTORS SIZE_STR <<< $(sfdisk -F "$DISK" | tail -n 1)
if [ "$DEBUG" = true ]; then
    echo START: $START
    echo END: $END
    echo SECTORS: $SECTORS
    echo SIZE_STR: $SIZE_STR
fi

SIZE_NUMBER=$(echo "$SIZE_STR" | grep -oE '^[0-9.]+')
SIZE_UNIT=$(echo "$SIZE_STR" | grep -oE '[KMGTP]$')


#sfdisk -F can show 128G or 128K so we convert to mb
case "$SIZE_UNIT" in
    K) SIZE_MB=$(echo "$SIZE_NUMBER / 1024" | bc -l) ;;
    M) SIZE_MB="$SIZE_NUMBER" ;;
    G) SIZE_MB=$(echo "$SIZE_NUMBER * 1024" | bc -l) ;;
    T) SIZE_MB=$(echo "$SIZE_NUMBER * 1024 * 1024" | bc -l) ;;
    P) SIZE_MB=$(echo "$SIZE_NUMBER * 1024 * 1024 * 1024" | bc -l) ;;
    *) SIZE_MB="0" ;;
esac

if [ "$SIZE_MB" -lt "40000" ]; then
    echo "not enough free space on disk $SIZE_MB MB free"
    exit 1
fi

EFI_PART=$(( $(lsblk "$DISK" -o NAME,TYPE | grep part | wc -l) + 1 ))
BTRFS_PART=$(( EFI_PART + 1 ))
if [ "$DEBUG" = true ]; then
    echo EFI_PART: $EFI_PART
    echo BTRFS_PART: $BTRFS_PART
fi


sgdisk -n ${EFI_PART}:0:+1000M ${DISK}
sgdisk -n ${BTRFS_PART}:0:0    ${DISK}

sgdisk -t ${EFI_PART}:ef00   ${DISK}
sgdisk -t ${BTRFS_PART}:8300 ${DISK}

if [[ "$DISK" =~ nvme ]]; then
    PART_PREFIX="${DISK}p"
else
    PART_PREFIX="${DISK}"
fi

mkfs.fat -F 32 ${PART_PREFIX}${EFI_PART}
mkfs.btrfs ${PART_PREFIX}${BTRFS_PART}

mount ${PART_PREFIX}${BTRFS_PART} /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount /mnt

mount -o compress=zstd,subvol=@ ${PART_PREFIX}${BTRFS_PART} /mnt
mkdir -p /mnt/home
mount -o compress=zstd,subvol=@home ${PART_PREFIX}${BTRFS_PART} /mnt/home

mkdir -p /mnt/efi
mount ${PART_PREFIX}${EFI_PART} /mnt/efi

pacman -Sy
pacstrap -K /mnt base base-devel linux linux-firmware git btrfs-progs grub efibootmgr grub-btrfs inotify-tools timeshift vim networkmanager pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber reflector zsh zsh-completions zsh-autosuggestions openssh man sudo

genfstab -U /mnt >> /mnt/etc/fstab



arch-chroot /mnt /bin/bash <<"EOT"

ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc

sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
locale-gen

echo LANG=en_US.UTF-8 > /etc/locale.conf

sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf

echo -e "127.0.0.1 localhost\n::1 localhost" > /etc/hosts

echo "root:bob" | sudo chpasswd

useradd -mG wheel meyyh
echo "meyyh:bob" | sudo chpasswd

echo "%wheel ALL=(ALL:ALL) ALL" | sudo EDITOR='tee -a' visudo

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

sed -i 's|^ExecStart=/usr/bin/grub-btrfsd --syslog /.snapshots|#ExecStart=/usr/bin/grub-btrfsd --syslog /.snapshots\nExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto|' /etc/systemd/system/grub-btrfsd.service
systemctl enable grub-btrfsd

systemctl enable NetworkManager
EOT