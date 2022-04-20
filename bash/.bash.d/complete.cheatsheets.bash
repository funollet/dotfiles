#!/bin/bash

_fzf_complete_cheatsheets() {
  [ -n "${COMP_WORDS[COMP_CWORD]}" ] && return 1

  local selected fzf
  fzf="$(__fzfcmd_complete)"
  selected=$(command find "$HOME/workingon/cheatsheets" \
        -regextype posix-egrep \
        -regex '.*\.(rst|txt|md|mk|mkd|markdown)' \
    | while read -r f ; do \
        printf "%-25s %s\n" $(basename $f) $f ; \
    done \
    | $fzf --with-nth 1 | awk '{print $2}')

  printf '\e[5n'

  if [ -n "$selected" ]; then
    COMPREPLY=( "$selected" )
    return 0
  fi
}

[ -n "$BASH" ] && complete -F _fzf_complete_cheatsheets -o default -o bashdefault cheatsheets
