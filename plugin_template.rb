=begin
To generate a new plugin, run:

rails plugin new path/to/my_plugin \
  --template=https://raw.githubusercontent.com/workarea-commerce/workarea/master/plugin_template.rb \
  --full \
  --skip-spring \
  --skip-active-record \
  --skip-action-cable \
  --skip-puma \
  --skip-coffee \
  --skip-turbolinks \
  --skip-bootsnap \
  --skip-yarn \
  --skip-webpack-install
=end

#
# Namespace plugin under Workarea
#
remove_file "lib/#{name}.rb"
create_file "lib/workarea/#{name}.rb", <<~CODE
  require 'workarea'
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
      VERSION = "1.0.0.pre".freeze
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

create_file "app/assets/images/workarea/admin/#{name}/.keep"
create_file "app/assets/images/workarea/storefront/#{name}/.keep"
remove_dir "app/assets/images/#{name}"

create_file "app/assets/javascripts/workarea/admin/#{name}/.keep"
create_file "app/assets/javascripts/workarea/storefront/#{name}/.keep"
remove_dir "app/assets/javascripts/#{name}"

create_file "app/assets/stylesheets/workarea/admin/#{name}/.keep"
create_file "app/assets/stylesheets/workarea/storefront/#{name}/.keep"
remove_dir "app/assets/stylesheets/#{name}"

#
# Selectively require rails gems, removing ActiveRecord
#
rails_requires = <<~CODE
  require 'action_controller/railtie'
  require 'action_view/railtie'
  require 'action_mailer/railtie'
  require 'rails/test_unit/railtie'
  require 'sprockets/railtie'
CODE

gsub_file 'bin/rails', /.+rails\/all.+/, rails_requires
gsub_file 'test/dummy/config/application.rb', /.+rails\/all.+/, rails_requires

#
# Require Workarea in dummy app configuration, before plugin
#
require_workarea = <<~CODE
  # Workarea must be required before other gems to ensure control over Rails.env
  # for running tests
  require 'workarea'
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
gsub_file "#{name}.gemspec", /(#{camelized}::VERSION)/, 'Workarea::\\1'
gsub_file "#{name}.gemspec", /(spec\.name\s+).+/, "\\1= \"workarea-#{name}\""

#
# Use the git file list for plugin's manifest
#
gsub_file "#{name}.gemspec", /(spec.files[\s=]+).*/, '\\1`git ls-files`.split("\\n")'

#
# Modify licence, rails & sqlite dependencies
#
gsub_file "#{name}.gemspec", /(spec.license[^'"]+['"])MIT/, '\\1Business Software License'
gsub_file "#{name}.gemspec", /spec.add_dependency.+rails.+/, ''
gsub_file "#{name}.gemspec", /spec.add_development_dependency.+sqlite.+/, ''

#
# Add Workarea dependency
#
workarea_dependency = "  spec.add_dependency 'workarea', '~> 3.x'\n"
inject_into_file "#{name}.gemspec", workarea_dependency, before: /^end$/

#
# Cleanup whitespace
#
gsub_file "#{name}.gemspec", /^\s*\n/, "\n\n"
gsub_file "#{name}.gemspec", /^\n\n/, "\n"

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

    system "git tag -a v\#{Workarea::#{camelized}::VERSION} -m 'Tagging \#{Workarea::#{camelized}::VERSION}'"
    system 'git push origin HEAD --follow-tags'

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
  yarn.lock
  yarn-error.log
  package-lock.json
CODE

#
# Replace License
#
remove_file 'MIT-LICENSE'
create_file 'LICENSE', <<~CODE
WebLinc
Business Source License

Licensor: WebLinc Corporation, 22 S. 3rd Street, 2nd Floor, Philadelphia PA 19106

Licensed Work: Workarea Commerce Platform
               The Licensed Work is (c) 2019 WebLinc Corporation

Additional Use Grant:
                      You may make production use of the Licensed Work without an additional license agreement with WebLinc so long as you do not use the Licensed Work for a Commerce Service.

                      A "Commerce Service" is a commercial offering that allows third parties (other than your employees and contractors) to access the functionality of the Licensed Work by creating or managing commerce functionality, the products, taxonomy, assets and/or content of which are controlled by such third parties.

                      For information about obtaining an additional license agreement with WebLinc, contact licensing@workarea.com.

Change Date: 2019-08-20

Change License: Version 2.0 or later of the GNU General Public License as published by the Free Software Foundation

Terms

The Licensor hereby grants you the right to copy, modify, create derivative works, redistribute, and make non-production use of the Licensed Work. The Licensor may make an Additional Use Grant, above, permitting limited production use.

Effective on the Change Date, or the fourth anniversary of the first publicly available distribution of a specific version of the Licensed Work under this License, whichever comes first, the Licensor hereby grants you rights under the terms of the Change License, and the rights granted in the paragraph above terminate.

If your use of the Licensed Work does not comply with the requirements currently in effect as described in this License, you must purchase a commercial license from the Licensor, its affiliated entities, or authorized resellers, or you must refrain from using the Licensed Work.

All copies of the original and modified Licensed Work, and derivative works of the Licensed Work, are subject to this License. This License applies separately for each version of the Licensed Work and the Change Date may vary for each version of the Licensed Work released by Licensor.

You must conspicuously display this License on each original or modified copy of the Licensed Work. If you receive the Licensed Work in original or modified form from a third party, the terms and conditions set forth in this License apply to your use of that work.

Any use of the Licensed Work in violation of this License will automatically terminate your rights under this License for the current and all other versions of the Licensed Work.

This License does not grant you any right in any trademark or logo of Licensor or its affiliates (provided that you may use a trademark or logo of Licensor as expressly required by this License). TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE LICENSED WORK IS PROVIDED ON AN "AS IS" BASIS. LICENSOR HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE. MariaDB hereby grants you permission to use this License’s text to license your works and to refer to it using the trademark "Business Source License" as long as you comply with the Covenants of Licensor below.

Covenants of Licensor
In consideration of the right to use this License’s text and the "Business Source License" name and trademark, Licensor covenants to MariaDB, and to all other recipients of the licensed work to be provided by Licensor:

To specify as the Change License the GPL Version 2.0 or any later version, or a license that is compatible with GPL Version 2.0 or a later version, where "compatible" means that software provided under the Change License can be included in a program with software provided under GPL Version 2.0 or a later version. Licensor may specify additional Change Licenses without limitation.

To either: (a) specify an additional grant of rights to use that does not impose any additional restriction on the right granted in this License, as the Additional Use Grant; or (b) insert the text "None."

To specify a Change Date.

Not to modify this License in any other way.

Notice
The Business Source License (this document, or the "License") is not an Open Source license. However, the Licensed Work will eventually be made available under an Open Source License, as stated in this License.

For more information on the use of the Business Source License generally, please visit the Adopting and Developing Business Source License FAQ.

License text copyright (c) 2017 MariaDB Corporation Ab, All Rights Reserved. "Business Source License" is a trademark of MariaDB Corporation Ab.
CODE

#
# Update README
#
remove_file 'README.md'
create_file 'README.md', <<~README
  Workarea #{name.titleize}
  ================================================================================

  #{name.titleize} plugin for the Workarea platform.

  Overview
  --------------------------------------------------------------------------------

  1. TODO

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

  Features
  --------------------------------------------------------------------------------

  ### TODO

  Workarea Platform Documentation
  --------------------------------------------------------------------------------

  See [https://developer.workarea.com](https://developer.workarea.com) for Workarea platform documentation.

  License
  --------------------------------------------------------------------------------

  Workarea #{name.titleize} is released under the [Business Software License](LICENSE)
README
