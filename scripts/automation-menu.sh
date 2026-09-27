#!/usr/bin/env bash
# automation-menu.sh: Rofi context menu for all Personal Automation Layer utilities.

set -euo pipefail

options="📦 extract
📦 archive
📄 fileinfo
🔗 share
🩺 doctor
🔍 nixcheck
📱 make-qr
👁️ clip-ocr
🧹 tidy-downloads
🖼️ img-resize
🖼️ img-compress
🎬 vid2audio
🎬 vid2gif
📄 pdf2text
✏️ batch-rename
🔁 find-duplicates
🔐 hashfile
🖼️ rofi-image
🎥 rofi-video
🎵 rofi-audio
🖼️ wallpaper"

selected=$(echo -e "$options" | rofi -dmenu -i -p "⚡ Automation" -theme-str "window { location: center; width: 300px; }")

case "$selected" in
    📦 extract)        extract ;;
    📦 archive)        archive ;;
    📄 fileinfo)       fileinfo ;;
    🔗 share)          share ;;
    🩺 doctor)         doctor ;;
    🔍 nixcheck)       nixcheck ;;
    📱 make-qr)        make-qr ;;
    👁️ clip-ocr)       clip-ocr ;;
    🧹 tidy-downloads) tidy-downloads ;;
    🖼️ img-resize)     img-resize ;;
    🖼️ img-compress)   img-compress ;;
    🎬 vid2audio)      vid2audio ;;
    🎬 vid2gif)        vid2gif ;;
    📄 pdf2text)       pdf2text ;;
    ✏️ batch-rename)    batch-rename ;;
    🔁 find-duplicates) find-duplicates ;;
    🔐 hashfile)       hashfile ;;
    🖼️ rofi-image)     rofi-image ;;
    🎥 rofi-video)     rofi-video ;;
    🎵 rofi-audio)     rofi-audio ;;
    🖼️ wallpaper)      wallpaper ;;
    *) exit 0 ;;
esac
