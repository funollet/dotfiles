#!/bin/bash
# ~/.config/qtile/autostart.sh

set -x

# Bring up the graphical session so systemd --user services that require it can
# start. In particular xdg-desktop-portal.service has
# "Requisite=graphical-session.target"; without this, flatpaks (e.g. Slack) fail
# to open links because the portal never starts.
dbus-update-activation-environment --systemd --all
systemctl --user start qtile-session.target

# Run the XDG autostart entries. systemd-xdg-autostart-generator turns
# ~/.config/autostart and /etc/xdg/autostart into app-*@autostart.service units,
# so every entry gets "systemctl --user status" and its own journal instead of
# disappearing into this script's stdout. Replaces dex-autostart, which only
# read ~/.config/autostart and ignored X-systemd-skip.
# The reload picks up entries stowed since the user manager started.
systemctl --user daemon-reload
systemctl --user start xdg-desktop-autostart.target

# lock screen after [TIMEOUT] seconds, dim during [CYCLE] seconds
xset s 1800 15 \
  && xss-lock -n /usr/libexec/xsecurelock/dimmer -l -- xsecurelock &
