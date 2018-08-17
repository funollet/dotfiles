#!/bin/bash

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
  
    git branch -a --color=always | grep -v '/HEAD\s' | sort |
    fzf --height 50% "$@" --border --ansi --multi --tac --preview-window right:70% \
        --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
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

