#!/bin/bash

# Default invocations with extra parameters.
alias top='top -d1'
alias ls='lsd'
alias tree='lsd --tree --icon=always -I "{*.terraform,.*_cache,__pycache__,.git,.venv}"'
alias vim=vimx
alias watch='watch -n1 --no-title --color'
alias cal='cal -m'
alias ssh='TERM=xterm-256color ssh'
alias ssh-blindly='TERM=xterm-256color ssh -o StrictHostKeyChecking=no  -o CheckHostIP=no -o UserKnownHostsFile=/dev/null'
alias lg='lazygit'
alias lzd='lazydocker'
alias bring-back-window='wmctrl -l | fzf | cut -d\  -f1 | xargs wmctrl -iR'
alias serie='serie --protocol kitty'
# go to git root folder 'zr' stands for z-root because zoxide doesn't do it
alias zr='cd $(git rev-parse --show-toplevel)'

psg() { # bash-expansion: grep [p]attern
  ps auxw | grep \[${1:0:1}\]${1:1}
}
alias pe='perl -wln -e'
alias pep='perl -wlp -e'
alias trn="tr '\n' ' '"
alias dnf='sudo dnf'
alias nocomments='egrep -ahv "^[[:space:]]*(#|$)"'

alias fuck='eval $(thefuck $(fc -ln -1))'

alias lessj='bat -l json'
alias lessy='bat -l yaml'
alias xclip='xclip -selection clipboard'

alias weight.edit='vim ~/workingon/pim/weight.dat'
weight() {
  echo "$(date -I)  $1" >>~/workingon/pim/weight.dat
}

fullname() { echo $(pwd)/${1}; }

batt() {
  cd /sys/class/power_supply/BAT0/
  echo print $(cat energy_now) *100 / $(cat energy_full) , \"% $(cat status)\" | bc
  echo
  cd $OLDPWD
}

mark() { grep -E "$1|.*"; }

diffssh() { #diffssh hostA hostB file
  colordiff -U0 <(ssh $1 cat $3) <(ssh $2 cat $3)
}

copier-chooser() {
  copier copy "$HOME/code/skeletons/$(ls -1 $HOME/code/skeletons/ | ag -v cookiecutter | fzf)" .
}

edit() {
  # fuzzy-search and edit files in current dir
  fd -tf | fzf --multi | xargs --no-run-if-empty $EDITOR
}

edithidden() {
  # fuzzy-search and edit files in current dir; hidden files too
  fd -tf --hidden --exclude .git | fzf --multi | xargs --no-run-if-empty $EDITOR
}

alias t='todo.sh'
alias ta='todo.sh add +inbox'
alias te='todo.sh edit'
alias tn='todo.sh ls @next'
