#!/bin/bash
set -x
virtwall(){
	WALLPAPER_DIR="$HOME/.config/hypr/walls/virt"
	#CURRENT_WALL=$(hyprctl hyprpaper listloaded)

	# Get a random wallpaper that is not the current one
	#WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)
	WALLPAPER=$(find "$WALLPAPER_DIR" -name "*.*" | shuf -n 1)

	# Apply the selected wallpaper
	hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER"
	echo "asdfasdf"
}


transform=$(hyprctl monitors -j | jq '.[0].transform')

if [ "$transform" -eq 1 ]; then
	hyprctl keyword monitor eDP-1,2256x1504,0x0,1.566667,transform,0
	sleep 0.1 #hyprpaper crashed without
	hyprctl hyprpaper wallpaper "eDP-1,$HOME/.config/hypr/walls/fr_wallpaper.png"

	pkill -9 waybar
	waybar
elif [ "$transform" -eq 0 ]; then
	hyprctl keyword monitor eDP-1,2256x1504,0x0,1.566667,transform,1
	sleep 0.1 #hyprpaper crashed without
	virtwall

	pkill -9 waybar
	waybar -c $HOME/.config/waybar/config-virt.jsonc -s $HOME/.config/waybar/style-virt.css
else
	echo ""
fi
