#!/bin/bash

# Config for wallapop-aws-credentials.
test -f 00.bash.secrets && source 00.bash.secrets

# alias wallapop-aws-credentials="docker run --rm -it \
#     -v ~/.aws/credentials:/data/credentials \
#         -e PROFILE=production \
#         -e GOOGLE_USERNAME=\${WPOP_GOOGLE_USERNAME} \
#         -e GOOGLE_IDP_ID=\${WPOP_GOOGLE_IDP_ID} \
#         -e GOOGLE_SP_ID=\${WPOP_GOOGLE_SP_ID} \
#         -e REGION=eu-west-1 \
#     wallapop/federated-credentials:latest"

alias wallapop-aws-credentials="aws-google-auth \
    --username \${WPOP_GOOGLE_USERNAME} \
    --idp-id \${WPOP_GOOGLE_IDP_ID} \
    --sp-id \${WPOP_GOOGLE_SP_ID} \
    --region eu-west-1 \
    --profile production"

alias cfn-lint="cfn-lint -a ~/code/wallapop/platform/docker-base-images/cfn-lint/custom_rules/"

ec2listenvs () {
    aws ec2 describe-instances --output json --filters "Name=tag-key,Values=Env" \
        | jq '.Reservations[].Instances[].Tags[] | select(.Key=="Env")' \
        | grep Value | sort | uniq
}
