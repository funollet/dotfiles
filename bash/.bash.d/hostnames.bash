#### Hostnames and SSH management.

# Bash uses this file for hostname completion.
export HOSTFILE=~/.hostnames        # Regenerate it with:
                                    # cd .dsh/ ; make

alias pdsh='pdsh -lroot'
alias pssh='pssh -i -O StrictHostKeyChecking=no -O UserKnownHostsFile=/dev/null -O GlobalKnownHostsFile=/dev/null'

ssh-rm-known-hosts () {
    # Parses input like: 
    #       Offending key for IP in /home/jordif/.ssh/known_hosts:275
    x=$(echo "$*" | cut -d: -f2)
    sed -i "${x}d" ~/.ssh/known_hosts

}

any () {
    ssh $(grep --max-count 1 "$1" ~/.hostnames)
}

grephost () {
    ag --nonumbers "$1" ~/.hostnames
}

dsh-list-short () {
    for GROUP in $* ; do
        # Remove comments.
        egrep -ahv "^[[:space:]]*(#|$)" ~/.dsh/group/$GROUP \
            | sed 's/\..*//'        # Remove domainnames.
    done
}
