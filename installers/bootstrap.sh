#!/bin/bash
# bootstrap.sh


set -eu

sudo dnf install -y git curl just vim dnf-plugins-core vim-enhanced stow
sudo dnf remove -y nano

### Workaround for failing ansible role.
sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# install mise
sudo dnf config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo
sudo dnf install -y mise
eval "$(/usr/bin/mise activate bash)"

# make global versions available
cd .. ; stow mise ; cd $OLDPWD
cd ~ ; mise install bin ; cd $OLDPWD

sudo dnf install -y ansible

echo
echo "#################"
echo You may want to enable running some commands passwordless (visudo).

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
