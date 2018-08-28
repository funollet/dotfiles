
complete -C aws_completer aws       # awscli: autocompletion

which awless > /dev/null 2>&1 && source <(awless completion bash)

ec2-search-id () {
    # Parallel search of an EC2 InstanceID on multiple accounts.
    AWS_ACCOUNTS='parsing web rtb info sistemas'

    echo -n $AWS_ACCOUNTS \
        | xargs -P0 -d' ' -n1 -i -- \
            aws --profile {} ec2 describe-instances \
            --filters Name=instance-id,Values=${1} \
            --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value[]' \
            --output text
}
