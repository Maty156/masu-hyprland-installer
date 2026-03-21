#!/bin/bash
# hyprlock_wall.sh — MASU Hyprland v2.0
# Updates hyprlock.conf with current wallpaper path

HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"

if [ -n "$1" ]; then
    WALLPAPER="$1"
else
    WALLPAPER=$(cat ~/.cache/wal/wal 2>/dev/null)
fi

[ -f "$WALLPAPER" ] || exit 1
sed -i "s|^    path = .*|    path = $WALLPAPER|" "$HYPRLOCK_CONF"
