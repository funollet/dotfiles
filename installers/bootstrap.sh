#!/bin/bash
# bootstrap.sh

set -eu

sudo dnf install -y git curl just vim dnf-plugins-core vim-enhanced stow
sudo dnf remove -y nano

# install mise
sudo dnf config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo
sudo dnf install -y mise
eval "$(/usr/bin/mise activate bash)"

# make global versions available
cd ..
stow mise

# mise applies [bootstrap.files] after [bootstrap.packages], but the dnf
# repo files below must exist before any dnf: package that lives in them.
# Running the files step early keeps that order right.
mise bootstrap files apply --yes
mise install
cd $OLDPWD

echo
echo "#################"
echo You may want to enable running some commands passwordless \(visudo\).
