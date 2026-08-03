#!/bin/bash
# ~/.config/qtile/autostart.sh

set -x

# Bring up the graphical session so systemd --user services that require it can
# start. In particular xdg-desktop-portal.service has
# "Requisite=graphical-session.target"; without this, flatpaks (e.g. Slack) fail
# to open links because the portal never starts.
dbus-update-activation-environment --systemd --all

# Tear down whatever a previous X session left behind. The user manager
# outlives the X session whenever a second login keeps it alive (a tty, ssh),
# and then every target below is still active from last time: "start" becomes a
# no-op, nothing is re-pulled, and the session comes up empty even though the
# processes died with the old X server. Stopping graphical-session.target takes
# the app-*@autostart.service units (PartOf=) and qtile-session.target
# (BindsTo=) down with it. A no-op on a freshly started user manager.
systemctl --user stop graphical-session.target

# Pick up any unit or autostart entry stowed since the user manager started,
# so the generator sees it before qtile-session.target pulls it in.
systemctl --user daemon-reload

# Starts the whole session: graphical-session-pre, graphical-session, and the
# XDG autostart entries, which systemd-xdg-autostart-generator has turned into
# app-*@autostart.service units. Each of those targets refuses a manual start,
# so they are all wanted by qtile-session.target rather than started here.
systemctl --user start qtile-session.target

# lock screen after [TIMEOUT] seconds, dim during [CYCLE] seconds
xset s 1800 15 \
  && xss-lock -n /usr/libexec/xsecurelock/dimmer -l -- xsecurelock &
