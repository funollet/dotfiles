#!/bin/bash
# display.sh

if [ -f "display.$(hostname).sh" ] ; then
    "./display.$(hostname).sh"
else
    "./display.default.sh"
fi
