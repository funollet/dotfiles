#!/bin/bash

if which bin > /dev/null 2>&1 ; then
    source <(bin completion bash)
fi

if which gcloud > /dev/null 2>&1 ; then
  source $(rtx bin-paths | grep '/installs/gcloud/')/../completion.bash.inc
  source $(rtx bin-paths | grep '/installs/gcloud/')/../path.bash.inc
fi

if which rtx > /dev/null 2>&1 ; then
    source <(rtx completion bash)
fi

if which nuclia-cli > /dev/null 2>&1 ; then
    source <(lazycomplete \
        nuclia-cli 'nuclia-cli --show-completion bash')
fi

if which k3d > /dev/null 2>&1 ; then
    source <(lazycomplete \
        k3d 'k3d completion bash')
fi

if which kind > /dev/null 2>&1 ; then
    source <(lazycomplete \
        kind 'kind completion bash')
fi

if which kubectl > /dev/null 2>&1 ; then
    source <(lazycomplete \
        kubectl 'kubectl completion bash')
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

if which argocd > /dev/null 2>&1 ; then
    source <(argocd completion bash)
fi

if which poetry > /dev/null 2>&1 ; then
    source <(lazycomplete \
        poetry 'poetry completions bash')
fi

if which cheat > /dev/null 2>&1 ; then
    [ -f /usr/share/bash-completion/completions/cheat ] \
        && source /usr/share/bash-completion/completions/cheat
fi

if which gh > /dev/null 2>&1 ; then
    eval "$(gh completion -s bash)"
fi

if which helm > /dev/null 2>&1 ; then
    source <(helm completion bash)
fi

if which vault > /dev/null 2>&1 ; then
    complete -C $(which vault) vault
fi
