#!/bin/bash
# sddm-colors.sh — Updates SDDM theme colors from pywal

THEME="/usr/share/sddm/themes/catppuccin/theme.conf"
COLORS="$HOME/.cache/wal/colors"

[ -f "$COLORS" ] || exit 1

# Read pywal colors
color0=$(sed -n '1p' "$COLORS")  # background
color1=$(sed -n '2p' "$COLORS")  # dark accent
color2=$(sed -n '3p' "$COLORS")  # accent
color4=$(sed -n '5p' "$COLORS")  # main accent
color6=$(sed -n '7p' "$COLORS")  # light
color7=$(sed -n '8p' "$COLORS")  # foreground

sudo sed -i "s|TimeColor=.*|TimeColor=\"$color4\"|" "$THEME"
sudo sed -i "s|DateColor=.*|DateColor=\"$color6\"|" "$THEME"
sudo sed -i "s|LoginButtonBgColor=.*|LoginButtonBgColor=\"$color4\"|" "$THEME"
sudo sed -i "s|UserPictureBorderColor=.*|UserPictureBorderColor=\"$color4\"|" "$THEME"
sudo sed -i "s|TextFieldHighlightColor=.*|TextFieldHighlightColor=\"$color4\"|" "$THEME"
sudo sed -i "s|PopupHighlightColor=.*|PopupHighlightColor=\"$color4\"|" "$THEME"
sudo sed -i "s|SessionButtonColor=.*|SessionButtonColor=\"$color4\"|" "$THEME"
sudo sed -i "s|PowerButtonColor=.*|PowerButtonColor=\"$color4\"|" "$THEME"

echo "SDDM colors updated!"
