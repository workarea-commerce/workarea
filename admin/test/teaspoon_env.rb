require 'workarea/testing/teaspoon'

Teaspoon.configure do |config|
  config.root = Workarea::Admin::Engine.root
  Workarea::Teaspoon.apply(config)

  config.suite do |suite|
    suite.stylesheets += ['workarea/admin/application']
  end
end
