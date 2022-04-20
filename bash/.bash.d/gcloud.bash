#!/bin/bash

# Activate a config. Every config has a *default* GKE cluster but can be associated to
# multiple clusters.
# gcconf () {
#     gcloud config configurations list | fzf +m --header-lines=1 +s | awk '{print $1}' | \
#         xargs --no-run-if-empty gcloud config configurations activate
# }
