#!/bin/bash
# mute-my-meet
#
# Sets focus on any window with an ongoing call, toggles the mic and gets the
# focus back to the previous window.

lockdir="/tmp/$(basename $0).lock"

mkdir "${lockdir}" || exit 1
trap "rmdir $lockdir" EXIT

get_active_call() {
  xdotool search --name \
    'Slack call with|Zoom Meeting$|^Meet - | - Discord$' getwindowname %@ |
    grep -Eio '(slack|zoom|meet|discord)' | uniq |
    tr '[:upper:]' '[:lower:]'
}

focus_and_toggle_audio() {
  local current
  current=$(xdotool getwindowfocus)

  xdotool \
    search --name "$1" \
    windowfocus key "$2" \
    windowfocus ${current}

  notify-send --urgency low --transient \
    --expire-time 1000 \
    --icon "microphone-sensitivity-muted" \
    "$3 muted/unmuted"
}

active_call=$(get_active_call)

case ${active_call} in
slack) focus_and_toggle_audio 'Slack call with' 'm' "${active_call}" ;;
zoom) focus_and_toggle_audio 'Zoom Meeting' 'alt+a' "${active_call}" ;;
meet) focus_and_toggle_audio 'Meet -' 'ctrl+d' "${active_call}" ;;
discord) focus_and_toggle_audio 'Discord' 'ctrl+shift+h' "${active_call}" ;;
esac

sleep .5
