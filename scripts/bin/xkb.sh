#!/bin/bash
# xkb.sh


#### Misc notes

# keysym code: number of a given key, specified in X11/keysymdef.h
# keysym name: 

# X11/keysymdef.h: 
#       keysym code     keysym macro name / keysym name
#       0x0020          XK_space
# xkb/keycodes/xfree86
#       <SPCE> =  65;

# xev:
#     state 0x0, keycode 65 (keysym 0x20, space), same_screen YES,

# modifier maps
# Shift Lock Control Mod1 Mod2 Mod3 Mod4 Mod5

# Unused(?) modifier keys
# ISO_Prev_Group
# ISO_Next_Group
# Hyper_L

# find unused keycodes with xmodmap -pke
# On layout EU:
#   8 93 97 103 120 132 149
# Not realy needed: xmodmap can do 'keycode any' on its own.

####


# Delete previous options.
setxkbmap -layout us -option ''

# Set keyboard layout.
#   ctrl:nocaps           disable capslock key
#   shift:both_capslock   Both Shift together enable Caps Lock.
#       Doesn't work with ctrl:nocaps.
#   caps:escape_shifted_capslock
#       Make unmodified Caps Lock an additional Esc, but Shift + Caps Lock
#       behaves like regular Caps Lock
# setxkbmap -layout us -variant intl \
setxkbmap -layout us \
    -option 'compose:caps' \
    -option 'compose:ralt' \
    -option 'terminate:ctrl_alt_bksp' \
    -option 'ctrl:menu_rctrl'

# Initial setup from kmonad config. Just as reference.
# setxkbmap -layout us \
#     -option 'compose:ralt' \
#     -option 'compose:caps'")

### compose keys
# á     a '
# à     a `
# ü     " u
# €     e =         euro
# ·     . -         periodcentered
# ç     c ,         ccedilla
# ñ     n ~

# Extend us(intl).
# dead_acute is lvl3, single quote is just one keypress.
# Also, can use AltGr+a to get á, etc.
xmodmap -e "keycode 48 = apostrophe quotedbl apostrophe quotedbl dead_acute dead_diaeresis dead_acute dead_diaeresis"
# lvl3 c is ccedila
xmodmap -e "keycode 54 = c C c C ccedilla Ccedilla ccedilla Ccedilla"
# lvl4 l is periodcentered
xmodmap -e "keycode 46 = l L l L periodcentered periodcentered periodcentered periodcentered"


xset r rate 400 50                      # key repeat: <delay>ms <rate>Hz
xset b off                              # disable bell
