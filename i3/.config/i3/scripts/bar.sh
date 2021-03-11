#!/bin/bash
# bar.sh

run_polybar () {
    killall -q polybar
    # Wait until the processes have been shut down
    while pgrep -u $UID -x polybar > /dev/null; do sleep 0.3 ; done

    devices=$(xrandr | awk '/ conn/ {print $1}')
    primary=$(xrandr | grep primary | awk '/ conn/ {print $1}')

    for dev in $devices ; do
        echo "---" | tee -a /tmp/polybar.$dev.log
        position=none
        if [ $dev == $primary ] ; then
            position=center
        fi
        TRAY_POSITION=$position MONITOR=$dev polybar base >> /tmp/polybar.$dev.log 2>&1 &
    done
}

run_polybar

# (
    # flock 200
# )200>/tmp/display.sh.lock
