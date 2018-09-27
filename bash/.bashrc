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


### __kube_ps1()
### {
###   local CONTEXT NS
###   local KUBE_PS1_SYMBOL_DEFAULT=$'\xE2\x8E\x88'
### 
###   CONTEXT=$(kubectl config current-context)
###   NS=$(kubectl config view -o json \
###       | jq -r ".contexts | map(select(.name == \"${CONTEXT}\")) | .[].context.namespace")
###   echo "${KUBE_PS1_SYMBOL_DEFAULT} ${CONTEXT}:${NS}"
### }
### 
### GIT_PS1_SHOWDIRTYSTATE="yepes"          # * staged | + unstaged
### GIT_PS1_SHOWSTASHSTATE="yepes"          # $ stashed
### GIT_PS1_SHOWUNTRACKEDFILES="yepes"      # % untracked
### GIT_PS1_SHOWUPSTREAM="auto"             # < behind | > ahead | <> diverged | = no difference
### source ~/.git-prompt.sh
### 
### NORMAL="\[\e[00m\]"     # Normal
### BLACK="\[\e[0;30m\]"    # Black
### RED="\[\e[1;31m\]"      # Red
### GREEN="\[\e[0;32m\]"    # Green
### YELLOW="\[\e[0;33m\]"   # Yellow
### BLUE="\[\e[0;34m\]"     # Blue
### PURPLE="\[\e[0;35m\]"   # Purple
### CYAN="\[\e[0;36m\]"     # Cyan
### WHITE="\[\e[0;37m\]"    # White
### 
### SMILEY="${WHITE}:)${NORMAL}"
### FROWNY="${RED}:(${NORMAL}"
### 
### LINE_FILL=`printf -- '- %.0s' {1..200}`
### # [todo] recalculate $width using PROMPT_COMMAND
### # width=$((COLUMNS-10))
### # PS1="${YELLOW}\w${PURPLE}$(__git_ps1)${NORMAL} ${LINE_FILL:0:50}\u@\h\n${BLUE}$(__kube_ps1)${NORMAL} \$ "
### 
### # PS1="${YELLOW}\w${PURPLE} \$(__git_ps1)${NORMAL}\n${BLUE}\$(__kube_ps1)${NORMAL} \$ "
### PS1="${PURPLE}\$(__git_ps1) ${YELLOW}\w${NORMAL}\n${BLUE}\$(__kube_ps1)${NORMAL} \$ "

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

# if [ "$TERM" != "linux" ]; then
#     source ~/.local/bin/pureline ~/.config/pureline/pureline.conf
# fi

function _update_ps1() {
    PS1="$(powerline-go -error $? -modules 'git,nix-shell,venv,ssh,root,vgo,cwd' -shorten-gke-names -newline -cwd-mode plain -path-aliases \~/code/wallapop=@WPOP)"
    # PS1="$(powerline-go -error $? -modules 'nix-shell,root,cwd' -shorten-gke-names -cwd-mode plain -path-aliases \~/code/onna=@ONNA)"
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

export PATH=~/bin:~/code/user-land:~/code/git-aliases:~/code/onna/ops-team/scripts:/usr/local/sbin:/usr/sbin:/sbin:$PATH
shopt -s histappend

export VISUAL='vim'
export EDITOR=$VISUAL
export GPG=gpg2

# PATH=$PATH:$HOME/.rvm/bin         # Add RVM to PATH for scripting
unset SSH_ASKPASS

export ONI_NEOVIM_PATH=/usr/bin/nvim


for rc in ~/.bash.d/*.secrets ; do source ${rc} ; done
for rc in ~/.bash.d/*.bash ; do source ${rc} ; done

