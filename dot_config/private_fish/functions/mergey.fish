function mergey --wraps='gh pr merge' --description='attempts to merge the pr in a loop'
    while ! gh pr merge -d -s; sleep 20; end 
end
