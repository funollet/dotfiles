#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

setxkbmap -layout "eu,es"
run nm-applet
run lxqt-powermanagement
run Telegram
run slack
# run xscreensaver
run keybase
