function rr --wraps='bundle exec rails routes -g' --description 'alias rr bundle exec rails routes -g'
  bundle exec rails routes -g $argv
        
end
