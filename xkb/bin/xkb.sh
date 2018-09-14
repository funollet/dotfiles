#!/bin/bash -x
# awesome/xkb.sh


# Delete previous options.
setxkbmap -layout eu -option ''
# Set keyboard layout EUrkey.
setxkbmap -layout eu -option 'ctrl:nocaps'
    # -option 'terminate:ctrl_alt_bksp'

# key repeat: <delay>ms <rate>Hz
xset r rate 300 50
