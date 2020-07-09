#!/bin/bash
# bar.sh

run_polybar () {
    killall -q polybar
    # Wait until the processes have been shut down
    while pgrep -u $UID -x polybar > /dev/null; do sleep 0.3 ; done

    devices=$(polybar --list-monitors | cut -d: -f1)
    primary=$(polybar --list-monitors | grep primary | cut -d: -f1)

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
