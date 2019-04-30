#!/bin/bash

eval "$(fasd --init auto)"

unalias d
unalias z
unalias f

function d() {
    fasd -dRl "$1" | fzf -1 -0 --no-sort +m
}

# fasd & fzf change directory - jump using `fasd` if given argument,
# filter output of `fasd` using `fzf` else
function z() {
    [ $# -gt 0 ] && fasd_cd -d "$*" && return
    local dir
    dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}

# fasd & fzf change directory - open best matched file using `fasd` if
# given argument, filter output of `fasd` using `fzf` else
function v() {
    [ $# -gt 0 ] && fasd -f -e ${EDITOR} "$*" && return
    local file
    file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m)" && vi "${file}" || return 1
}
