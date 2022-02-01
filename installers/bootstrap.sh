#!/bin/bash
# bootstrap.sh


set -eu

sudo dnf install -y git curl just

# install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0
. $HOME/.asdf/asdf.sh

# make global versions available
ln -s ~/.tool-versions .dotfiles/asdf/.tool-versions

asdf plugin-add python
# ensure a clean PATH, linuxbrew shadows system-wide libraries
PATH=~/.asdf/shims:~/.asdf/bin:/usr/sbin:/usr/bin:/sbin:/bin asdf install python

asdf plugin add pipx https://github.com/amrox/asdf-pyapp.git
asdf install pipx

pipx install --include-deps ansible==5.2.0
ansible-galaxy collection install community.general
# inject boto?

# Alternative, not yet working:
#   asdf plugin add ansible https://github.com/amrox/asdf-pyapp.git
#   asdf install ansible latest:5.
#
# Must find a way to pass --include-deps

