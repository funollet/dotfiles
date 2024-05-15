#!/bin/bash
# i3-move-to-ws-or-create.sh
#
# Move container to the next/previous workspace. Create a new one if it doesn't exist.
# Lower limit: workspace 1.

ws=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).num')

case $1 in
  prev) num=$(( ws - 1 )) ;;
  next) num=$(( ws + 1 )) ;;
  *) exit ;;
esac

# Don't go to workspaces below 1
if [[ $num -eq 0 ]] ; then
  exit
fi

i3-msg move container to workspace $num 
i3-msg workspace $num
