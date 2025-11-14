require "sinatra"

set :bind, "0.0.0.0"
port = ENV["PORT"] || "3000"
set :port, port

# Allow requests from any host in the development environment
configure :development do 
  set :host_authorization, { permitted_hosts: [] }
end

get "/" do
  name = ENV["NAME"] || "World"
  "Hello #{name}!"
end