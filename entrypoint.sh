# Compile the assets
bundle exec rake assets:precompile

# Start the server
cp config/environments/development.rb_with_remote_byebug config/environments/development.rb
bundle exec rails server -b 0.0.0.0
