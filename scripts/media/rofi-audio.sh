#!/usr/bin/env bash
# rofi-audio.sh: Rofi-based script for audio manipulation using ffmpeg.

set -euo pipefail

# --- Helper Functions ---

notify() {
    local message="$1"
    local urgency="${2:-normal}"
    notify-send "🎵 Audio Script" "$message" -u "$urgency"
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

# 1. Convert Audio
convert_audio() {
    local input_file
    input_file=$(select_file "Select audio to convert")
    [[ -z "$input_file" ]] && notify "No file selected. Aborting." "low" && exit 0

    local new_format
    new_format=$(get_input "New format (e.g., mp3, ogg, flac)" "mp3")
    [[ -z "$new_format" ]] && notify "No format entered. Aborting." "low" && exit 0

    local output_file="${input_file%.*}.$new_format"

    notify "Starting conversion..."
    if ffmpeg -i "$input_file" "$output_file"; then
        notify "Successfully converted '$input_file' to '$output_file'."
    else
        notify "Failed to convert audio." "critical"
    fi
}

# 2. Change Bitrate
change_bitrate() {
    local input_file
    input_file=$(select_file "Select audio to change bitrate")
    [[ -z "$input_file" ]] && notify "No file selected. Aborting." "low" && exit 0

    local bitrate
    bitrate=$(get_input "New audio bitrate (e.g., 192k, 128k)" "128k")
    [[ -z "$bitrate" ]] && notify "No bitrate entered. Aborting." "low" && exit 0

    local output_file="${input_file%.*}_br_${bitrate}.${input_file##*.}"

    notify "Changing bitrate..."
    if ffmpeg -i "$input_file" -b:a "$bitrate" "$output_file"; then
        notify "Successfully changed bitrate for '$output_file'."
    else
        notify "Failed to change bitrate." "critical"
    fi
}

# 3. Trim Audio
trim_audio() {
    local input_file
    input_file=$(select_file "Select audio to trim")
    [[ -z "$input_file" ]] && notify "No file selected. Aborting." "low" && exit 0

    local start_time
    start_time=$(get_input "Start time (HH:MM:SS)" "00:00:00")
    [[ -z "$start_time" ]] && notify "No start time. Aborting." "low" && exit 0

    local end_time
    end_time=$(get_input "End time (HH:MM:SS)" "00:00:10")
    [[ -z "$end_time" ]] && notify "No end time. Aborting." "low" && exit 0

    local output_file="${input_file%.*}_trimmed.${input_file##*.}"

    notify "Trimming audio..."
    if ffmpeg -i "$input_file" -ss "$start_time" -to "$end_time" -c copy "$output_file"; then
        notify "Successfully trimmed audio to '$output_file'."
    else
        notify "Failed to trim audio." "critical"
    fi
}


# --- Rofi Menu ---
options="Convert
Change Bitrate
Trim"

selected_action=$(echo -e "$options" | rofi -dmenu -i -p "Audio Action")

case "$selected_action" in
    "Convert")
        convert_audio
        ;;
    "Change Bitrate")
        change_bitrate
        ;;
    "Trim")
        trim_audio
        ;;
    *)
        exit 0
        ;;
esac
