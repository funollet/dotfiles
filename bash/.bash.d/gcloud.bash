#!/bin/bash

# Activate a config. Every config has a *default* GKE cluster but can be associated to
# multiple clusters.
# gcconf () {
#     gcloud config configurations list | fzf +m --header-lines=1 +s | awk '{print $1}' | \
#         xargs --no-run-if-empty gcloud config configurations activate
# }

alias gssh='gcloud compute ssh'
alias gscp='gcloud compute scp'

_complete_gcloud_instance () {
    instance="$(ginstance)"
    COMPREPLY+=("$instance")
}

complete -F _complete_gcloud_instance gssh
complete -F _complete_gcloud_instance gscp
