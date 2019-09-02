#!/bin/bash

# Config for wallapop-aws-credentials.
# test -f ~/.bash.d/00.bash.secrets && source ~/.bash.d/00.bash.secrets
# 
# alias wallapop-aws-credentials="docker run --rm -it \
#     -v ~/.aws/credentials:/root/credentials \
#         -e GOOGLE_USERNAME=\${GOOGLE_USERNAME} \
#         -e GOOGLE_IDP_ID=\${GOOGLE_IDP_ID} \
#         -e GOOGLE_SP_ID=\${GOOGLE_SP_ID} \
#         -e REGION=eu-west-1 \
#     wallapop/federated-credentials:latest --log debug"

# Running locally:
# No need to load 00.bash.secrets: just provide the values on the first run and
# those will be cached on ~/.aws/config.
#
#     aws-google-auth --region eu-west-1

alias cfn-lint="cfn-lint -a ~/code/wallapop/platform/docker-base-images/cfn-lint/custom_rules/"

ec2listenvs () {
    aws ec2 describe-instances --output json --filters "Name=tag-key,Values=Env" \
        | jq '.Reservations[].Instances[].Tags[] | select(.Key=="Env")' \
        | grep Value | sort | uniq
}
