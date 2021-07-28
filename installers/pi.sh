#!/bin/bash

set -eu

usage() {
    cat <<.
Usage: $(basename "$0") <command>

Commands:
    help:   Shows this message.
    update: Update dotfiles.
.
}


install() {
    sudo apt install mopidy-mpd
    sudo apt install python3-tunigo
    sudo python3 -m pip install Mopidy-Iris
    sudo systemctl enable mopidy.service
}


if [ $# = 0 ] ; then usage && exit 1 ; fi
case $1 in
    help)   usage ; exit 0 ;;
    install) install ; exit 0 ;;
    *)      echo "Invalid command" ; exit 1 ;;
esac

