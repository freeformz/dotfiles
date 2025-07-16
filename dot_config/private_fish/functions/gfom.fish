function gfom --wraps=git --description='git fetch origin main or master'
    set -l branch (git branch -l main master --format '%(refname:short)')
    git fetch origin $branch
end
