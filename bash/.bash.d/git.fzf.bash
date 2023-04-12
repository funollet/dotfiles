#!/bin/bash

bind '"\er": redraw-current-line'
bind '"\C-g\C-f": "$(gf)\e\C-e\er"'
bind '"\C-g\C-b": "$(gb)\e\C-e\er"'
bind '"\C-g\C-v": "$(fshow)\e\C-e\er"'

alias gitc='git checkout $(gb)'

gco() {
    # are we in a in git repo?
    git rev-parse HEAD > /dev/null 2>&1 || return

    git commit $(
        git -c color.status=always status --short |
        fzf --height 50% "$@" --border -m --ansi --nth 2..,.. \
            --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
        cut -c4- | sed 's/.* -> //' \
    )
  
}

# Git: get branch
gb() {
    # are we in a git repo?
    git rev-parse HEAD > /dev/null 2>&1 || return
  
    git branch --color=always | grep -v '/HEAD\s' | sort |
    fzf --height 50% "$@" --border --ansi --multi --tac --preview-window right:70% | \
        #--preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
    sed 's/^..//' | cut -d' ' -f1 |
    sed 's#^remotes/##'
}

gf() {
    # are we in a git repo?
    git rev-parse HEAD > /dev/null 2>&1 || return

    git -c color.status=always status --short |
    fzf --height 50% "$@" --border -m --ansi --nth 2..,.. \
        --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
    cut -c4- | sed 's/.* -> //'
}


# fshow - get commit id
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index \
      --preview 'git show --color=always {2} | head -500' \
    | grep -o '[a-f0-9]\{7\}' | head -1
}
