#! /bin/bash

HUGO_BASE="$HOME/workingon/study.notes"
export HUGO_BASE

hugonew () {
    cd "${HUGO_BASE}" || exit 1
    hugo new "$@"
    cd "${OLDPWD}" || exit 1
}

hugorun () {
    cd "${HUGO_BASE}" && hugo server
}

hugoedit () {
    fname=$(cd "${HUGO_BASE}/content/" ; \
        fd -t file --exclude '_*.md' | fzf)
    [ -n "${fname}" ] && vim "${HUGO_BASE}/content/${fname}"
}
