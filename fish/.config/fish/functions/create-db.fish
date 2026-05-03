function create-db --description 'setup cleo test and dev db'
  bundle exec rake db:drop
  bundle exec rake db:create
  bundle exec rake db:schema:load
  RAILS_ENV=test bundle exec rake db:setup
  bundle exec rake db:seed
end
