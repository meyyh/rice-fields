#!/bin/bash

#this is designed to be run after an fresh install with systemd boot

# require root
if [ "$(id -u)" -ne 0 ]; then
		        echo 'This script must be run by root' >&2
    exit 1
fi

user="meyyh"

pkgs=(
    #wayland
    sddm
    hyprland
    xdg-desktop-portal-hyprland
    kitty
    wayland
    wofi
    dunst
    polkit-kde-agent 
    swaybg 
    swaylock-effects
    qt6-wayland
    qt5-wayland
    grim
    slurp

    keepassxc
    thunar
    htop
    firefox
    gimp
    blender
    p7zip

    linux-headers
    linux-firmware
    cifs-utils
    ntfs-3g
    less
    texinfo
    man-db
    man-pages
    openssh
    os-prober
    intel-gpu-tools
    steam

    remmina
    freerdp

    #video/audio
    wireplumber
    pipewire-pulse
    pipewire-jack
    pipewire-alsa
    pipewire
    mpd

    #gpu drivers
    nvidia-open-dkms
    intel-media-driver

    #vm things
    qemu-full 
    virt-manager 
    dnsmasq 
    dmidecode

    #editors
    neovim
    vscodium-bin
    vscodium-bin-features
    vscodium-bin-marketplace

    #fonts
    otf-font-awesome #needed for waybar icons
)

# edit pacman config
sed -i -e '/^#Color/s/^#//' \
       -e '/^#ParallelDownloads = 5/s/^#//' \
       -e "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

#run as user because yay tells you to not run it as root
#EOF things are so it cant prompt you for root password
sudo -u $user bash << EOF
yay -Syu --noconfirm
yay -S --needed --noconfirm ${pkgs[@]}
EOF

#needed to stop the wayland version form crashing on hyprland
vscodium_settings='{
    "window.titleBarStyle": "custom"
}'
echo "$vscodium_settings" > /home/$user/.config/VSCodium/User/settings.json

#make dirs for my other drives
mkdir /c 
mkdir /hdd
mkdir /mx500
mkdir /serber

sudo systemctl enable sddm

#configure vm things
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo usermod -aG libvirt $user
virsh net-autostart default
virsh net-start default
sudo sed -i '/^MODULES=/ {/ i915 vfio_pci vfio vfio_iommu_type1/! s/\(MODULES=\([^)]*\)/\1 i915 vfio_pci vfio vfio_iommu_type1/}' /etc/mkinitcpio.conf
sudo sed -i '/^HOOKS=/ {/ modconf/! s/\(HOOKS=\([^)]*\)/\1 modconf/}' /etc/mkinitcpio.conf


boot_file="/boot/loader/entries/arch.conf"
if [ -e "$boot_file" ]; then
    sudo sed -i '/^options/ {/ intel_iommu=on iommu=pt rd\.driver\.pre=vfio-pci vfio-pci\.ids=10de:1f02,10de:10f9,10de:1ada,10de:1adb rd\.driver\.blacklist=nouveau modprobe\.blacklist=nouveau module_blacklist=nouveau/! s/$/ intel_iommu=on iommu=pt rd.driver.pre=vfio-pci vfio-pci.ids=10de:1f02,10de:10f9,10de:1ada,10de:1adb rd.driver.blacklist=nouveau modprobe.blacklist=nouveau module_blacklist=nouveau/}' "$boot_file"
else
    echo "Error: $boot_file does not exist. Exiting."
    exit 1
fi

#intel gpu drivers
cat "options i915 enable_guc=3" > /etc/modprobe.d/i915.conf

mkdir -p /etc/libvirt/hooks

qemu_hook='#!/bin/sh

command=$2

if [ "$command" = "started" ]; then
    systemctl set-property --runtime -- system.slice AllowedCPUs=12,13,14,15
    systemctl set-property --runtime -- user.slice AllowedCPUs=12,13,14,15
    systemctl set-property --runtime -- init.scope AllowedCPUs=12,13,14,15
elif [ "$command" = "release" ]; then
    systemctl set-property --runtime -- system.slice AllowedCPUs=0-15
    systemctl set-property --runtime -- user.slice AllowedCPUs=0-15
    systemctl set-property --runtime -- init.scope AllowedCPUs=0-15
fi'

echo "$qemu_hook" > /etc/libvirt/hooks/qemu
chmod +x /etc/libvirt/hooks/qemu

nvidia_hook="[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia-open-dkms
Target=linux
# Change the linux part above if a different kernel is used

[Action]
Description=Update NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'"

mkdir /etc/pacman.d/hooks
echo "$nvidia_hook" > /etc/pacman.d/hooks/nvidia.hook


mkinitcpio -p linux

bootctl update
