#!/bin/bash
# bootstrap.sh

set -eu

sudo dnf install -y git curl just vim dnf-plugins-core vim-enhanced stow ansible
sudo dnf remove -y nano

# install mise
sudo dnf config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo
sudo dnf install -y mise
eval "$(/usr/bin/mise activate bash)"

# make global versions available
cd ..
stow mise
mise install
cd $OLDPWD

echo
echo "#################"
echo You may want to enable running some commands passwordless \(visudo\).
