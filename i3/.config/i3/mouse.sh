#!/bin/bash
# mouse.sh

device_detected=false

lsusb | grep -qi 'elecom trackball' && device_detected=true

if [ "$device_detected" = "true" ] ; then
    pgrep xbindkeys || xbindkeys
else
    pkill xbindkeys
fi
