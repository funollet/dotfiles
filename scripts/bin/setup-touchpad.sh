#!/bin/bash
# setup-touchpad.sh

devs=$(xinput list | grep -Ei 'magic trackpad|touchpad' | sed 's/.*id=//' | awk '{print $1}')

for dev in ${devs} ; do
  xinput set-prop "${dev}" "libinput Tapping Enabled" 1
  xinput set-prop "${dev}" "libinput Natural Scrolling Enabled" 0
  xinput set-button-map "${dev}" 1 3 2 4 5 6 7
done

systemctl --user restart fusuma
