
# source /etc/bash_completion.d/fzf
source /usr/share/fzf/shell/key-bindings.bash

export FZF_DEFAULT_OPTS="--reverse --no-mouse --tabstop=4 --pointer='•' --marker='‣' --color=dark"

export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git --exclude '.*.sw?'"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="fd --type f --type d --hidden --follow --exclude .git --exclude '.*.sw?'"

command -v bat > /dev/null && \
    export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"
command -v lsd > /dev/null && \
    export FZF_ALT_C_OPTS="--preview 'lsd --color always --tree {}'"


fzcut () {
    local column headers
    column=${1:-1}              # $1 (default: 1)
    header_lines=${2:-0}        # $2 (default: 0)

    fzf --no-sort --header-lines=${header_lines} \
        | awk -vORS=' ' "{print \$${column}}" | xclip -i
    xclip -o
}


# https://medium.com/@calbertts/docker-and-fuzzy-finder-fzf-4c6416f5e0b5
runc() {
  export FZF_DEFAULT_OPTS='--height 90% --reverse --border'
  local image=$(docker images --format '{{.Repository}}:{{.Tag}}' | fzf-tmux --reverse --multi)
  if [[ $image != '' ]]; then
    echo -e "\n  \033[1mDocker image:\033[0m" $image
    read -e -p $'  \e[1mOptions: \e[0m' -i "-it --rm" options

    printf "  \033[1mChoose the command: \033[0m"
    local cmd=$(echo -e "/bin/bash\nsh" | fzf-tmux --reverse --multi)
    if [[ $cmd == '' ]]; then
        read -e -p $'  \e[1mCustom command: \e[0m' cmd
    fi
    echo -e "  \033[1mCommand: \033[0m" $cmd

    export FZF_DEFAULT_COMMAND='find ./ -type d -maxdepth 1 -exec basename {} \;'
    printf "  \033[1mChoose the volume: \033[0m"
    local volume=$(fzf-tmux --reverse --multi)
    local curDir=${PWD##*/}
    if [[ $volume == '.' ]]; then
        echo -e "  \033[1mVolume: \033[0m" $volume
        volume="`pwd`:/$curDir -w /$curDir"
    else
        echo -e "  \033[1mVolume: \033[0m" $volume
        volume="`pwd`/$volume:/$volume -w /$volume"
    fi

    export FZF_DEFAULT_COMMAND=""
    export FZF_DEFAULT_OPTS=""

    history -s runc
    history -s docker run $options -v $volume $image $cmd
    echo ""
    echo "### docker run $options -v $volume $image $cmd"
    echo ""
    docker run $options -v $volume $image $cmd
  fi
}
