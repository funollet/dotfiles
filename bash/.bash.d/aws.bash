#!/bin/bash

# export AWS_PROFILE="default"

_awsprofile_table() {
  # Print an aligned "<profile>  <alias>  <sso account id>" table, one row per
  # profile in the AWS config, sorted by name. Anything unknown shows a "-".
  #
  # Read straight from the config: asking the AWS CLI for each profile boots the
  # whole CLI once per profile, which is what made this slow.
  #
  # -N everywhere so a future --line-number in ~/.config/ripgrep/ripgreprc can't
  # prepend numbers to any of these intermediate lines.
  local config="${AWS_CONFIG_FILE:-$HOME/.aws/config}"
  local profile account

  # What the account behind each profile is actually called. The AWS config has
  # nowhere to put this, so it is hardcoded; add a line per profile as needed.
  local -A aliases=(
    [network]=SATELIOT
  )

  # Both blocks below emit "<section header>\t<sso_account_id = value>" lines.
  {
    # Keep every section header plus the account ids, so -B1 pairs each id with
    # the header right above it. Keeping *every* header (not just profiles) is
    # what stops an id under [sso-session foo] pairing with the profile before
    # it; the non-profile pairs are dropped further down.
    rg -N '^\[|sso_account_id' "$config" \
      | rg -N -B1 sso_account_id \
      | rg -Nv '^--$' \
      | paste - -

    # A "-" row for every profile, as the fallback for those the block above
    # found no account id for.
    rg -N '^\[(default\]|profile )' "$config" \
      | sed 's/$/\tsso_account_id = -/'
  } \
    | rg -N '^\[(default\]|profile )' \
    | sed -E '
        s/^\[profile ([^]]+)\]/\1/
        s/^\[default\]/default/
        s/\t[[:space:]]*sso_account_id[[:space:]]*=[[:space:]]*/\t/
      ' \
    | awk '!seen[$1]++' \
    | sort \
    | while read -r profile account; do
      printf '%s\t%s\t%s\n' "$profile" "${aliases[$profile]:--}" "$account"
    done \
    | column -t -s $'\t'
}

awsprofile() {
  # Interactive AWS profile picker, showing the account alias and SSO account id
  # next to each profile name.
  #
  # Keep this a shell function, not a script in ~/.local/bin: it has to export
  # AWS_PROFILE into the *current* shell, and a script only ever changes its own
  # environment.
  local selection profile
  selection=$(
    _awsprofile_table \
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
