# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put in history duplicated lines and line starting with space 
export HISTCONTROL=ignoreboth

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

export TERM=xterm-256color

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
    PS1="$(powerline-go -error $? -modules 'git,venv,ssh,root,kube,cwd' -newline -cwd-mode fancy -shorten-gke-names -path-aliases \~/code/nuclia=@N)"
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

export PATH=$PATH:/sbin:~/bin:~/.local/bin:~/code/user-land:~/code/git-aliases:~/.cargo/bin
shopt -s histappend

export VISUAL='lvim'
export EDITOR=$VISUAL
export GPG=gpg2

# PATH=$PATH:$HOME/.rvm/bin         # Add RVM to PATH for scripting
unset SSH_ASKPASS

export ONI_NEOVIM_PATH=/usr/bin/nvim
export FORGIT_COPY_CMD=xclip

export CHEAT_USE_FZF=true

export RIPGREP_CONFIG_PATH=~/.config/ripgrep/ripgreprc

if which mise > /dev/null 2>&1 ; then
  eval "$(/usr/bin/mise activate bash)"
  _mise_hook
fi

for rc in ~/.bash.d/*.secrets ; do source ${rc} ; done
for rc in ~/.bash.d/*.bash ; do source ${rc} ; done
