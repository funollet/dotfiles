#!/bin/bash
# ~/.config/qtile/autostart.sh

set -x

autorandr --change &
xset s 1800 10 && xss-lock -n /usr/libexec/xsecurelock/dimmer -l -- xsecurelock &
dex-autostart --autostart --environment qtile --search-paths ~/.config/autostart/ &
