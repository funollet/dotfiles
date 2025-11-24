#_Read-only token to retrieve passwods from 1Password in non-interactive scripts.
OP_SERVICE_ACCOUNT_TOKEN="$(secret-tool lookup application 1password vault non-interactive)"
export OP_SERVICE_ACCOUNT_TOKEN
