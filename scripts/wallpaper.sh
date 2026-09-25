#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
IMAGE=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.avif" \) | shuf -n 1)
if [ -n "$IMAGE" ]; then
  hyprctl hyprpaper wallpaper ",$IMAGE"
fi
