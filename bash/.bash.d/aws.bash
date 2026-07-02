#!/bin/bash

# export AWS_PROFILE="default"

awsprofile() {
  # Interactive AWS profile picker. Shows the SSO account id in a second column.
  local rows selection profile
  # Parse ~/.aws/config in a single pass instead of one `aws` call per profile
  # (each call boots the whole CLI, which is what made this slow).
  rows=$(
    awk '
      /^\[/ {
        # Only [default] and [profile NAME] are profiles; skip [sso-session ...].
        if ($0 !~ /^\[(default\]|profile )/) { profile = ""; next }
        gsub(/^\[(profile )?|\]$/, "")
        profile = $0
        acct[profile] = "-"
        order[++n] = profile
      }
      profile != "" && /^[[:space:]]*sso_account_id[[:space:]]*=/ {
        split($0, kv, "=")
        gsub(/[[:space:]]/, "", kv[2])
        acct[profile] = kv[2]
      }
      END { for (i = 1; i <= n; i++) printf "%s\t%s\n", order[i], acct[order[i]] }
    ' "${AWS_CONFIG_FILE:-$HOME/.aws/config}" | sort | column -t -s $'\t'
  )
  selection=$(
    printf '%s\n' "$rows" \
      | fzf --no-multi --prompt "Choose active AWS profile: " --header "[Current: $AWS_PROFILE]"
  )
  profile=${selection%% *}
  [ -n "$profile" ] && export AWS_PROFILE="$profile"
}

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

aaws-ec2-whois() {
  # $1: Private IP of the instance or instance_id
  id=$1

  if [ "${id::2}" = 'i-' ]; then
    filter_name="instance-id"
  else
    filter_name="network-interface.addresses.private-ip-address"
  fi
  aws ec2 describe-instances --output json \
    --filters "Name=${filter_name},Values=${id}" \
    | jq --sort-keys '.Reservations[].Instances[] | (.Tags | from_entries) + {"InstanceId": .InstanceId, "PrivateIpAddress": .PrivateIpAddress, "ImageId": .ImageId, "AZ": .Placement.AvailabilityZone} '
}

aaws-ec2-bytag() {
  aws ec2 describe-instances --output json --filters "Name=tag:$1,Values=$2"
}

aaws-prodbytag() {
  aws ec2 describe-instances --output json --filters "Name=tag:$1,Values=$2" \
    "Name=instance-state-name,Values=running,pending" "Name=tag:Env,Values=prod" \
    --query "Reservations[].Instances[]"
}

aaws-betabytag() {
  aws ec2 describe-instances --output json --filters "Name=tag:$1,Values=$2" \
    "Name=instance-state-name,Values=running,pending" "Name=tag:Env,Values=beta" \
    --query "Reservations[].Instances[]"
}

aaws-asgpick() {
  ASGTARGET=$(aws autoscaling describe-auto-scaling-groups --output json \
    | jq .AutoScalingGroups[].AutoScalingGroupName -r \
    | fzf)
  export ASGTARGET
  echo $ASGTARGET
}

aaws-ecr-login() {
  aws ecr get-login-password | docker login \
    --username AWS \
    --password-stdin "745640521341.dkr.ecr.eu-west-1.amazonaws.com"
}

aaws-running-instances() {
  # list names of running instances
  aws ec2 describe-instances \
    --filter Name=instance-state-name,Values=running \
    --output json \
    | jq -r '.Reservations[].Instances[].Tags[] | select(.Key=="Name") | .Value'
}

aaws-running-instances-show() {
  # show running instances in a table
  aws ec2 describe-instances \
    --filter Name=instance-state-name,Values=running \
    --output table \
    --query 'Reservations[].Instances[].{ID: InstanceId,Hostname: PublicDnsName,Name: Tags[?Key==`Name`].Value | [0],Type: InstanceType}'
}
