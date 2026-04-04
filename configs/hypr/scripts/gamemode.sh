#!/usr/bin/env bash
# MASU Hyprland Gaming Mode Toggle
# Disables animations, blur, and shadows for maximum performance

HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')

if [ "$HYPRGAMEMODE" = 1 ] ; then
    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:blur:enabled 0;\
        keyword decoration:shadow:enabled 0"
    notify-send "MASU Gaming Mode" "Animations & Blur DISABLED (MAX FPS)" -i face-cool
else
    hyprctl --batch "\
        keyword animations:enabled 1;\
        keyword decoration:blur:enabled 1;\
        keyword decoration:shadow:enabled 1"
    notify-send "MASU Gaming Mode" "Animations & Blur ENABLED" -i face-smile
fi
