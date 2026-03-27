#!/bin/bash
if hyprctl clients -j | jq -e '.[] | select(.class == "Spotify")' > /dev/null 2>&1; then
    hyprctl dispatch togglespecialworkspace spotify
else
    spotify &
fi
