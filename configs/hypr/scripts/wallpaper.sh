#!/bin/bash
# wallpaper.sh — MASU Hyprland v2.0

if [ -n "$1" ]; then
    WALLPAPER="$1"
else
    WALLPAPER=$(grep "^wallpaper" ~/.config/waypaper/config.ini 2>/dev/null \
        | cut -d'=' -f2 | xargs | sed "s|~|$HOME|g")
fi

[ -f "$WALLPAPER" ] || { echo "Error: wallpaper not found: $WALLPAPER"; exit 1; }

echo "Applying: $WALLPAPER"

# Set wallpaper
swww img "$WALLPAPER" --transition-type random --transition-duration 2 --transition-fps 60 &

# Generate pywal colors
wal -i "$WALLPAPER" -n 2>/dev/null

# Sync color files
[ -f ~/.cache/wal/colors-waybar.css ]    && cp ~/.cache/wal/colors-waybar.css  ~/.config/waybar/colors.css
[ -f ~/.cache/wal/colors-wofi.css ]      && cp ~/.cache/wal/colors-wofi.css    ~/.config/wofi/style.css
[ -f ~/.cache/wal/wob.ini ]              && cp ~/.cache/wal/wob.ini             ~/.config/wob/wob.ini
[ -f ~/.cache/wal/dunstrc ]              && cp ~/.cache/wal/dunstrc              ~/.config/dunst/dunstrc
[ -f ~/.cache/wal/hyprland-colors.conf ] && cp ~/.cache/wal/hyprland-colors.conf ~/.config/hypr/hyprland-colors.conf

# Sync hyprlock wallpaper
~/.config/hypr/scripts/hyprlock_wall.sh "$WALLPAPER"

# Sync SDDM colors and wallpaper
sudo cp "$WALLPAPER" /usr/share/sddm/themes/catppuccin/backgrounds/current-wall.jpg 2>/dev/null
~/.config/hypr/scripts/sddm-colors.sh

# Reload hyprland colors
hyprctl reload 2>/dev/null

# Restart services
killall waybar 2>/dev/null; waybar &
pkill dunst    2>/dev/null; dunst &

# Restart wob pipe
pkill wob 2>/dev/null
rm -f /tmp/wobpipe
mkfifo /tmp/wobpipe
tail -f /tmp/wobpipe | wob -c ~/.config/wob/wob.ini &

echo "Done."
