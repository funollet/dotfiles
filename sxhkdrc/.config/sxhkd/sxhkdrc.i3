F1
  ~/bin/mute-meet.sh

{F6,F7,F8,F9}
  i3-msg '[class="{discord,Telegram,Slack,Spotify}"] scratchpad show'
#   ~/bin/toggle-window.sh {telegram,discord,spotify}

super + p ; {k, space, super+p}
  playerctl -p spotify play-pause ; notify-send -t 3000 "Spotify: toggle-play"
super + p ; {j,l}
  playerctl -p spotify {previous,next}
super + p ; {Prior, Next}
  playerctl -p spotify {previous,next,play-pause,play-pause}
super + p ; p
  i3-msg '[class="Spotify"] scratchpad show'

{XF86AudioPlay,XF86AudioNext,XF86AudioPrev}
  playerctl -p spotify {play-pause,next,previous}

{XF86AudioRaiseVolume,XF86AudioLowerVolume}
  pactl set-sink-volume @DEFAULT_SINK@ {+,-}3%
super + {Prior,Next}
  pactl set-sink-volume @DEFAULT_SINK@ {+,-}3%
{super+m, XF86AudioMute}
  pactl set-sink-mute @DEFAULT_SINK@ toggle

# activate screensaver
ctrl + alt + l
  xset s activate

# F17 on ergodox
XF86Launch8
  ~/bin/firefox-detach-window.sh

# F16,F15 on ergodox
{XF86Launch7,XF86Launch6}
  ~/bin/copypaster {copy,paste}



# Brightness ; overwritten by another app
{XF86MonBrightnessDown,XF86MonBrightnessUp}
  light -{U,A} 15
# overwritten by another app
Print
  flameshot gui
# overwritten by another app
super + y
  dolphin

super + Return
  konsole
super + shift + a
  autorandr 2
super + r
  ulauncher-toggle
# # "rofi -theme applications -show-icons -drun-use-desktop-cache \
# # -sorting-method fzf -matching normal \
# # -show drun -modi 'drun,custom-menu:~/.config/rofi/scripts/rofi-custom-menu,run'"

# # https://github.com/jluttine/rofi-power-menu
super + Escape
    rofi -theme powermenu -show power-menu \
      -modi 'power-menu:~/.config/rofi/scripts/rofi-power-menu --confirm ""'





# change volume with mouse wheel
super + shift + {button4,button5}
  pactl set-sink-volume @DEFAULT_SINK@ {+,-}3%

# mouse wheel left/right button switch to prev/next desktop
# {button6,button7}
#   xdotool set_desktop --relative -- {-1,1}
{button8,button9}
  xdotool set_desktop --relative -- {-1,1}

# # Mouse 'forward' button.
# button8
#   xdotool key ctrl+r

# # Mouse 'back' button.
# button9
#   i3-msg move container to output right