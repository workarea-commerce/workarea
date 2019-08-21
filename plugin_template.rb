# Start with...
# rails plugin new path/to/my_plugin --full -m path/to/plugin_template.rb --skip-spring --skip-active-record --skip-action-cable
#

#
# Namespace plugin under Workarea
#
remove_file "lib/#{name}.rb"
create_file "lib/workarea/#{name}.rb", <<~CODE
  require 'workarea'
  require 'workarea/storefront'
  require 'workarea/admin'

  require 'workarea/#{name}/engine'
  require 'workarea/#{name}/version'

  module Workarea
    module #{camelized}
    end
  end
CODE

remove_file "lib/#{name}/version.rb"
create_file "lib/workarea/#{name}/version.rb", <<~CODE
  module Workarea
    module #{camelized}
      VERSION = "0.1.0"
    end
  end
CODE

remove_file "lib/#{name}/engine.rb"
create_file "lib/workarea/#{name}/engine.rb", <<~CODE
  require 'workarea/#{name}'

  module Workarea
    module #{camelized}
      class Engine < ::Rails::Engine
        include Workarea::Plugin
        isolate_namespace Workarea::#{camelized}
      end
    end
  end
CODE

create_file 'config/initializers/workarea.rb', <<~CODE
  Workarea.configure do |config|
    # Add custom configuration here
  end
CODE

#
# Selectively require rails gems, removing ActiveRecord
#
rails_requires = <<~CODE
  require "action_controller/railtie"
  require "action_view/railtie"
  require "action_mailer/railtie"
  require "rails/test_unit/railtie"
  require "sprockets/railtie"
  require 'teaspoon-mocha'
CODE

gsub_file 'bin/rails', /.+rails\/all.+/, rails_requires
gsub_file 'test/dummy/config/application.rb', /.+rails\/all.+/, rails_requires

#
# Require Workarea in dummy app configuration, before plugin
#
require_workarea = <<~CODE
  # Workarea must be required before other gems to ensure control over Rails.env
  # for running tests
  require 'workarea/core'
  require 'workarea/admin'
  require 'workarea/storefront'
CODE

inject_into_file 'test/dummy/config/application.rb', require_workarea, before: 'Bundler.require(*Rails.groups)'

#
# Modify bin/rails, correct path to engine file
#
gsub_file 'bin/rails', %r(lib/#{name}/engine), %(lib/workarea/#{name}/engine)

#
# Require Plugin in dummy app configuration
#
gsub_file "test/dummy/config/application.rb", /require.+"#{name}"/, %(require "workarea/#{name}")

#
# Comment out any active record config in dummy app
#
comment_lines 'test/dummy/config/environments/development.rb', /active_record/
comment_lines 'test/dummy/config/environments/production.rb', /active_record/

#
# Remove database config from dummy app
#
remove_file 'test/dummy/config/database.yml'

#
# Allow seeds to be run from dummy app
#
create_file 'test/dummy/db/seeds.rb', <<~CODE
  require 'workarea/seeds'
  Workarea::Seeds.run
CODE

#
# Remove ActionCable files from dummy app
#
remove_file 'test/dummy/app/assets/javascripts/cable.js'
remove_dir 'test/dummy/app/assets/javascripts/channels'
remove_dir 'test/dummy/app/channels'

#
# Remove assets config
# This is for Sprockets 4, remove this when we upgrade Sprockets
#
remove_dir 'app/assets/config'

#
# Remove application_record from dummy app
#
remove_file 'test/dummy/app/models/application_record.rb'

#
# Configure dummy app
#
create_file 'test/dummy/config/initializers/workarea.rb', <<~CODE
  Workarea.configure do |config|
    # Basic site info
    config.site_name = 'Workarea #{name.titleize}'
    config.host = 'www.example.com'
  end
CODE

#
# Update routes in dummy app
#
remove_file 'test/dummy/config/routes.rb'
create_file 'test/dummy/config/routes.rb', <<~CODE
  Rails.application.routes.draw do
    mount Workarea::Core::Engine => '/'
    mount Workarea::Admin::Engine => '/admin', as: 'admin'
    mount Workarea::Storefront::Engine => '/', as: 'storefront'
  end
CODE

#
# Create teaspoon env in dummy app
#
create_file 'test/teaspoon_env.rb', <<~CODE
  require 'workarea/testing/teaspoon'

  Teaspoon.configure do |config|
    config.root = Workarea::#{camelized}::Engine.root
    Workarea::Teaspoon.apply(config)
  end
CODE

#
# Remove default tests
#
remove_file "test/#{name}_test.rb"
remove_file 'test/integration/navigation_test.rb'

#
# Namespace plugin under Workarea in gemspec
#
gsub_file "#{name}.gemspec", /#{name}\/version/, "workarea/#{name}/version"
gsub_file "#{name}.gemspec", /(#{camelized}::VERSION)/, 'Workarea::\1'
gsub_file "#{name}.gemspec", /(spec\.name\s+).+/, "\\1= \"workarea-#{name}\""

#
# Use the git file list for plugin's manifest
#
gsub_file "#{name}.gemspec", /spec.files.+\n\n/, "spec.files = `git ls-files`.split(\"\\n\")"

#
# Remove licence, rails & sqlite dependencies
#
gsub_file "#{name}.gemspec", /spec.license.+\n/, ''
gsub_file "#{name}.gemspec", /spec.add_dependency.+rails.+\n/, ''
gsub_file "#{name}.gemspec", /spec.add_development_dependency.+sqlite.+/, ''

#
# Add Workarea dependency
#
workarea_dependency = "  spec.add_dependency 'workarea', '~> 3.x'\n"
inject_into_file "#{name}.gemspec", workarea_dependency, before: /^end$/

#
# Rename gemspec
#
def source_paths
  [Dir.pwd] # this hack allows the copy_file method to work
end

inside do # root of plugin
  copy_file "#{name}.gemspec", "workarea-#{name}.gemspec"
  remove_file "#{name}.gemspec"
end

#
# Add null test cache store to test environment config
#
inject_into_file 'test/dummy/config/environments/test.rb', "\n\n  config.cache_store = :null_store", before: "\nend"

#
# Update Github path in Gemfile
#
gsub_file 'Gemfile', /https:\/\/github.com\//, 'git@github.com:'

#
# Add workarea to Gemfile
#
gem 'workarea', github: 'workarea-commerce/workarea'

#
# Setup test helper
#
remove_file 'test/test_helper.rb'
create_file 'test/test_helper.rb', <<~CODE
  # Configure Rails Environment
  ENV['RAILS_ENV'] = 'test'

  require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
  require 'rails/test_help'
  require 'workarea/test_help'

  # Filter out Minitest backtrace while allowing backtrace from other libraries
  # to be shown.
  Minitest.backtrace_filter = Minitest::BacktraceFilter.new
CODE

#
# Setup CI
#
create_file 'script/admin_ci', <<~CODE
#!/usr/bin/env bash

gem install bundler
bundle update

bin/rails app:workarea:test:admin
CODE

create_file 'script/core_ci', <<~CODE
#!/usr/bin/env bash

gem install bundler
bundle update

bin/rails app:workarea:test:core
CODE

create_file 'script/plugins_ci', <<~CODE
#!/usr/bin/env bash

gem install bundler
bundle update

bin/rails app:workarea:test:plugins
CODE

create_file 'script/storefront_ci', <<~CODE
#!/usr/bin/env bash

gem install bundler
bundle update

bin/rails app:workarea:test:storefront
CODE

`chmod a+x ../../script/*`

#
# Setup Rakefile
#
remove_file 'Rakefile'
create_file 'Rakefile', <<~CODE
  begin
    require 'bundler/setup'
  rescue LoadError
    puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
  end

  require 'rdoc/task'
  RDoc::Task.new(:rdoc) do |rdoc|
    rdoc.rdoc_dir = 'rdoc'
    rdoc.title    = '#{name.titleize}'
    rdoc.options << '--line-numbers'
    rdoc.rdoc_files.include('README.md')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end

  APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
  load 'rails/tasks/engine.rake'
  load 'rails/tasks/statistics.rake'
  load 'workarea/changelog.rake'

  require 'rake/testtask'
  Rake::TestTask.new(:test) do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.pattern = 'test/**/*_test.rb'
    t.verbose = false
  end
  task default: :test

  $LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
  require 'workarea/#{name}/version'

  desc "Release version \#{Workarea::#{camelized}::VERSION} of the gem"
  task :release do
    Rake::Task['workarea:changelog'].execute
    system 'git add CHANGELOG.md'
    system 'git commit -m "Update CHANGELOG"'
    system 'git push origin HEAD'

    system "git tag -a v\#{Workarea::#{camelized}::VERSION} -m 'Tagging \#{Workarea::#{camelized}::VERSION}'"
    system 'git push --tags'

    system "gem build workarea-#{name}.gemspec"
    system "gem push workarea-#{name}-\#{Workarea::#{camelized}::VERSION}.gem"
    system "rm workarea-#{name}-\#{Workarea::#{camelized}::VERSION}.gem"
  end

  desc 'Run the JavaScript tests'
  ENV['TEASPOON_RAILS_ENV'] = File.expand_path('../test/dummy/config/environment', __FILE__)
  task teaspoon: 'app:teaspoon'

  desc 'Start a server at http://localhost:3000/teaspoon for JavaScript tests'
  task :teaspoon_server do
    Dir.chdir("test/dummy")
    teaspoon_env = File.expand_path('../test/teaspoon_env.rb', __FILE__)
    system "RAILS_ENV=test TEASPOON_ENV=\#{teaspoon_env} rails s"
  end
CODE

#
# Remove default Rake task
#
remove_file "lib/tasks/#{name}_tasks.rake"

#
# Update .gitignore
#
append_to_file '.gitignore', <<~CODE
  .DS_Store
  .byebug_history
  .bundle/
  .sass-cache/
  Gemfile.lock
  pkg/
  test/dummy/tmp/
  test/dummy/public/
  log/*.log
  test/dummy/log/*.log
  test/dummy/db/*.sqlite3
  test/dummy/db/*.sqlite3-journal
  node_modules
  package.json
  yarn.lock
CODE

#
# Remove MIT License
#
remove_file 'MIT-LICENSE'

#
# Update README
#
remove_file 'README.md'
create_file 'README.md', <<~README
  Workarea #{name.titleize}
  ================================================================================

  #{name.titleize} plugin for the Workarea platform.

  Getting Started
  --------------------------------------------------------------------------------

  This gem contains a Rails engine that must be mounted onto a host Rails application.

  Then add the gem to your application's Gemfile specifying the source:

      # ...
      gem 'workarea-#{name}'
      # ...

  Update your application's bundle.

      cd path/to/application
      bundle

  Workarea Platform Documentation
  --------------------------------------------------------------------------------

  See [http://developer.workarea.com](http://developer.workarea.com) for Workarea platform documentation.

  Copyright & Licensing
  --------------------------------------------------------------------------------

  Copyright Workarea #{Time.now.year}. All rights reserved.

  For licensing, contact sales@workarea.com.
README
