#!/bin/bash

if which gcloud >/dev/null 2>&1; then
  source $(mise bin-paths | grep '/installs/gcloud/')/../completion.bash.inc
  source $(mise bin-paths | grep '/installs/gcloud/')/../path.bash.inc
fi

if which mise >/dev/null 2>&1; then
  source <(mise completion bash)
fi

if which kind >/dev/null 2>&1; then
  source <(lazycomplete \
    kind 'kind completion bash')
fi

if which kubectl >/dev/null 2>&1; then
  source <(lazycomplete \
    kubectl 'kubectl completion bash')
fi

if which pipx >/dev/null 2>&1; then
  eval "$(register-python-argcomplete pipx)"
fi

if which terraform >/dev/null 2>&1; then
  complete -C terraform terraform
fi

if which aws >/dev/null 2>&1; then
  complete -C aws_completer aws
fi

if which ag >/dev/null 2>&1; then
  [ -f /usr/share/bash-completion/completions/ag ] &&
    source /usr/share/bash-completion/completions/ag
fi

if which argocd >/dev/null 2>&1; then
  source <(argocd completion bash)
fi

if which poetry >/dev/null 2>&1; then
  source <(lazycomplete \
    poetry 'poetry completions bash')
fi

if which cheat >/dev/null 2>&1; then
  [ -f /usr/share/bash-completion/completions/cheat ] &&
    source /usr/share/bash-completion/completions/cheat
fi

if which gh >/dev/null 2>&1; then
  eval "$(gh completion -s bash)"
fi

if which helm >/dev/null 2>&1; then
  source <(helm completion bash)
fi

if which vault >/dev/null 2>&1; then
  complete -C $(which vault) vault
fi

if which gcrane >/dev/null 2>&1; then
  source <(lazycomplete \
    gcrane 'gcrane completion bash')
fi

if which vagrant >/dev/null 2>&1; then
  version=$(vagrant -v | awk '{print $2}')
  source /opt/vagrant/embedded/gems/gems/vagrant-${version}/contrib/bash/completion.sh
fi

if which eksctl >/dev/null 2>&1; then
  source <(lazycomplete \
    eksctl 'eksctl completion bash')
fi

if which eksdemo >/dev/null 2>&1; then
  source <(lazycomplete \
    eksdemo 'eksdemo completion bash')
fi
