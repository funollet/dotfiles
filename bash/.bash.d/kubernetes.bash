#!/bin/bash

export KUBECONFIG=~/.kube/config

which kubectl > /dev/null 2>&1 || return

source <(kubectl completion bash)
alias k=kubectl
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


k8sh () {
  local pod ns
  ns=$(kubectl get ns \
      | fzf --header-lines=1 --height=40% --prompt="$(kubectl config current-context):namespace > " \
      | awk '{print $1}' )
  pod=$(kubectl -n ${ns} get pods | fzf --header-lines=1 -q "$*" | awk -vORS=' ' '{print $1}')
  kubectl -n ${ns} exec -it ${pod} -- sh
}
