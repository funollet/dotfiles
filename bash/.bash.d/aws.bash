#!/bin/bash

complete -C aws_completer aws       # awscli: autocompletion

export AWS_PROFILE=production

which awless > /dev/null 2>&1 && source <(awless completion bash)

## ec2-search-id () {
##     # Parallel search of an EC2 InstanceID on multiple accounts.
##     AWS_ACCOUNTS='parsing web rtb info sistemas'
## 
##     echo -n $AWS_ACCOUNTS \
##         | xargs -P0 -d' ' -n1 -i -- \
##             aws --profile {} ec2 describe-instances \
##             --filters Name=instance-id,Values=${1} \
##             --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value[]' \
##             --output text
## }

ec2-by-tag () {
    local env
    local role

    case $1 in
        Prod) env=prod ;;
        Beta) env=beta ;;
        *) env=$1
    esac
    case $2 in
        Fluent|fluentd|fluent) role=Fluentd ;;
        *) role=$2
    esac
    
    aws ec2 describe-instances --no-paginate \
        --filters "Name=tag:Env,Values=${env}" "Name=tag:Role,Values=${role}" \
                  "Name=instance-state-name,Values=running" \
        --query "Reservations[].Instances" \
    | jq '.[][] | .Tags[] + { "Ip": .PrivateIpAddress } | select(.Key=="Name") | del(.Key)'
}
