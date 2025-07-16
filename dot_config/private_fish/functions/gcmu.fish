function gcmu --wraps=git --description='git checkout main or master and then update'
    set -l branch (git branch -l main master --format '%(refname:short)')
    git checkout $branch
    git pull origin $branch
end
