#!/bin/bash

columnize() {
  tr -s ' ' | column -t -s:
}

(
  upower -i "$(upower -e | grep BAT)" | grep -E 'state|to full|percentage' \
    | sed 's/^[ \t]*//g'
  echo -n "🔌 "
  upower -i "$(upower -e | grep AC)" | grep 'online' \
    | sed 's/^[ \t]*//g;s/online/AC online/'
  tuned-adm active
) | sed 's/Current //' | columnize
