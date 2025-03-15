#!/bin/bash

export KUBECONFIG=~/.kube/config

which kubectl > /dev/null 2>&1 || return

if command -v fzf >/dev/null 2>&1 ; then
	source <(kubectl completion bash | sed 's#"${requestComp}" 2>/dev/null#"${requestComp}" 2>/dev/null | head -n -1 | fzf  --multi=0 #g')
else
  source <(kubectl completion bash)
fi

# Replaced this alias by a symlink on ~/bin
# alias k=kubectl
complete -F __start_kubectl k
# source ~/code/kubefzf/kubectl.fzf.completion.bash

# Run k8set on Alt-k.
bind -x '"\ek":"_kube_fzf_resource_selector"'


k8labels () {
    kubectl get pods --show-labels | grep "$@"
}

k8startedAt () {
    # Show state.running.startedAt.
    local pods
    pods=$(kubectl get pods | fzf --header-lines=1 -m | awk -vORS=' ' '{print "pod/" $1}')
    kubectl get ${pods} --no-headers \
        -o custom-columns=pod:.metadata.name,startedAt:'.status.containerStatuses[0].state.running.startedAt' \
        --sort-by '.status.containerStatuses[0].state.running.startedAt'
}
