# Point SSH_AUTH_SOCK at the socket-activated ssh-agent.socket user unit.
#
# Managed by ansible (dotfiles: installers/roles/ssh-agent). Do not edit here.
#
# Why this exists:
#   xinitrc-common (pkg xorg-x11-xinit) prefixes the whole X session with a
#   throwaway `ssh-agent` UNLESS SSH_AUTH_SOCK is already set. That per-session
#   agent is only visible to processes qtile launches directly, so the ghostty
#   systemd --user service (and the terminals it spawns) can't reach it.
#
#   xinitrc-common sources every /etc/X11/xinit/xinitrc.d/* file *before* that
#   guard runs, so exporting SSH_AUTH_SOCK here both (a) suppresses the
#   throwaway agent and (b) makes the entire session use the socket-activated
#   ssh-agent.socket unit — the same agent that systemd --user services see.
#
#   The matching SSH_AUTH_SOCK for systemd --user lives in
#   qtile/.config/environment.d/90-qtile.conf.

export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
