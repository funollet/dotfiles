#!/bin/bash -x
# awesome/autorun.sh

# Lock screen after (in minutes).
LOCK_SCREEN_MINS=5

~/bin/xkb.sh

if ! pgrep xautolock ; then
    xautolock -time ${LOCK_SCREEN_MINS} -locker 'i3lock -c 000000' &
fi

pgrep nm-applet || nm-applet &
pgrep lxqt-powermanagement || lxqt-powermanagement &
pgrep Telegram || Telegram &
pgrep firefox || firefox &
dropbox running && dropbox start
