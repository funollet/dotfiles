#!/bin/bash

if asdf which gcloud > /dev/null 2>&1 ; then
    source `asdf where gcloud`/completion.bash.inc
    source `asdf where gcloud`/path.bash.inc
fi

if which kubectl > /dev/null 2>&1 ; then
    source <(kubectl completion bash)
fi

if which pipx > /dev/null 2>&1 ; then
    eval "$(register-python-argcomplete pipx)"
fi

if which terraform > /dev/null 2>&1 ; then
    complete -C terraform terraform
fi

if which aws > /dev/null 2>&1 ; then
    complete -C aws_completer aws
fi

if which ag > /dev/null 2>&1 ; then
    [ -f /usr/share/bash-completion/completions/ag ] \
        && source /usr/share/bash-completion/completions/ag
fi

if which poetry > /dev/null 2>&1 ; then
    source <(poetry completions bash)
fi

if which cheat > /dev/null 2>&1 ; then
    [ -f /usr/share/bash-completion/completions/cheat ] \
        && source /usr/share/bash-completion/completions/cheat
fi

if which gh > /dev/null 2>&1 ; then
    eval "$(gh completion -s bash)"
fi
