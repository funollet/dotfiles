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
    local env role prefix addr

    case $1 in
        Prod)   env=prod ;;
        Beta)   env=beta ;;
        *)      env=$1
    esac
    case $2 in
        Fluent|fluentd|fluent)  role=Fluentd ;;
        *)                      role=$2
    esac
    case ${role} in
        Fluentd)    prefix='ubuntu@' ;;
        *)          prefix='' ;;
    esac

    ec2query () {
        aws ec2 describe-instances --no-paginate --output json \
            --filters "Name=tag:Env,Values=${env}" "Name=tag:Role,Values=${role}" \
                      "Name=instance-state-name,Values=running" \
            --query "Reservations[].Instances"
    }
    
    jq_filter () {
        cat <<.
            .[][] |
            # enrich all tags with user@IP
            .Tags[] + { "Ip": ["${prefix}", .PrivateIpAddress]|join("") } |
            # keep only tags with Key="Name"
            select(.Key=="Name") |
            [ .Value, .Ip ] | @tsv
.
    }

    addr=$(ec2query | jq -r -f <(jq_filter) | fzf -n1 | awk '{print $2}' )
    ssh "${addr}"

    # Remove the local functions from global env.
    unset -f jq_filter
    unset -f ec2query
}
