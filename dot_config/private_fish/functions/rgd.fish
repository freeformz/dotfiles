function rgd --wraps=rg --description='rg + delta'
    rg --json -C 2 $argv | delta --tabs=1
end
