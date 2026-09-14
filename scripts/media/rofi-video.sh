#!/usr/bin/env bash
# rofi-video.sh: Rofi-based script for video manipulation using ffmpeg.

set -euo pipefail

# --- Helper Functions ---

notify() {
    local message="$1"
    local urgency="${2:-normal}"
    notify-send "🎥 Video Script" "$message" -u "$urgency"
}

select_file() {
    local prompt="$1"
    fd . ~ -t f | rofi -dmenu -i -p "$prompt"
}

get_input() {
    local prompt="$1"
    local default_value="$2"
    rofi -dmenu -p "$prompt" -l 0 -mesg "$default_value"
}

# --- Main Operations ---

# 1. Convert Video
convert_video() {
    local input_file
    input_file=$(select_file "Select video to convert")
    [[ -z "$input_file" ]] && notify "No file selected. Aborting." "low" && exit 0

    local new_format
    new_format=$(get_input "New format (e.g., mp4, mkv, webm)" "mp4")
    [[ -z "$new_format" ]] && notify "No format entered. Aborting." "low" && exit 0

    local output_file="${input_file%.*}.$new_format"

    notify "Starting conversion... This may take a while."
    if ffmpeg -i "$input_file" "$output_file"; then
        notify "Successfully converted '$input_file' to '$output_file'."
    else
        notify "Failed to convert video." "critical"
    fi
}

# 2. Resize Video
resize_video() {
    local input_file
    input_file=$(select_file "Select video to resize")
    [[ -z "$input_file" ]] && notify "No file selected. Aborting." "low" && exit 0

    local scale
    scale=$(get_input "New resolution (e.g., 1280:720, 1920:-1)" "1280:720")
    [[ -z "$scale" ]] && notify "No resolution entered. Aborting." "low" && exit 0

    local output_file="${input_file%.*}_resized.${input_file##*.}"

    notify "Starting resize... This may take a while."
    if ffmpeg -i "$input_file" -vf "scale=$scale" "$output_file"; then
        notify "Successfully resized video to '$output_file'."
    else
        notify "Failed to resize video." "critical"
    fi
}

# 3. Crop Video
crop_video() {
    local input_file
    input_file=$(select_file "Select video to crop")
    [[ -z "$input_file" ]] && notify "No file selected. Aborting." "low" && exit 0

    local crop_params
    crop_params=$(get_input "Crop params (w:h:x:y)" "1280:720:0:0")
    [[ -z "$crop_params" ]] && notify "No crop params entered. Aborting." "low" && exit 0

    local output_file="${input_file%.*}_cropped.${input_file##*.}"
    
    notify "Starting crop... This may take a while."
    if ffmpeg -i "$input_file" -vf "crop=$crop_params" "$output_file"; then
        notify "Successfully cropped video to '$output_file'."
    else
        notify "Failed to crop video." "critical"
    fi
}


# --- Rofi Menu ---
options="Convert
Resize
Crop"

selected_action=$(echo -e "$options" | rofi -dmenu -i -p "Video Action")

case "$selected_action" in
    "Convert")
        convert_video
        ;;
    "Resize")
        resize_video
        ;;
    "Crop")
        crop_video
        ;;
    *)
        exit 0
        ;;
esac
