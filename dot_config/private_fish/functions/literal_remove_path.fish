function remove_path
  if set -l index (contains -i "$argv" $fish_user_paths)
    set -g -e fish_user_paths[$index]
    echo "Removed $argv from the path"
  end
end