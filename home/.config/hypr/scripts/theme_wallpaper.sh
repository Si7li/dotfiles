#!/bin/bash

# Get the active theme config path from wallbash.conf
CONFIG_LINE=$(grep 'Configuration File:' "$HOME/.config/hypr/themes/wallbash.conf")
THEME_PATH=$(echo "$CONFIG_LINE" | cut -d '"' -f2)

# Get the directory from that path
THEME_DIR=$(dirname "$THEME_PATH")

# Define the wallpaper directory
WALLPAPER_DIR="$THEME_DIR/wallpapers"

# Check and set wallpaper
if [ -d "$WALLPAPER_DIR" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

    if [ -n "$WALLPAPER" ]; then
        awww img "$WALLPAPER" --transition-type any
        notify-send "HyDE Wallpaper" "Wallpaper set from: $WALLPAPER"
    else
        notify-send "HyDE Wallpaper" "No wallpapers found in $WALLPAPER_DIR"
    fi
else
    notify-send "HyDE Wallpaper" "Wallpaper directory not found: $WALLPAPER_DIR"
fi
