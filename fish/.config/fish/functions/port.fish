function port --wraps='lsof -i :' --description 'alias port lsof -i :'
  lsof -i ":$argv"
    
end
