alias ghcommit='( git status && git diff --cached && echo /commit-message-skill ) | claude'
alias ghpr='gh pr create --assignee "@me" --title "$(git branch --show-current)"'
alias ghprdraft='gh pr create --assignee "@me" --title "$(git branch --show-current)" --draft'
