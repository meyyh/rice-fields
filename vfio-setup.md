# warning

this guide is specific to nvidia gpus so if you dont have one make sure you know what you are typing and why.
there are a few minor differences if you have an amd cpu but the biggest thing is you **MUST** have 2 gpus for me thats an RTX 2070 and the iGPU of my 12600k we will rendering one of the useless to the host system while the vm is using it.

# this guide assumes that

- you are using arch linux
- [yay](https://github.com/Jguer/yay) is installed and multilib repo is enabled
- you have 2 monitors
- your motherboard needs to have 2 video out
    - if you dont you will need to swap a cable from gpu to motherboard constantly
- the main one is plugged into gpu via DP and mobo via HDMI
- the secondary one is plugged into the mobo by DP
- you using grub if you are not you can reference the [Kernel parameters](https://wiki.archlinux.org/title/Kernel_parameters) arch wiki page on what to do
- you are using hyprland and sddm
    - I dont know how much this matters but be aware its using wayland

# setup
## install required packages
```
yay -Syu && yay -S linux-firmware linux-headers
```
## intall gpu specific drivers 

for me this is nvidia-open-dkms and intel-media-driver.
but make double check what driver you should use in the [NVIDIA](https://wiki.archlinux.org/title/NVIDIA) [AMD](https://wiki.archlinux.org/title/AMDGPU) [INTEL](https://wiki.archlinux.org/title/Intel_graphics) arch wiki pages
```
yay -S nvidia-open-dkms intel-media-driver
```
## nvidia driver 
if you are using nvidia go to section 1.3.1.3 of the nvidia page and setup the pacman hook otherwise if you forget to regen initramfs after a kernel update your system wont boot

now add ```i915 vfio_pci vfio vfio_iommu_type1``` to MODULES=() and ~~~modprobe~~~in /etc/mkinitcpio.conf



add nvidia_drm.modeset=1 in grub cfg according to hyprland wiki


then run grub-mkconfig

also add options nvidia-drm modeset=1 to /etc/modprobe.d/nvidia.conf

then regen cpio

install vscodium

wayland version crashes

for normal vscode replace VSCodium with code

needed to install qt5/6-wayland

nvm thats hard we using thunderbird for email and tasks

now i install japanese font so instead of not understanding ascii error i can enjoy not understanding japanese but i can copy and paste (ﾉ◕ヮ◕)ﾉ*:・ﾟ✧

lol the ascii is broke without jp font

install ttf-hanazono ttf-symbola for ascii emojis

install ttf-font-awesome for waybar but its using jp text for icons? tries to install ttf-jetbrains-mono did not help will fix this later

to fix workspaces edit /etc/xdg/waybar/config and chage sway/workspaces to hyprland/workspaces

now we steam ahead with sl jk were installing steam and pick nvidia option cus you know nvidia gpu

now we install remmina and freerdp so i can access my linux iso seeding serber

i installed qpwgraph to help trouble shoot remmina audio not working also change audio from non to local in advaced

for some reason pipewire-pulse/alsa was not installed

systemctl --user start pipewire-puls

installed gimp

now onto gpu passthrough yaaaaaaaaaaaaaaaaaaaaaaaaaaaay (I enjoy pain TᴖT)

here is a link that helped me last time
https://blandmanstudios.medium.com/tutorial-the-ultimate-linux-laptop-for-pc-gamers-feat-kvm-and-vfio-dee521850385

yay -S qemu-full virt-manager dnsmasq dmidecode



L systemcrash during install going to try updateing before see if that helps

system update did nothing just texinfo and qemu+virt manager installed fine so i guess were good?

sudo systemctl enable & start libvird

sudo usermod -aG libvirt USER so you dont need to enter root passwd

here comes my first issue with the guide it tells you to put "nvidia-drm.modeset=1 intel_iommu=on iommu=pt rd.driver.pre=vfio-pci rd.driver.blacklist=nouveau modprobe.blacklist=nouveau module_blacklist=nouveau" in your GRUB_CMDLINE_LINUX how do we figure out what vfio-pci.ids to put run this command lspci -nnk ok but what ones lol get fucked mabye its in a different spot in the video but it should be there when he tells us about it so on to the arch wiki
## dont add the vfio ids or gpu will be disabled by default


https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF bless this page i highly recomend reading it as its been very helpful for me when im confused on thing

the page does mention gpu-passthrough-manager but i never got it to work

quick aside im running an i5-12600k and rtx 2070 if you have an amd cpu or gpu or nvidia card older than 20 series you will likely have some different steps somewhere so just be aware of that

also


    Options in GRUB_CMDLINE_LINUX are always effective
    Options in GRUB_CMDLINE_LINUX_DEFAULT are effective ONLY during normal boot (NOT during recovery mode).



first thing we need to do is enable iommu so we are going to add all of the things the guide says but the pci ids to GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub

so the line should look something like this GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia_drm.modeset=1 intel_iommu=on iommu=pt rd.driver.pre=vfio-pci rd.driver.blacklist=nouveau modprobe.blacklist=nouveau module_blacklist=nouveau"

now reboot and pray to arch-chan

i must of not prayed hard enough as shit no workey

you can test it with the commands and scripts in the vfio arch wiki

no im just a fucking idjit and forgot to regen grub cfg

grub-mkconfig -o /boot/grub/grub.cfg


also do git config --global core.editor "vim"

[    0.049893] DMAR: IOMMU enabled 
poggies

ok here is where that bash script from the arch wiki comes in

here is what mine shows 
IOMMU Group 0:
	00:02.0 VGA compatible controller [0300]: Intel Corporation AlderLake-S GT1 [8086:4680] (rev 0c)
IOMMU Group 1:
	00:00.0 Host bridge [0600]: Intel Corporation Device [8086:4648] (rev 02)
IOMMU Group 2:
	00:01.0 PCI bridge [0604]: Intel Corporation 12th Gen Core Processor PCI Express x16 Controller #1 [8086:460d] (rev 02)
IOMMU Group 3:
	00:06.0 PCI bridge [0604]: Intel Corporation 12th Gen Core Processor PCI Express x4 Controller #0 [8086:464d] (rev 02)
IOMMU Group 4:
	00:14.0 USB controller [0c03]: Intel Corporation Alder Lake-S PCH USB 3.2 Gen 2x2 XHCI Controller [8086:7ae0] (rev 11)
	00:14.2 RAM memory [0500]: Intel Corporation Alder Lake-S PCH Shared SRAM [8086:7aa7] (rev 11)
IOMMU Group 5:
	00:15.0 Serial bus controller [0c80]: Intel Corporation Alder Lake-S PCH Serial IO I2C Controller #0 [8086:7acc] (rev 11)
IOMMU Group 6:
	00:16.0 Communication controller [0780]: Intel Corporation Alder Lake-S PCH HECI Controller #1 [8086:7ae8] (rev 11)
IOMMU Group 7:
	00:17.0 SATA controller [0106]: Intel Corporation Alder Lake-S PCH SATA Controller [AHCI Mode] [8086:7ae2] (rev 11)
IOMMU Group 8:
	00:1c.0 PCI bridge [0604]: Intel Corporation Device [8086:7aba] (rev 11)
IOMMU Group 9:
	00:1f.0 ISA bridge [0601]: Intel Corporation Z690 Chipset LPC/eSPI Controller [8086:7a84] (rev 11)
	00:1f.3 Audio device [0403]: Intel Corporation Alder Lake-S HD Audio Controller [8086:7ad0] (rev 11)
	00:1f.4 SMBus [0c05]: Intel Corporation Alder Lake-S PCH SMBus Controller [8086:7aa3] (rev 11)
	00:1f.5 Serial bus controller [0c80]: Intel Corporation Alder Lake-S PCH SPI Controller [8086:7aa4] (rev 11)
IOMMU Group 10:
	01:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU106 [GeForce RTX 2070] [10de:1f02] (rev a1)
	01:00.1 Audio device [0403]: NVIDIA Corporation TU106 High Definition Audio Controller [10de:10f9] (rev a1)
	01:00.2 USB controller [0c03]: NVIDIA Corporation TU106 USB 3.1 Host Controller [10de:1ada] (rev a1)
	01:00.3 Serial bus controller [0c80]: NVIDIA Corporation TU106 USB Type-C UCSI Controller [10de:1adb] (rev a1)
IOMMU Group 11:
	02:00.0 Non-Volatile memory controller [0108]: Micron/Crucial Technology P2 [Nick P2] / P3 / P3 Plus NVMe PCIe SSD (DRAM-less) [c0a9:540a] (rev 01)
IOMMU Group 12:
	03:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8125 2.5GbE Controller [10ec:8125] (rev 05)


i think you might need to add all of the things from a group im not sure but i thinnk you do so now im going to add vfio-pci.ids=10de:1f02,10de:10f9,10de:1ada,10de:1adb to grub cmd line

and remember kids alawys regen grub cfg before crossing the road

and reboot

now if you followed along perfectly and copied my config your hyprland will fail to load why ... fuck if i know time for troubleshooting

ah so libvirtd is mad about dnsmasq and dmidecode just intsall and reboot

so at this point i did not think hyprland would load but here we are

ah so vfio does not show up for drivers in lspci thats a bit of an issue

yep i forgor to add it to /etc/mkinitcpio.conf like section 3.2.2 of the arch wiki told me to 

sudo mkinitcpio -p linux and reboot

yay it failed to load WOOOOOOOOOOOOOO so at this point yo will need an hdmi cable from your mobo to your monitor to even be able to see tty

add a note later about enabling thing in bios for virtualization and chitset config

so at this point sddm start complaining about not being able to read from pipe but changing things in bios fixes it

yea changing primary graphics driver arround lets me boot not we need to change hyprland config to use mobo connection


at this point out gpu looks like this

	Subsystem: Gigabyte Technology Co., Ltd TU106 [GeForce RTX 2070] [1458:37c2]
	Kernel driver in use: vfio-pci
	Kernel modules: nouveau, nvidia_drm, nvidia

but how do we re enable our gpu oh very smart and wise writer of this guide who is very cool 
ah yes wll you see this is one of the parts i like about the medium article its the alias's that they have you add that can turn your gpu "on" and "off" with ease but thats if it works right away and if my past expirence has taught me anything its that im in over my head and i dont know what the fuck is going on

tangent aside

add the alias to your .bashrc file

i edited mine to not be so long and remove some of the un needed and yes i understand irony 

alias ls-gpu='echo "Nvidia" && lspci -nnk | grep "VGA" -A 2 | grep "NVIDIA" -A 2 | grep "driver in use"'
alias en-nvidia='sudo virsh nodedev-reattach pci_0000_01_00_0 && sudo rmmod vfio_pci vfio_pci_core vfio_iommu_type1 && sudo modprobe -i nvidia_modeset nvidia_uvm nvidia && echo "gpu enabled"'
alias dis-nvidia='sudo rmmod nvidia_modeset nvidia_uvm nvidia && sudo modprobe -i vfio_pci vfio_pci_core vfio_iommu_type1 && sudo virsh nodedev-detach pci_0000_01_00_0 && echo "gpu disabled"'

its a bit jank but much shorter and should still work i think

source .bashrc

ok ls-gpu

its vfio that means its "disabled" and able to be used for vms

now en-nvidia

less gooooo it worked

its using nvidia 

to to be able to use nvidia gpu on linux you must remove the vfio ids from grub and regen config

installed obs and gstreamer-vaapi and xdg-desktop-portal-hyprland

systemctl --user enable wireplumber
systemctl --user enable pipewire

install grim and slurp

screens sharing still does not work F

stating to setup catppuccin mocha

list of things im using it for 

hyprland
qt5/6

installed lightly-qt for a better qt5ct look

i will keep it but not using it atm

installed blender and p7zip


new reinstall


intstalled intel-gpu-tools and hypland is using igpu

the obs issue that made me reinstall was nvidia related works fine on intel igpu

installed qt5-wayland, qt5ct, os-prober and libva

all i had to do was intall the nvidia patch duh TᴖT

sticking with web version of discord as desktop screensharing works and installing steam

installing gamescope

uncomment the first line in waybar config to set its layer to top so context menus show up on top

install intel-media-driver and xf86-video-intel


nvidia_drm was being used and could not be disabled
https://unix.stackexchange.com/questions/440840/how-to-unload-kernel-module-nvidia-drm



I imagine you want to stop the display manager which is what I'd suspect would be using the Nvidia drivers.

After change to a text console (pressing Ctrl+Alt+F2) and logging in as root, use the following command to disable the graphical target, which is what keeps the display manager running:

# systemctl isolate multi-user.target

At this point, I'd expect you'd be able to unload the Nvidia drivers using modprobe -r (or rmmod directly):

# modprobe -r nvidia-drm

Once you've managed to replace/upgrade it and you're ready to start the graphical environment again, you can use this command:

# systemctl start graphical.target

that did not help after a reboot so i removed the drm part from /etc/default/grub

so i think the best option is to add the vfio ids back to grub because it keeps loading grub and sddm on gpu then once hyprland loads we can have it run the en-nvidia command to re enable it if we want

the video did the vgs and audio ones im also putting drm modeset back in

ok so only add i915 to mkinitcpio.conf and add all of the nvidia things including vfio ids so the gpu is disabled and the igpu can be the one used for loading as sddm gets confused still need to figure out how chaing the primary graphics optiions from auto to internal and back to auto fixes it but who knows then just have hyprland exec en-nvidia if you want to use it


now we have the nvidia gpu disabled and can start setting up the vm
download win 11/10 iso
download virtio drivers from here https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md 
open virt-manager and setup the vm make sure to toggle edit before install at the end and make sure its setup with Q35, and UEFI oh and enable tpm

now once you are at the desktop add your desktop shutdown and add the virtio iso and a small virtio disk to the vm then reboot and install the virtio drivers using the new small drive to check it works then shutdown and change the main drive to virt io interface by shuting down the vm and enable xml editing in edit/preferences in virt-manager and going to the drive clicking xml at the top and changing the target bus from sata to virtio and the address type from drive to pci ((note this part did not work for me windows said it could not access the drive but that can come later))

now its time to add the gpu shutdown the vm and add pci host device then the gpu and the sound card (still not sure if its needed) now plug in a monitor to your gpu if you have not already and you can have 1 from mobo and one from gpu going to a signle monitor but there will be extra issues if you do that so be aware but its what im doing so i sould be able to help with that

ok so all of the things in goup 10 from the arch wiki script need to be in the vfio pci list in grub and i think i dont know if i need to add all of them to the vm