require "byebug/core"

if Rails.env.development?
  Byebug.wait_connection = false
  Byebug.start_server 'localhost', ENV.fetch("BYEBUG_SERVER_PORT", 5000).to_i
end

# later, if application is running development env, the
# remote byebug can be accessed similar to:
# bundle exec byebug -R localhost:5000
