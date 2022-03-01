#!/bin/bash

source `asdf where gcloud`/completion.bash.inc
source `asdf where gcloud`/path.bash.inc

alias gssh='gcloud compute ssh --tunnel-through-iap'
alias gsshbr="gcloud compute ssh --zone southamerica-east1-b --tunnel-through-iap"
alias gsshusc1="gcloud compute ssh --zone us-central1-a --tunnel-through-iap"
alias gscp='gcloud compute scp --tunnel-through-iap'
alias gci='gcloud compute instances'

# Activate a config. Every config has a *default* GKE cluster but can be associated to
# multiple clusters.
gcconf () {
    gcloud config configurations list | fzf +m --header-lines=1 +s | awk '{print $1}' | \
        xargs --no-run-if-empty gcloud config configurations activate
}



# #### GCP
# # EU
# alias gsh="gcloud compute ssh --tunnel-through-iap"
# alias gcp="gcloud compute scp --tunnel-through-iap"
# alias gci="gcloud compute instances"
# # BR
# alias gcpbr="gcloud compute scp --zone southamerica-east1-b --tunnel-through-iap"
# alias gcibr="gcloud compute instances --zone southamerica-east1-b"
# # USC1
# alias gcpusc1="gcloud compute scp --zone us-central1-a --tunnel-through-iap"
# alias gciusc1="gcloud compute instances --zone us-central1-a"
