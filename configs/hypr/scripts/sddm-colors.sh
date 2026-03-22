#!/bin/bash
THEME="/usr/share/sddm/themes/catppuccin/theme.conf"
COLORS="$HOME/.cache/wal/colors"
[ -f "$COLORS" ] || exit 1
color4=$(sed -n '5p' "$COLORS")
color6=$(sed -n '7p' "$COLORS")
sudo sed -i "s|TimeColor=.*|TimeColor=\"$color4\"|" "$THEME"
sudo sed -i "s|DateColor=.*|DateColor=\"$color6\"|" "$THEME"
sudo sed -i "s|LoginButtonBgColor=.*|LoginButtonBgColor=\"$color4\"|" "$THEME"
sudo sed -i "s|UserPictureBorderColor=.*|UserPictureBorderColor=\"$color4\"|" "$THEME"
sudo sed -i "s|TextFieldHighlightColor=.*|TextFieldHighlightColor=\"$color4\"|" "$THEME"
sudo sed -i "s|PopupHighlightColor=.*|PopupHighlightColor=\"$color4\"|" "$THEME"
sudo sed -i "s|SessionButtonColor=.*|SessionButtonColor=\"$color4\"|" "$THEME"
sudo sed -i "s|PowerButtonColor=.*|PowerButtonColor=\"$color4\"|" "$THEME"
echo "SDDM colors updated!"
