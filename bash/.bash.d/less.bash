
# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Emulate 'less' with 'vim' for syntax highlighting. Different numbers
# for Debian/Ubuntu.
if [ -x /usr/share/vim/vim72/macros/less.sh ] ; then
    alias less='/usr/share/vim/vim72/macros/less.sh'
elif [ -x /usr/share/vim/vim71/macros/less.sh ] ; then
    alias less='/usr/share/vim/vim71/macros/less.sh'
fi
# pless () { pygmentize -l $1 $2 | less ; }

export PAGER=less
export LESSOPEN="| $(which highlight) %s --out-format xterm256 --force -s molokai --no-trailing-nl"
export LESS='-R'
# Colorized man pages with 'less'.
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
export GROFF_NO_SGR=1                   # For Konsole and Gnome-terminal
