#!/usr/bin/env bash

# now.sh: Fetches the currently playing track from Last.fm for Waybar.

# --- IMPORTANT ---
# You need to fill in your own Last.fm username and API key below.
# Get an API key here: https://www.last.fm/api/account/create

USER="YOUR_USERNAME"
API_KEY="YOUR_API_KEY"

# --- Script Logic ---

# Check if credentials are placeholders
if [[ "$USER" == "YOUR_USERNAME" ]] || [[ "$API_KEY" == "YOUR_API_KEY" ]]; then
    echo "Please edit the now.sh script to add your Last.fm username and API key."
    exit 0
fi

# Fetch data from Last.fm API
# We ask for the most recent track and check if it's marked as "nowplaying"
response=$(curl -s "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=${USER}&api_key=${API_KEY}&format=json&limit=1")

# Check if the API call was successful
if ! jq -e . >/dev/null 2>&1 <<<"$response"; then
  # API returned invalid JSON or nothing at all
  exit 0
fi

# Parse the JSON response with jq
now_playing=$(echo "$response" | jq -r '.recenttracks.track[] | select(."@attr".nowplaying == "true")')

# If a track is playing, format and print it. Otherwise, print nothing.
if [[ -n "$now_playing" ]]; then
    artist=$(echo "$now_playing" | jq -r '.artist."#text"')
    track=$(echo "$now_playing" | jq -r '.name')
    echo "$artist - $track"
else
    echo ""
fi
