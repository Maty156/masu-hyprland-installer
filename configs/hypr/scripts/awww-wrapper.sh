#!/bin/bash
# Intercepts matuwall awww calls
# Passes to real awww AND runs pywal

REAL_AWW=/usr/bin/awww
WALLPAPER="${@: -1}"

# Run real awww with original args
"$REAL_AWW" "$@"

# Then run our color pipeline
[ -f "$WALLPAPER" ] && bash ~/.config/hypr/scripts/wallpaper-colors.sh "$WALLPAPER" &
