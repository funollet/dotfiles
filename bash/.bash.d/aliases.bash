#!/bin/bash


# fzf for changing to a chart's directory.
cdchart () {
    local dir dest

    # List dirs of charts. Show shortened name for searching in fzf.
    dest=$(
    # for dir in $(find "$HOME/code/onna/" -name Chart.yaml -print0 | xargs -0 -n1 dirname) ; do
    ls -d $HOME/code/onna/*/charts | xargs -n1 dirname | while read dir ; do \
        printf '%-25s %s\n' "$(basename $dir)" "$dir"
    done | \
        sort | fzf -n1 | awk '{print $2}'
    )
    cd "$dest"
}

#alias quicknotes='vim ~/.local/share/quicknotes/quick.md'

# Default invocations with extra parameters.
alias top='top -d1'
# alias kash='kash -p2'
alias tree='tree -C'
alias gvim='gvim --remote-tab'
alias watch='watch -n1 --no-title --color'


psg () {        # bash-expansion: grep [p]attern
    ps auxw | grep \[${1:0:1}\]${1:1}
}
alias pe='perl -wln -e'
alias pep='perl -wlp -e'
alias trn="tr '\n' ' '"
alias dnf='sudo dnf'
# alias puppetlocalrun='sudo puppet apply -v --confdir ~/code/puppet-ws/ ~/code/puppet-ws/manifests/site.pp'
alias nocomments='egrep -ahv "^[[:space:]]*(#|$)"'
#alias vimtask='vim ~/Dropbox/pim/sft.taskpaper'
alias sheetc='sheet copy'

alias fuck='eval $(thefuck $(fc -ln -1))'

alias greperb='ag -G erb$'

alias me='fab -f ~/bin/me.py'
jless () { jq -C '.' | less ; }


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

runonchange () {
    local cmd=( "$@" )
    while inotifywait --exclude '.*\.swp' -qqre close_write,move,create,delete "${1}" ; do
        "${cmd[@]:1}"
    done
}

mark () { grep -E "$1|.*" ; }

diffssh () {    #diffssh hostA hostB file
    colordiff -U0 <(ssh $1 cat $3) <(ssh $2 cat $3)
}

git-pull-dirs() {
    while read dir ; do
        echo "######## ${dir}"
        cd $dir
        git checkout master
        git pull
        cd $OLDPWD
    done
}

alias cal='cal -m'
