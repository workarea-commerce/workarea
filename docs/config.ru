require 'bundler/setup'
Bundler.require(:default)

middleman = Middleman::Application.new
app = Middleman::Rack.new(middleman).to_app

run app
