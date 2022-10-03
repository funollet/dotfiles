#!/bin/sh
# inputplug-handler.sh
#
# Event handler for https://github.com/andrewshadura/inputplug

event="$1"
dev_id="$2"
dev_type="$3"
dev_name="$4"

case $event in
    XIDeviceEnabled)
        case "$dev_type,$dev_name" in
            XISlavePointer,"ELECOM ELECOM TrackBall Mouse")
                pkill xbindkeys
                xbindkeys -f "$HOME/.xbindkeysrc.elecom"
                ;;
        esac
        ;;
    XIDeviceDisabled)
        case "$dev_type,$dev_id" in
            XISlavePointer,10)
                pkill xbindkeys
                xbindkeys
                ;;
        esac
        ;;
esac

