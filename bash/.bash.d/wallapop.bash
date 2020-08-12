#!/bin/bash

# Config for AWS credentials:
# test -f ~/.bash.d/00.bash.secrets && source ~/.bash.d/00.bash.secrets
# 
# Running locally:
# No need to load 00.bash.secrets: just provide the values on the first run and
# those will be cached on ~/.aws/config.
#
#     aws-google-auth --region eu-west-1
