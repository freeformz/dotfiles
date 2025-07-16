function gpof --wraps=git --description='git push origin the current branch force'
    gpo --force-with-lease $argv
end
