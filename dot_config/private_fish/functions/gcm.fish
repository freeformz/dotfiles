function gcm --wraps=git --description='git checkout main or master'
    set -l branch (git branch -l main master --format '%(refname:short)')
    git checkout $branch
end
