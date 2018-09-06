#!/usr/bin/bash -x
# awesome/autorun.sh

# Lock screen after (in minutes).
LOCK_SCREEN_MINS=5

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

setxkbmap -layout eu -option ''
setxkbmap -layout eu -option 'caps:ctrl_modifier' -option 'terminate:ctrl_alt_bksp'

xset r rate 300 50      # key repeate rate: delay 300ms, 50Hz

if ! pgrep xautolock ; then
    xautolock -time ${LOCK_SCREEN_MINS} -locker 'i3lock -c 000000' &
fi

run nm-applet
run lxqt-powermanagement
run Telegram
run firefox
dropbox running && dropbox start
