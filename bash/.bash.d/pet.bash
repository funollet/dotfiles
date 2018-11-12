#!/usr/bin/env bash
# pet.bash

_pet_complete() {
    COMPREPLY=()
    local current="${COMP_WORDS[COMP_CWORD]}"
    local completions="configure edit exec help list new search sync version"

    COMPREPLY=( $(compgen -W "${completions}" -- "${current}") )
}

complete -F _pet_complete pet
