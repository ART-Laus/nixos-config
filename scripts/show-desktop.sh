#!/usr/bin/env bash
STATE_FILE="$HOME/.cache/hyprland-showdesktop"
SPECIAL="special:showdesktop"

mkdir -p "$(dirname "$STATE_FILE")"

if [ -f "$STATE_FILE" ]; then
  while IFS=' ' read -r addr ws; do
    [ -n "$addr" ] && [ -n "$ws" ] || continue
    hyprctl dispatch movetoworkspacesilent "$ws,address:$addr" >/dev/null 2>&1
  done < "$STATE_FILE"
  rm -f "$STATE_FILE"
  exit 0
fi

hyprctl clients -j | jq -r '
  .[] | select(.mapped == true and (.workspace.name | startswith("special:") | not))
  | "\(.address) \(.workspace.id)"
' > "$STATE_FILE"

if [ ! -s "$STATE_FILE" ]; then
  rm -f "$STATE_FILE"
  exit 0
fi

while IFS=' ' read -r addr _ws; do
  [ -n "$addr" ] || continue
  hyprctl dispatch movetoworkspacesilent "$SPECIAL,address:$addr" >/dev/null 2>&1
done < "$STATE_FILE"
