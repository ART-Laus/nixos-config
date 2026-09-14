#!/usr/bin/env bash
# rofi-image.sh: Rofi-based script for image manipulation using ImageMagick.

set -euo pipefail

# --- Helper Functions ---

# Send a notification
# Usage: notify "Message" "Optional: Urgency (low, normal, critical)"
notify() {
    local message="$1"
    local urgency="${2:-normal}"
    notify-send "🖼️ Image Script" "$message" -u "$urgency"
}

# Rofi-powered file browser
# Usage: select_file "Prompt"
select_file() {
    local prompt="$1"
    # Starting from the home directory, find files and let rofi pick one.
    # You can customize the find command (e.g., add -path to exclude dirs)
    fd . ~ -t f | rofi -dmenu -i -p "$prompt"
}

# Rofi-powered input box
# Usage: get_input "Prompt" "Default Value"
get_input() {
    local prompt="$1"
    local default_value="$2"
    rofi -dmenu -p "$prompt" -l 0 -mesg "$default_value"
}

# --- Main Operations ---

# 1. Convert Image
convert_image() {
    local input_file
    input_file=$(select_file "Select image to convert")
    [[ -z "$input_file" ]] && notify "No file selected. Aborting." "low" && exit 0

    local new_format
    new_format=$(get_input "New format (e.g., png, jpg, webp)" "png")
    [[ -z "$new_format" ]] && notify "No format entered. Aborting." "low" && exit 0

    local output_file="${input_file%.*}.$new_format"

    if convert "$input_file" "$output_file"; then
        notify "Successfully converted '$input_file' to '$output_file'."
    else
        notify "Failed to convert image." "critical"
    fi
}

# 2. Resize Image
resize_image() {
    local input_file
    input_file=$(select_file "Select image to resize")
    [[ -z "$input_file" ]] && notify "No file selected. Aborting." "low" && exit 0

    local geometry
    geometry=$(get_input "New size (e.g., 1920x1080, 50%)" "50%")
    [[ -z "$geometry" ]] && notify "No size entered. Aborting." "low" && exit 0

    # We modify the file in-place, you might want to create a copy first.
    if mogrify -resize "$geometry" "$input_file"; then
        notify "Successfully resized '$input_file' to $geometry."
    else
        notify "Failed to resize image." "critical"
    fi
}

# 3. Crop Image
crop_image() {
    local input_file
    input_file=$(select_file "Select image to crop")
    [[ -z "$input_file" ]] && notify "No file selected. Aborting." "low" && exit 0

    local geometry
    geometry=$(get_input "Crop geometry (e.g., 640x480+100+150)" "widthxheight+x+y")
    [[ -z "$geometry" ]] && notify "No crop geometry entered. Aborting." "low" && exit 0

    local output_file="${input_file%.*}_cropped.${input_file##*.}"

    if convert "$input_file" -crop "$geometry" "$output_file"; then
        notify "Successfully cropped '$input_file' to '$output_file'."
    else
        notify "Failed to crop image." "critical"
    fi
}


# --- Rofi Menu ---
options="Convert
Resize
Crop"

selected_action=$(echo -e "$options" | rofi -dmenu -i -p "Image Action")

case "$selected_action" in
    "Convert")
        convert_image
        ;;
    "Resize")
        resize_image
        ;;
    "Crop")
        crop_image
        ;;
    *)
        exit 0
        ;;
esac
