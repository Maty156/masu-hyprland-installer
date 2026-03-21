#!/bin/bash
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')
echo $volume > /tmp/wobpipe
