#!/usr/bin/env bash
# firefox-detach-window.sh
#
# Move a Firefox tab to its own window and send it to another screen.


# go to url 
# shift+tab backwards to the tab
# use the contextual menu to detach the tab
xdotool sleep 0.5 key --delay 300 \
  ctrl+l \
  shift+Tab shift+Tab shift+Tab shift+Tab \
  shift+F10 v w

# set focus on the newest Firefox window
sleep 0.8
firefox_last_window=$(wmctrl -l | awk '/ — Mozilla Firefox$/ {print $1}' | sort -n | tail -1)
wmctrl -i -a "$firefox_last_window"

sleep .2
next=$(qtile cmd-obj -o screen -f info | tr \' \" | jq '(.index+1)%2')
qtile cmd-obj -o window -f toscreen -a $next


# set focus on the newest Firefox window
#sleep .2
#wmctrl -i -a "$firefox_last_window"

