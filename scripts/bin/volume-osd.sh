#!/bin/bash

# Load docopts
source docopts.sh

# Define usage for docopts
doc="Usage: volume_osd.sh [options] (up|down|mute)

Options:
  --step=<step>         Volume change step [default: 1]
  --timeout=<timeout>   Notification timeout in seconds [default: 1]
"

# Parse arguments using docopts
eval "$(docopts -A args -h "$doc" : "$@")"

STEP=${args[--step]}
TIMEOUT=${args[--timeout]}

# Get the current volume
function get_volume {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+%' | head -1 | tr -d '%'
}

# Get the mute status
function get_mute_status {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes" && echo "muted" || echo "unmuted"
}

# Set the volume
function set_volume {
    pactl set-sink-volume @DEFAULT_SINK@ "$1%"
}

# Show the OSD with notify-send
function show_osd {
    local volume=$1
    local mute_status=$(get_mute_status)
    local icon

    if [ "$mute_status" == "muted" ]; then
        icon="audio-volume-muted"
    else
        icon="audio-volume-medium"
    fi

    notify-send --app-name volume-osd --replace-id 2593 --urgency low --transient \
      --expire-time $((TIMEOUT * 1000)) \
      --icon $icon \
      --hint int:value:$volume \
      " "
}

# Show the mute OSD with notify-send
function show_mute_osd {
    icon="audio-volume-muted"
    notify-send --app-name volume-osd --replace-id 2593 --urgency low --transient \
      --expire-time $((TIMEOUT * 1000)) \
      --icon $icon \
      " "
}

# Main function to change the volume and show OSD
function change_volume {
    local change=$1
    local current_volume=$(get_volume)
    local new_volume=$((current_volume + change))

    if [ $new_volume -lt 0 ]; then
        new_volume=0
    elif [ $new_volume -gt 100 ]; then
        new_volume=100
    fi

    set_volume $new_volume
    show_osd $new_volume
}

# Check the first argument
if [ "${args[up]}" == "true" ]; then
    change_volume $STEP
elif [ "${args[down]}" == "true" ]; then
    change_volume -$STEP
elif [ "${args[mute]}" == "true" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    if pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes"; then
        show_mute_osd
    else
        show_osd $(get_volume)
    fi
else
    echo "$doc"
    exit 1
fi
