function rt --wraps='bin/rails test' --description 'alias rt bin/rails test'
  bin/rails test $argv
end
