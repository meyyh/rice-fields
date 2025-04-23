#!/bin/bash
for img in *.png *.jpg *.jpeg *.webp; do
    [ -f "$img" ] || continue  # skip if no match
    gm convert "$img" -resize 400x400 png:- | kitty +kitten icat
done
