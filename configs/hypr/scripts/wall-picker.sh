#!/bin/bash
# wall-picker.sh — MASU Hyprland v2.0
# Rofi thumbnail wallpaper picker — adapted from JaKooLit

WALL_DIR="$HOME/wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper-thumbs"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
ROFI_THEME="$HOME/.config/rofi/selector2.rasi"

FPS=60; TYPE="any"; DURATION=2; BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

mkdir -p "$THUMB_DIR"

focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
scale_factor=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .scale')
monitor_height=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .height')
icon_size=$(echo "scale=1; ($monitor_height * 3) / ($scale_factor * 150)" | bc)
adjusted_icon_size=$(echo "$icon_size" | awk '{if ($1 < 15) $1 = 20; if ($1 > 25) $1 = 25; print $1}')
rofi_override="element-icon{size:${adjusted_icon_size}%;}"

menu() {
    mapfile -d '' PICS < <(find -L "$WALL_DIR" -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
        -o -iname "*.webp" -o -iname "*.bmp" \) -print0)
    IFS=$'\n' sorted=($(sort <<<"${PICS[*]}"))
    for pic_path in "${sorted[@]}"; do
        pic_name=$(basename "$pic_path")
        thumb="$THUMB_DIR/${pic_name}.thumb.png"
        [ -f "$thumb" ] || convert "$pic_path" -resize 480x270^ -gravity center \
            -extent 480x270 -strip "$thumb" 2>/dev/null
        printf "%s\x00icon\x1f%s\n" "$pic_name" "$thumb"
    done
}

choice=$(menu | rofi -i -dmenu \
    -config "$ROFI_THEME" \
    -theme-str "$rofi_override" \
    -p "󰸉 Wallpaper")

[ -z "$choice" ] && exit 0

choice_base="${choice%.*}"
selected=$(find "$WALL_DIR" -iname "$choice_base.*" -print -quit)
[ -z "$selected" ] || [ ! -f "$selected" ] && exit 1

pgrep -x swww-daemon >/dev/null || { swww-daemon & sleep 0.5; }
swww img -o "$focused_monitor" "$selected" $SWWW_PARAMS

bash "$SCRIPTSDIR/wallpaper.sh" "$selected"
