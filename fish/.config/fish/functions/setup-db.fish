function setup-db --description 'setup cleo test and dev db without migrate'
  bundle exec rake db:drop
  bundle exec rake db:create
  bundle exec rake db:schema:load
end
