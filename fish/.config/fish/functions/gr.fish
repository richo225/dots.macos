function gr --wraps='git rebase origin main' --description 'alias gr git rebase origin main'
  git rebase main $argv
        
end
