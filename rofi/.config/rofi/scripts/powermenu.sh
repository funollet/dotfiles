#!/bin/bash

MESSAGE="Powermenu"
SUSPEND=""
POWER=""
RESTART=""
LOGOUT=""
LOCK=""
RES=`echo "$SUSPEND|$POWER|$RESTART|$LOGOUT|$LOCK" | rofi -dmenu -p "$MESSAGE" -sep "|" -theme powermenu -monitor -1`
[ "$RES" = "$SUSPEND" ] && systemctl suspend
[ "$RES" = "$POWER" ] && systemctl poweroff
[ "$RES" = "$RESTART" ] && systemctl reboot
[ "$RES" = "$LOGOUT" ] && loginctl terminate-session ${XDG_SESSION_ID-}
[ "$RES" = "$LOCK" ] && sleep .2 && xset l activate
