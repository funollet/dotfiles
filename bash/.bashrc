# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
#export HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
screen)
    PROMPT_COMMAND='echo -ne "\033k`echo $HOSTNAME |cut -f 1 -d .` `pwd`\033\\"'
    ;;
*)
    # Save/read history at every command.
    PROMPT_COMMAND='history -n ; history -a'
    ;;
esac

function _update_ps1() {
    PS1="$(powerline-go -error $? -modules 'git,nix-shell,venv,ssh,root,kube,terraform-workspace,cwd' -newline -cwd-mode plain -shorten-gke-names -path-aliases \~/code/wallapop=@WPOP)"
}

if [ "$TERM" != "linux" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

# enable bash completion in interactive shells
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Just for Fedora.
if [ -f /etc/redhat-release ] ; then
    [ -f /etc/bashrc ] && . /etc/bashrc
fi

############################################################

export PATH=$PATH:/sbin:~/bin:~/.local/bin:~/code/user-land:~/code/git-aliases
shopt -s histappend

export VISUAL='vim'
export EDITOR=$VISUAL
export GPG=gpg2

# PATH=$PATH:$HOME/.rvm/bin         # Add RVM to PATH for scripting
unset SSH_ASKPASS

export ONI_NEOVIM_PATH=/usr/bin/nvim
export FORGIT_COPY_CMD=xclip

export CHEAT_USE_FZF=true

. ~/.asdf/asdf.sh
. ~/.asdf/completions/asdf.bash

for rc in ~/.bash.d/*.secrets ; do source ${rc} ; done
for rc in ~/.bash.d/*.bash ; do source ${rc} ; done
