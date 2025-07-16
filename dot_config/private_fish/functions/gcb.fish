function gcb --wraps='git checkout' --description='git checkout -b'
    git checkout -b $argv
end
