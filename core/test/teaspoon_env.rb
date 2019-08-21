require 'workarea/testing/teaspoon'

Teaspoon.configure do |config|
  config.root = Workarea::Core::Engine.root
  Workarea::Teaspoon.apply(config)
end
