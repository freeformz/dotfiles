function grom --wraps=git --description='git rebase origin/main or master'
    set -l branch (git branch -l main master --format '%(refname:short)')
    git fetch origin $branch
    git rebase origin/$branch $argv
end
