#!/bin/bash
# ~/.config/qtile/autostart.sh

set -x

# Bring up the graphical session so systemd --user services that require it can
# start. In particular xdg-desktop-portal.service has
# "Requisite=graphical-session.target"; without this, flatpaks (e.g. Slack) fail
# to open links because the portal never starts.
dbus-update-activation-environment --systemd --all
systemctl --user start qtile-session.target

# lock screen after [TIMEOUT] seconds, dim during [CYCLE] seconds
xset s 1800 15 \
  && xss-lock -n /usr/libexec/xsecurelock/dimmer -l -- xsecurelock &
systemctl --user start ulauncher.service &
dex-autostart --autostart --environment qtile --search-paths ~/.config/autostart/ &
