
# source /etc/bash_completion.d/fzf
source /usr/share/fzf/shell/key-bindings.bash

export FZF_DEFAULT_OPTS="--color=light --reverse"
export FZF_DEFAULT_COMMAND='ag -l -g ""'

# on ALT-c (dirs) use 'tree' as preview
command -v tree > /dev/null && export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -$LINES'"
command -v blsd > /dev/null && export FZF_ALT_C_COMMAND='blsd' \

fzcut () {
    local column headers
    column=${1:-1}              # $1 (default: 1)
    header_lines=${2:-0}        # $2 (default: 0)

    fzf --no-sort --header-lines=${header_lines} \
        | awk -vORS=' ' "{print \$${column}}" | xclip -i
    xclip -o
}

