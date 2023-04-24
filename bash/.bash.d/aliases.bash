#!/bin/bash

# Default invocations with extra parameters.
alias top='top -d1'
alias tree='tree -a -I ".git|__pycache__|.pytest_cache|.mypy_cache|*.swp|*.pyc|.venv"'
alias vim=vimx
alias nvim=lvim
alias watch='watch -n1 --no-title --color'
alias cal='cal -m'
alias ssh='TERM=xterm-256color ssh'
alias ssh-blindly='TERM=xterm-256color ssh -o StrictHostKeyChecking=no  -o CheckHostIP=no -o UserKnownHostsFile=/dev/null'
alias lg='lazygit'


psg () {        # bash-expansion: grep [p]attern
    ps auxw | grep \[${1:0:1}\]${1:1}
}
alias pe='perl -wln -e'
alias pep='perl -wlp -e'
alias trn="tr '\n' ' '"
alias dnf='sudo dnf'
# alias puppetlocalrun='sudo puppet apply -v --confdir ~/code/puppet-ws/ ~/code/puppet-ws/manifests/site.pp'
alias nocomments='egrep -ahv "^[[:space:]]*(#|$)"'

alias fuck='eval $(thefuck $(fc -ln -1))'

alias jless='bat -l json'
alias yless='bat -l yaml'


alias weight.edit='vim ~/workingon/pim/weight.dat'
weight () {
    echo "$(date -I)  $1" >> ~/workingon/pim/weight.dat
}

fullname () { echo $(pwd)/${1} ; }

batt () {
    cd /sys/class/power_supply/BAT0/
    echo print $(cat energy_now) *100 / $(cat energy_full) , \"%  $(cat status)\" | bc ; echo
    cd $OLDPWD
}

mark () { grep -E "$1|.*" ; }

diffssh () {    #diffssh hostA hostB file
    colordiff -U0 <(ssh $1 cat $3) <(ssh $2 cat $3)
}

copier-chooser () {
    copier ~/code/skeletons/$(ls -1 ~/code/skeletons/ | fzf )
}

i3keys () {
    grep -E -R ^bind ~/.config/i3/ | cut -d ' ' -f 2- | sed 's/ /\t/' | column -ts $'\t' | pr -2 -w 145 -t
}
