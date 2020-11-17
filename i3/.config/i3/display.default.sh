#!/bin/bash
# display.sh


# modes suitable for eDP-1
# 2560x1440 2048x1152 1920x1080 1600x900 1440x810 1280x720

mode_laptop='1600x900'
# mode_lg='1920x1080'

setup_displays () {
    if [ "$(hostname)" = "yak.lan" ] ; then
        if xrandr | grep -q 'HDMI-1 connected' ; then
            xrandr --output HDMI-1 --primary --auto \
                   --output eDP-1 --right-of HDMI-1 --mode $mode_laptop
        else
            xrandr --output HDMI-1 --off --output eDP-1 --primary --mode $mode_laptop
        fi
    fi
}


xrandr --output HDMI-2 --off
setup_displays
