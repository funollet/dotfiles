#!/bin/bash
# display.sh

setup_displays () {
    if [ "$(hostname)" = "yak.lan" ] ; then
        if xrandr | grep -q 'HDMI-1 connected' ; then
            xrandr --output HDMI-1 --primary --auto \
                   --output eDP-1 --auto --left-of HDMI-1 --mode 1920x1080
        else
            xrandr --output HDMI-1 --off --output eDP-1 --primary --mode 1920x1080
        fi
    fi
}


setup_displays
