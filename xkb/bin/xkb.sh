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
    -option 'terminate:ctrl_alt_bksp' \
    -option 'ctrl:menu_rctrl'

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


# key repeat: <delay>ms <rate>Hz
xset r rate 300 50


# Stop running instances of xcape.
pkill xcape

# 'Space' becomes Super
xmodmap -e "remove mod4 = Super_R"
xmodmap -e "keycode 65  = Super_R"      # keycode <SPC> (65)
xmodmap -e "add mod4    = Super_R"
xmodmap -e "keycode any = space"

# Space still works as space.
# space cadet shift: shift as (), ctrl as {}
# xcape -t 200 -e "Super_R=space;Shift_L=parenleft;Shift_R=parenright;Control_L=Shift_L|bracketleft;Control_R=Shift_L|bracketright"
xcape -t 200 -e "Super_R=space;Shift_L=parenleft;Shift_R=parenright;Control_L=Tab;Control_R=Return"



# # Space becomes Control
# xmodmap -e "remove mod4 = Hyper_L"
# xmodmap -e "keycode 65  = Hyper_L"      # keycode <SPC> (65)
# xmodmap -e "add Control = Hyper_L"      # add keysym F20 to Control modifier map
# xmodmap -e "keycode any = space"
# # 'Tab' becomes Super
# xmodmap -e "remove mod4 = Super_R"
# xmodmap -e "keycode 23  = Super_R"      # keycode <Tab> (23)
# xmodmap -e "add mod4    = Super_R"
# xmodmap -e "keycode any = Tab"
# 
# # Space still works as space.
# xcape -t 200 -e "Hyper_L=space;Super_R=Tab"


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


## Using v/n as Super.
## Close alternative to f/j, not so prone to accidentally overlap with typing the next key.

## Space becomes Control
#xmodmap -e "remove mod4 = Hyper_L"
#xmodmap -e "keycode 65  = Hyper_L"      # keycode <SPC> (65)
#xmodmap -e "add Control = Hyper_L"      # add keysym F20 to Control modifier map
#xmodmap -e "keycode any = space"
#
## 'v' becomes Super
#xmodmap -e "remove mod4 = Super_L"
#xmodmap -e "keycode 55  = Super_L"      # keycode <v> (55)
#xmodmap -e "add mod4    = Super_L"
#xmodmap -e "keycode any = v"
#
## 'n' becomes Super
#xmodmap -e "remove mod4 = Super_R"
#xmodmap -e "keycode 57  = Super_R"      # keycode <n> (57)
#xmodmap -e "add mod4    = Super_R"
#xmodmap -e "keycode any = n"
#
## Space still works as space, 'v' still works as 'v'.
#xcape -t 200 -e "Hyper_L=space;Super_L=v;Super_R=n"
