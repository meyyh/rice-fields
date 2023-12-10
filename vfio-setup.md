# Warning

This guide is using an nvidia gpu and intel igpueven if you have a different config this guide can still help.
there only are a few minor differences if you have an amd cpu but the biggest thing is you **MUST** have 2 gpus.


- troubleshooting tips and other links at bottom

# My config
- hardware 
  - NVIDIA RTX 2070
  - i5 12600k with igpu
  - mobo with 2 video out
- OS: arch linux
  - [yay](https://github.com/Jguer/yay) is installed and multilib repo is enabled
  - grub bootloader
  - sddm login manager
  - hyprland a wayland window manager
- virtualization is enabled in bios




# Setup

### Install required packages
```
yay -Syu && yay -S linux-firmware linux-headers qemu-full virt-manager dnsmasq dmidecode
```
## Intall gpu specific drivers 

for me this is nvidia-open-dkms and intel-media-driver.
but make double check what driver you should use in the [NVIDIA](https://wiki.archlinux.org/title/NVIDIA) [AMD](https://wiki.archlinux.org/title/AMDGPU) [INTEL](https://wiki.archlinux.org/title/Intel_graphics) arch wiki pages
```
yay -S nvidia-open-dkms intel-media-driver
```
- If you are using an nvidia gpu go to section 1.3.1.3 of the [NVIDIA](https://wiki.archlinux.org/title/NVIDIA) page and setup the pacman hook for your gpu driver otherwise if you forget to regen initramfs after a kernel update your system wont boot.

## Initramfs config
Add ```i915 vfio_pci vfio vfio_iommu_type1``` to MODULES=() and ```modprobe``` is in HOOKS=() in `/etc/mkinitcpio.conf`
- you can remove `i915` if you are not using an intel igpu

type `sudo mkinitcpio -p linux` to regen initramfs then reboot and make sure the system works


## Grub config
if you are not using grub you can reference the [Kernel parameters](https://wiki.archlinux.org/title/Kernel_parameters) arch wiki page on what to do

edit `etc/default/grub` so your GRUB_CMDLINE_LINUX_DEFAULT looks like this but with different vfio-pci.ids
```
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet intel_iommu=on iommu=pt rd.driver.pre=vfio-pci vfio-pci.ids=10de:1f02,10de:10f9,10de:1ada,10de:1adb rd.driver.blacklist=nouveau modprobe.blacklist=nouveau module_blacklist=nouveau nvidia_drm.modeset=1"
```
- loglevel=3 quiet
>  - defaults  
  
- intel_iommu=on iommu=pt
>  - amd cpus dont need intel_iommu=on
- rd.driver.pre=vfio-pci vfio-pci.ids=###
>  - rd.driver.pre makes sure the vfio driver gets loaded first and i will explain how to get vfio-pci.ids in the next part
- rd.driver.blacklist=nouveau modprobe.blacklist=nouveau module_blacklist=nouveau
>  - dont load nouveau driver so if you dont have an nvidia card dont add these
- nvidia_drm.modeset=1
>  - still dont know if this is needed or not i think it was for the hyprland config but hyprland is running off igpu now

## how to get vfio-pci.ids 
in section 2.2 of the [wiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF) page it has a script to see your IOMMU groups. this is important beacause all or none of the devices in a group have to be "using" the vfio driver if you have only some of them using it you will just get a bunch of errors 



when I run the script I see my nvidia gpu is in group 10
```
OMMU Group 10:
	01:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU106 [GeForce RTX 2070] [10de:1f02] (rev a1)
	01:00.1 Audio device [0403]: NVIDIA Corporation TU106 High Definition Audio Controller [10de:10f9] (rev a1)
	01:00.2 USB controller [0c03]: NVIDIA Corporation TU106 USB 3.1 Host Controller [10de:1ada] (rev a1)
	01:00.3 Serial bus controller [0c80]: NVIDIA Corporation TU106 USB Type-C UCSI Controller [10de:1adb] (rev a1)
```
so my vfio ids look like this ```vfio-pci.ids=10de:1f02,10de:10f9,10de:1ada,10de:1adb```

now run `sudo grub-mkconfig -o /boot/grub/grub.cfg` but make sure your grub.cfg is in the same spot

after you reboot you can make sure it worked by running
```
sudo dmesg | grep -i -e DMAR -e IOMMU
```
and look for

> DMAR: IOMMU enabled

and

> DMAR: Intel(R) Virtualization Technology for Directed I/O

or something mentioning AMD-Vi for amd cpus

# disable and enable gpu
at this point if we type ```lspci | grep -E 'VGA|3D'``` we should see vfio-pci as the driver being used

```
Subsystem: Gigabyte Technology Co., Ltd TU106 [GeForce RTX 2070] [1458:37c2]
Kernel driver in use: vfio-pci
Kernel modules: nouveau, nvidia_drm, nvidia
```

this means that the gpu is in a "disabled" state and cant be used by the host if we want to "re-enable" it you can add 
```
alias ls-gpu='echo "Nvidia" && lspci -nnk | grep "VGA" -A 2 | grep "NVIDIA" -A 2 | grep "driver in use"'
alias en-nvidia='sudo virsh nodedev-reattach pci_0000_01_00_0 && sudo rmmod vfio_pci vfio_pci_core vfio_iommu_type1 && sudo modprobe -i nvidia_modeset nvidia_uvm nvidia && echo "gpu enabled"'
alias dis-nvidia='sudo rmmod nvidia_modeset nvidia_uvm nvidia && sudo modprobe -i vfio_pci vfio_pci_core vfio_iommu_type1 && sudo virsh nodedev-detach pci_0000_01_00_0 && echo "gpu disabled"'
```

to your .bashrc and running en-ndidia

> note that this is an edited version from [blandmanstudios's](https://blandmanstudios.medium.com/tutorial-the-ultimate-linux-laptop-for-pc-gamers-feat-kvm-and-vfio-dee521850385) guide
> I would recomend you take a look at his and edit it to your liking like I did as mine is shorter but less neat output
> ```
> alias hows-my-gpu='echo "NVIDIA Dedicated Graphics" | grep "NVIDIA" && lspci -nnk | grep "NVIDIA Corporation GA107M" -A 2 | grep "Kernel driver in use" && echo "Intel Integrated Graphics" | grep "Intel" && lspci -nnk | grep "Intel.*Integrated Graphics Controller" -A 3 | grep "Kernel driver in use" && echo "Enable and disable the dedicated NVIDIA GPU with nvidia-enable and nvidia-disable"'
> alias nvidia-enable='sudo virsh nodedev-reattach pci_0000_01_00_0 && echo "GPU reattached (now host ready)" && sudo rmmod vfio_pci vfio_pci_core vfio_iommu_type1 && echo "VFIO drivers removed" && sudo modprobe -i nvidia_modeset nvidia_uvm nvidia && echo "NVIDIA drivers added" && echo "COMPLETED!"'
> alias nvidia-disable='sudo rmmod nvidia_modeset nvidia_uvm nvidia && echo "NVIDIA drivers removed" && sudo modprobe -i vfio_pci vfio_pci_core vfio_iommu_type1 && echo "VFIO drivers added" && sudo virsh nodedev-detach pci_0000_01_00_0 && echo "GPU detached (now vfio ready)" && echo "COMPLETED!"'
> ```


- if when typing dis-nvidia and get that nvidia_uvm or nvidia_modeset is not loaded type `sudo modprobe -i nvidia_uvm nvidia_modeset` to load them the type dis-nvidia to disable them
need to figure out what is causing this

# virt-manager qemu/kvm etc

```
sudo systemctl enable libvirtd && sudo systemctl start libvirtd
```
  - start and enable qemu backend
```hai
sudo usermod -aG libvirt $(whoami) 
```
  - add yourself to libvirt group so you dont need to enter root passwd




and remember kids alawys regen grub cfg before crossing the road



yay it failed to load WOOOOOOOOOOOOOO so at this point yo will need an hdmi cable from your mobo to your monitor to even be able to see tty

add a note later about enabling thing in bios for virtualization and chitset config

so at this point sddm start complaining about not being able to read from pipe but changing things in bios fixes it

yea changing primary graphics driver arround lets me boot not we need to change hyprland config to use mobo connection




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
in order to switch between host and guest input the default is pressing both ctrl at the same time if you sont have 2 or want to chane it edit grabToggle 

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

# started working on this again
meyyh@arch ~]$ glxgears 
X Error of failed request:  BadValue (integer parameter out of range for operation)
  Major opcode of failed request:  150 (GLX)
  Minor opcode of failed request:  3 (X_GLXCreateContext)
  Value in failed request:  0x0
  Serial number of failed request:  26
  Current serial number in output stream:  27
  
also cant launch steam

sudo virsh net-autostart default

i get a display on the dp input on my monitor but i cant interact with the vm

setup ev dev to fix that 4.5 of the arch wiki link

make sure to diable the other "monitor" in windows that is not directly attached to the gpu

also to move an app to a different monitor its win + shift +1 arrow

now onto cpu pinning 5.1 of the arch wiki based on some help from the vfio discord they recoemeded that you dont pin e cores in the vm as it will not know whats an e vs p core plus they also said try not to mix L3 and L2 cache (reminder to put image of cpu layout lstopo) 

my p core are 0-11 so i change my vcpu line and add the cputune so it looks like this
```
...
<vcpu placement='static'>12</vcpu>
<cputune>
  <vcpupin vcpu='0' cpuset='0'/>
  <vcpupin vcpu='1' cpuset='1'/>
  <vcpupin vcpu='2' cpuset='2'/>
  <vcpupin vcpu='3' cpuset='3'/>
  <vcpupin vcpu='4' cpuset='4'/>
  <vcpupin vcpu='5' cpuset='5'/>
  <vcpupin vcpu='6' cpuset='6'/>
  <vcpupin vcpu='7' cpuset='7'/>
  <vcpupin vcpu='8' cpuset='8'/>
  <vcpupin vcpu='9' cpuset='9'/>
  <vcpupin vcpu='10' cpuset='10'/>
  <vcpupin vcpu='11' cpuset='11'/>
</cputune>
...
```

# dynamic isolation

5.4.2.1 i will be using the libvirt hook shown and note allowed cpus here is for the host not the guest so edit /etc/libvirt/hooks/qemu

note i needed to make the /etc/libvirt/hooks dir

```
#!/bin/sh

command=$2

if [ "$command" = "started" ]; then
    systemctl set-property --runtime -- system.slice AllowedCPUs=12,13,14,15
    systemctl set-property --runtime -- user.slice AllowedCPUs=12,13,14,15
    systemctl set-property --runtime -- init.scope AllowedCPUs=12,13,14,15
elif [ "$command" = "release" ]; then
    systemctl set-property --runtime -- system.slice AllowedCPUs=0-15
    systemctl set-property --runtime -- user.slice AllowedCPUs=0-15
    systemctl set-property --runtime -- init.scope AllowedCPUs=0-15
fi
```
remember to make it executable

when using this instead of a kenel parameter we can isolate and un isolate the core withoutneed to edit config file and reboot


# links
https://blandmanstudios.medium.com/tutorial-the-ultimate-linux-laptop-for-pc-gamers-feat-kvm-and-vfio-dee521850385
- other guide on how to set this up on a laptop but still helpful

https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF

# troubleshooting
after running ```sudo dmesg | grep -i -e DMAR -e IOMMU``` you dont see IOMMU enabled read over https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
