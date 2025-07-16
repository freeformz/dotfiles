function branch_done --wraps=git --description='done with the branch'
    set -l cb (git branch --show-current)
    gcmu
    git branch -D $cb
end