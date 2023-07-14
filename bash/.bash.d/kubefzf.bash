#!/bin/bash
# kubefzf.bash
#
# Install: add to your .bashrc
#
#     source your/path/to/kubefzf.bash
#     bind -x '"\ek":"_kube_fzf_resource_selector"'
#
# Usage: just press 'Alt k'.

_kubernetes_resources_names () {
    cat <<.
pods                        po
deployments                 deploy
statefulsets                sts
daemonsets                  ds
services                    svc
persistentvolumeclaims      pvc
persistentvolumes           pv
configmaps                  cm
secrets
endpoints                   ep
events                      ev
ingresses                   ing
namespaces                  ns
nodes                       no
jobs
cronjobs
certificatesigningrequests  csr
clusterrolebindings
clusterroles
clusters
componentstatuses           cs
controllerrevisions
customresourcedefinition    crd
horizontalpodautoscalers    hpa
limitranges                 limits
networkpolicies             netpol
poddisruptionbudgets        pdb
podpreset
podsecuritypolicies         psp
podtemplates
replicasets                 rs
replicationcontrollers      rc
resourcequotas              quota
rolebindings
roles
serviceaccounts             sa
storageclasses
all
.

}

_kube_fzf_resource_selector () {
    local resource namespace context out prefix pre_line post_line

    # trim="${READLINE_LINE%% }"    # trim spaces at end of line, just in case

    resource=$(_kubernetes_resources_names \
        | fzf --no-sort --height=40% --prompt="${READLINE_LINE}" \
        | awk '{ if (NF==2) print $2 ; else print $1}')

    # Read namespace from $KUBECONFIG file.
    context=$(kubectl config current-context)
    namespace=$(kubectl config view -o jsonpath="{.contexts[?(.name==\"${context}\")].context.namespace}")
    # Alternative: pass namespace on current readline, preceded by '-n'.
    #namespace=$(echo $READLINE_LINE | sed 's/.* -n //;s/ .*//')
    case "${READLINE_LINE}" in
        *" log "*)          prefix="" ;;
        *" logs "*)         prefix="" ;;
        *" exec "*)         prefix="" ;;
        *" port-forward "*) prefix="" ;;
        *" top pod "*)      prefix="" ;;
        *" top node "*)     prefix="" ;;
        *)                  prefix="${resource}/" ;;
    esac


    out=$(kubectl get -n "${namespace}" "${resource}" \
        | fzf -m --header-lines=1 --height=40% --prompt="${READLINE_LINE} ${prefix}" \
        | awk -vRES="${prefix}" -vORS=' ' '{print RES $1}')
    # Insert into current line.
    pre_line="${READLINE_LINE:0:$READLINE_POINT}"
    post_line="${READLINE_LINE:$READLINE_POINT}"
    READLINE_LINE="${pre_line}${out}${post_line}"
    READLINE_POINT=$(( ${#pre_line} + ${#out} ))
}
