#!/bin/bash

complete -C aws_completer aws       # awscli: autocompletion

export AWS_PROFILE=default

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

ec2whois () {
  # $1: Private IP of the instance or instance_id
  id=$1

  if [ "${id::2}" = 'i-' ] ; then
    filter_name="instance-id"
  else
    filter_name="network-interface.addresses.private-ip-address"
  fi
  aws ec2 describe-instances --output json \
      --filters "Name=${filter_name},Values=${id}" \
  | jq --sort-keys '.Reservations[].Instances[] | (.Tags | from_entries) + {"InstanceId": .InstanceId, "PrivateIpAddress": .PrivateIpAddress, "ImageId": .ImageId} '
}

ec2bytag () {
    aws ec2 describe-instances --output json --filters "Name=tag:$1,Values=$2"
}

prodbytag () {
    aws ec2 describe-instances --output json --filters "Name=tag:$1,Values=$2" \
        "Name=instance-state-name,Values=running,pending" "Name=tag:Env,Values=prod" \
        --query "Reservations[].Instances[]"
}

betabytag () {
    aws ec2 describe-instances --output json --filters "Name=tag:$1,Values=$2" \
        "Name=instance-state-name,Values=running,pending" "Name=tag:Env,Values=beta"  \
        --query "Reservations[].Instances[]"
}
