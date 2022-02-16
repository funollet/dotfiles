#!/bin/bash
# bootstrap.sh


set -eu

sudo dnf install -y git curl just

# install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0
. $HOME/.asdf/asdf.sh

# make global versions available
ln -s ~/.dotfiles/asdf/.tool-versions ~/.tool-versions

asdf plugin-add python
sudo dnf install make gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel
# ensure a clean PATH, linuxbrew shadows system-wide libraries
PATH=~/.asdf/shims:~/.asdf/bin:/usr/sbin:/usr/bin:/sbin:/bin asdf install python

pip install ansible==5.2.0
asdf reshim python 3.9.10
ansible-galaxy collection install community.general

# asdf plugin add pipx https://github.com/amrox/asdf-pyapp.git
# asdf install pipx
#
# pipx install --include-deps ansible==5.2.0
# ansible-galaxy collection install community.general
# Should I inject boto?

# Alternative, not yet working:

#   asdf plugin add ansible https://github.com/amrox/asdf-pyapp.git
#   asdf install ansible latest:5.
#
# - bins are installed on the venv but not exposed as shims
# - how do I inject required libraries? (boto,...)
