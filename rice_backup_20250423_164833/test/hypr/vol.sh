#!/bin/bash
vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')

if [ $1 == "+" ]; then
	if awk "BEGIN {exit !($vol < 1.0)}"; then
		wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+
	fi
elif [ $1 == "-" ]; then
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-
fi
