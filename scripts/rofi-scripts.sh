#!/usr/bin/env bash
# rofi-scripts.sh: Launch a rofi menu to select and run media scripts.

set -euo pipefail

# Rofi menu options
options="🖼️ Image
🎥 Video
🎵 Audio"

# Show rofi menu and get the user's choice
selected_option=$(echo -e "$options" | rofi -dmenu -i -p "Select media type")

# Execute the corresponding script based on the selection
# The scripts are expected to be in the PATH without the .sh extension
case "$selected_option" in
    "🖼️ Image")
        rofi-image
        ;;
    "🎥 Video")
        rofi-video
        ;;
    "🎵 Audio")
        rofi-audio
        ;;
    *)
        # If the user escapes or selects nothing, do nothing.
        exit 0
        ;;
esac
