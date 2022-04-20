
alias gitst='git status'
alias gitdc='git diff --cached'

git-pull-dirs() {
    while read dir ; do
        echo "######## ${dir}"
        cd $dir
        git checkout master
        git pull
        cd $OLDPWD
    done
}

## https://thoughtbot.com/blog/powerful-git-macros-for-automating-everyday-workflows
#

gbc() {
  # (git branch changes) to see what the current branch has that the base branch does not
  # pass base branch as first argument
  git log --graph \
    --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' \
    --abbrev-commit --date=relative \
    $@..$(git rev-parse --abbrev-ref HEAD)
}

gbbc() {
  # (git base branch changes) to see what the base branch has that the current branch does not
  # pass base branch as first argument
  git log --graph \
    --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' \
    --abbrev-commit --date=relative \
    $(git rev-parse --abbrev-ref HEAD)..$@
}
