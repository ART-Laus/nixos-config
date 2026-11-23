#!/usr/bin/env bash
WALLPAPER_DIR="/home/artlaus/nixos-config/wallpapers"
STATE_FILE="$HOME/.cache/hyprpaper-current"

mapfile -t images < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.avif' \) | sort)
count=${#images[@]}
if [ "$count" -eq 0 ]; then
  exit 1
fi

mapfile -t monitors < <(hyprctl -j monitors | jq -r '.[].name')
if [ ${#monitors[@]} -eq 0 ]; then
  exit 1
fi

current=""
if [ -f "$STATE_FILE" ]; then
  current=$(<"$STATE_FILE")
fi

image=${images[0]}
if [ "$count" -gt 1 ]; then
  while true; do
    image=${images[RANDOM % count]}
    [ "$image" != "$current" ] && break
  done
fi

for monitor in "${monitors[@]}"; do
  hyprctl hyprpaper wallpaper "$monitor,$image" || exit 1
done
printf '%s\n' "$image" > "$STATE_FILE"
notify-send "Обои" "$(basename "$image")" -u low
