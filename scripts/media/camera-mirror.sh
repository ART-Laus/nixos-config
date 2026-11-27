#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

device=""
for candidate in /dev/video*; do
  [ -e "$candidate" ] || continue
  device="$candidate"
  break
done

if [ -z "$device" ]; then
  notify-send -u critical "Камера не найдена" "Проверьте камеру в BIOS и подключение устройства"
  exit 1
fi

input_conf="$(mktemp)"
trap 'rm -f "$input_conf"' EXIT
cat > "$input_conf" <<'EOF'
MBTN_LEFT_DBL cycle fullscreen
MBTN_RIGHT_DBL cycle fullscreen
EOF

exec mpv "$device" \
  --no-config \
  --no-terminal \
  --msg-level=all=error \
  --force-window=immediate \
  --cache=no \
  --untimed \
  --demuxer-lavf-o=video_size=1280x720,framerate=30,input_format=mjpeg \
  --vf=hflip \
  --no-audio \
  --osc=no \
  --osd-level=0 \
  --osd-bar=no \
  --border=no \
  --input-conf="$input_conf" \
  --title="Камера (зеркало)" \
  --geometry=640x480+640+180 \
  --ontop \
  --keep-open=yes
