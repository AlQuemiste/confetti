#!/bin/bash

# <https://docs.slackware.com/howtos:window_managers:keyboard_layout_in_i3>
# shell scipt to prepend i3status with more stuff

i3status --config ~/.config/i3status/config | while :
do
    read line
    LG=$(setxkbmap -query | awk '/layout/{print $2}')
    echo "LG: $LG | $line" || exit 1
done
