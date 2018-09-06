#!/usr/bin/env bash
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

run xautolock -time ${LOCK_SCREEN_MINS} -locker 'i3lock -c 000000'

run nm-applet
run lxqt-powermanagement
run Telegram
run firefox
run keybase
