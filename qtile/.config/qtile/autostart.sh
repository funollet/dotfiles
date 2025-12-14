#!/bin/bash
# ~/.config/qtile/autostart.sh

set -x

# lock screen after [TIMEOUT] seconds, dim during [CYCLE] seconds
xset s 1800 15 \
  && xss-lock -n /usr/libexec/xsecurelock/dimmer -l -- xsecurelock &
systemctl --user start ulauncher.service &
dex-autostart --autostart --environment qtile --search-paths ~/.config/autostart/ &
