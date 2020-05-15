#!/bin/bash -e

# linuxbrew dependencies
sudo yum groupinstall 'Development Tools'
sudo yum install curl file git
sudo yum install libxcrypt-compat # needed by Fedora 30 and up

# Linuxbrew
if ! command -v brew > /dev/null ; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# go-task
if ! command -v task > /dev/null ; then
  brew install go-task/tap/go-task
fi
