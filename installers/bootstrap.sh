#!/bin/bash
# bootstrap.sh


set -eu

sudo dnf install -y git curl just vim dnf-plugins-core
sudo dnf remove -y nano

### Workaround for failing ansible role.
sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# install rtx
sudo dnf config-manager --add-repo https://rtx.pub/rpm/rtx.repo
sudo dnf install -y rtx
export RTX_FETCH_REMOTE_VERSIONS_TIMEOUT=30s
eval "$(/usr/bin/rtx activate bash)"

# make global versions available
mkdir -p ~/.config/rtx/
ln -s ~/.dotfiles/rtx/.tool-versions ~/.tool-versions
ln -s ~/.dotfiles/rtx/config.toml ~/.config.toml

cd ~ ; rtx install bin ; cd $OLDPWD

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
