#!/bin/bash
# bootstrap.sh

set -eu

# Passwordless sudo for wheel first: mise bootstrap and task dnf run many sudo
# commands and must not stop for a password on each one. The only prompt of
# this script is the one below. Drop-ins are read after the wheel rule in
# /etc/sudoers, so this one wins whatever Fedora ships there. visudo validates
# the rule before it lands.
sudoers_tmp="$(mktemp)"
printf '%%wheel ALL=(ALL) NOPASSWD: ALL\n' > "$sudoers_tmp"
sudo visudo -cf "$sudoers_tmp"
sudo install -m 0440 -o root -g root "$sudoers_tmp" /etc/sudoers.d/wheel
rm "$sudoers_tmp"

sudo dnf install -y git curl dnf-plugins-core neovim vim vim-enhanced stow
sudo dnf remove -y nano

# install mise
sudo dnf config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo
sudo dnf install -y mise
eval "$(/usr/bin/mise activate bash)"

# make global versions available
cd ..
stow mise

mise install
# mise applies [bootstrap.files] after [bootstrap.packages], but the dnf
# repo files below must exist before any dnf: package that lives in them.
# Running the files step early keeps that order right.
mise bootstrap files apply --yes
mise bootstrap --yes
task dnf
cd $OLDPWD
