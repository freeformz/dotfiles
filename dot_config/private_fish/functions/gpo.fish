function gpo --wraps=git --description='git push origin the current branch'
    git push origin (git branch --show-current) $argv
end
