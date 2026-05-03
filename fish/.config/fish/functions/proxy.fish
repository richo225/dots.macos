function proxy --wraps='ssh -vnNT -R 3090:localhost:3000 cleo_development_proxy' --description 'alias proxy ssh -vnNT -R 3090:localhost:3000 cleo_development_proxy'
  ssh -vnNT -R 3090:localhost:3000 cleo_development_proxy $argv
        
end
