#!/bin/bash

# Config for wallapop-aws-credentials.
test -f 00.bash.secrets && source 00.bash.secrets

alias wallapop-aws-credentials="docker run --rm -it \
    -v ~/.aws/credentials:/data/credentials \
        -e PROFILE=production \
        -e GOOGLE_USERNAME=\${WPOP_GOOGLE_USERNAME} \
        -e GOOGLE_IDP_ID=\${WPOP_GOOGLE_IDP_ID} \
        -e GOOGLE_SP_ID=\${WPOP_GOOGLE_SP_ID} \
        -e REGION=eu-west-1 \
    wallapop/federated-credentials:latest"
