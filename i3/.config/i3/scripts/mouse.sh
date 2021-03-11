#!/bin/bash
# mouse.sh

# Custom configuration for this device.
# Bus 001 Device 002: ID 056e:00fd Elecom Co., Ltd ELECOM TrackBall Mouse

suffix=""
lsusb -d 056e:00fd > /dev/null && suffix=".elecom"

pkill xbindkeys
xbindkeys -f "$HOME/.xbindkeysrc${suffix}"

