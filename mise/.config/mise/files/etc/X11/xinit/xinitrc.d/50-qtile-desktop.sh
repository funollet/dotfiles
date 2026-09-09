# Give the qtile session a desktop identity.
#
# Managed by mise bootstrap (.config/mise/files). Do not edit here.
#
# Why this exists:
#   /usr/share/xsessions/qtile.desktop carries no DesktopNames= key (compare
#   plasmax11.desktop, which has DesktopNames=KDE), so the display manager
#   never exports XDG_CURRENT_DESKTOP. Everything qtile spawns from a
#   keybinding then runs with no desktop identity at all, which is the sort of
#   gap that "Exec=env XDG_CURRENT_DESKTOP=Unity dropbox start -i" works
#   around one app at a time.
#
#   xinitrc-common (pkg xorg-x11-xinit) sources every
#   /etc/X11/xinit/xinitrc.d/* file before the session command is exec'd, so
#   exporting here reaches qtile itself and every child it spawns.
#   autostart.sh then pushes the value on to systemd --user with
#   dbus-update-activation-environment.
#
#   The systemd --user half lives in qtile/.config/environment.d/90-qtile.conf,
#   which is read before the X session exists and so cannot learn this from
#   the session.
#
# Keep the value lowercase "qtile". It is compared literally against the
# OnlyShowIn and NotShowIn keys of the autostart entries, and against the
# ExecCondition that systemd-xdg-autostart-generator emits for each of them.

if [ "$DESKTOP_SESSION" = "qtile" ]; then
  export XDG_CURRENT_DESKTOP=qtile
  export XDG_SESSION_DESKTOP=qtile
fi
