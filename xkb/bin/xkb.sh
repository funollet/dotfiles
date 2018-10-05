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
# Not reaaly needed: xmodmap can do 'keycode any' on its own.

####


# Delete previous options.
setxkbmap -layout us -option ''

# Set keyboard layout.
setxkbmap -layout us -variant intl \
    -option 'ctrl:nocaps' \
    -option 'terminate:ctrl_alt_bksp'

# Extend us(intl).
# dead_acute is lvl3, single quote is just one keypress.
# Also, can use AltGr+a to get á, etc.
xmodmap -e "keycode 48 = apostrophe quotedbl apostrophe quotedbl dead_acute dead_diaeresis dead_acute dead_diaeresis"
# lvl3 c is ccedila
xmodmap -e "keycode 54 = c C c C ccedilla Ccedilla ccedilla Ccedilla"
# lvl4 l is periodcentered
xmodmap -e "keycode 46 = l L l L periodcentered periodcentered periodcentered periodcentered"


# key repeat: <delay>ms <rate>Hz
xset r rate 300 50


# Stop running instances of xcape.
pkill xcape

# Space becomes Control
xmodmap -e "remove mod4 = Hyper_L"
xmodmap -e "keycode 65  = Hyper_L"      # keycode <SPC> (65)
xmodmap -e "add Control = Hyper_L"      # add keysym F20 to Control modifier map
xmodmap -e "keycode any = space"

# 'f' becomes Super
xmodmap -e "remove mod4 = Super_R"
xmodmap -e "keycode 41  = Super_R"      # keycode <f> (41)
xmodmap -e "add mod4    = Super_R"
xmodmap -e "keycode any = f"

# Space still works as space, 'f' still works as 'f'.
xcape -t 400 -e "Hyper_L=space;Super_R=f"


## Using f/j as Control keys, too.
## Good: stay on the home row.
## Bad: typing fast it's easy to type (say) f and type the next character
##      before letting go f, which launches a 'chord' (ctrl+...)
##
# xmodmap -e 'keycode 41  = Control_L'      # f
# xmodmap -e 'keycode 44  = Control_R'      # j
# xmodmap -e 'add Control = Control_L'
# xmodmap -e 'add Control = Control_R'
# xmodmap -e 'keycode any = f'
# xmodmap -e 'keycode any = j'
# 
# xcape -t 300 -e 'Control_L=f;Control_R=j'
