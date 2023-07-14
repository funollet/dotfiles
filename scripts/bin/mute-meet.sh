#!/bin/bash
# mute-my-meet
#
# Sets focus on any window with an ongoing call, toggles the mic and gets the
# focus back to the previous window.

lockdir="/tmp/$(basename $0).lock"

mkdir "${lockdir}" || exit 1
trap "rmdir $lockdir" EXIT

get_active_call () {
  wmctrl -l | \
    grep -E ' Slack call with| Zoom Meeting$| Meet – | - Discord$' | \
    grep -Eio '(slack|zoom|meet)' | uniq | \
    tr '[:upper:]' '[:lower:]'
}

focus_and_toggle_audio () {
    # get focus on the meeting window
    wmctrl -a "$1"
    sleep .1
    # send hotkeys to toggle the mic
    xdotool key "$2"
    # get focus back to the original window
    xdotool windowactivate "$current"
}

current=$(xdotool getwindowfocus)

active_call=$(get_active_call)

case ${active_call} in
  slack)    focus_and_toggle_audio 'Slack call with' 'm' ;;
  zoom)     focus_and_toggle_audio 'Zoom Meeting' 'alt+a' ;;
  meet)     focus_and_toggle_audio 'Meet' 'ctrl+d' ;;
  discord)  focus_and_toggle_audio 'Discord' 'ctrl+shift+h' ;;
esac

sleep .5
