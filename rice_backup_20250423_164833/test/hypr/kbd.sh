#!/bin/bash
kbd_proc=$(ps -a | grep wvkbd | awk '{ print $4 }')

if [ "$kbd_proc" = "wvkbd-mobintl" ]; then
	pkill -9 wvkbd-mobintl
else
	hyprctl dispatch exec $HOME/gits/old/wvkbd/wvkbd-mobintl
fi
