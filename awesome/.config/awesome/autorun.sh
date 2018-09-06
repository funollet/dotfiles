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

setxkbmap -layout "eu,es"

if ! pgrep xautolock ; then
    xautolock -time ${LOCK_SCREEN_MINS} -locker 'i3lock -c 000000' &
fi

run nm-applet
run lxqt-powermanagement
run Telegram
run firefox
dropbox running && dropbox start
