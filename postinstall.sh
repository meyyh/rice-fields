#!/bin/bash

if [ "$EUID" -eq 0 ]; then
  echo "This script must NOT be run as root. Exiting."
  exit 1
fi

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
yay -S timeshift-autosnap
