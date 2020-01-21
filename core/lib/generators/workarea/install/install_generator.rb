module Workarea
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    desc File.read(File.expand_path('../USAGE', __FILE__))

    def add_requires
      require_workarea = <<~CODE

        # Workarea must be required before other gems to ensure control over Rails.env
        # for running tests
        require 'workarea'

      CODE

      inject_into_file(
        'config/application.rb',
        require_workarea,
        before: 'Bundler.require(*Rails.groups)'
      )
    end

    def mount_routes
      route "mount Workarea::Core::Engine => '/'"
      route "mount Workarea::Admin::Engine => '/admin', as: 'admin'"
      route "mount Workarea::Api::Engine => '/api', as: 'api'" if Workarea::Plugin.installed?(:api)
      route "mount Workarea::Storefront::Engine => '/', as: 'storefront'"
    end

    def create_initializer
      template('initializer.rb.erb', 'config/initializers/workarea.rb')
    end

    def configure_sidekiq
      environment "require 'sidekiq/testing/inline'\n", env: 'development'
      environment '# Run Sidekiq tasks synchronously so that Sidekiq is not required in Development', env: 'development'
    end

    def update_test_helper
      inject_into_file(
        'test/test_helper.rb',
        "\nrequire 'workarea/test_help'", after: "require 'rails/test_help'"
      )
    end

    def add_seeds
      create_file 'db/seeds.rb', <<~CODE
        require 'workarea/seeds'
        Workarea::Seeds.run
      CODE
    end

    def remove_favicon
      remove_file 'public/favicon.ico'
    end

    def install_javascripts
      rake 'webpacker:install'
      rake 'webpacker:install:stimulus'
      rake 'webpacker:install:erb'

      remove_directory 'app/javascript/controllers'

      run 'yarn init -y'
      run 'yarn add workarea'

      %w(admin storefront).each do |side|
        create_file "app/javascripts/#{side}/controllers/index.js", <<~JS
        import Workarea, { #{side.camelize} } from "workarea"

        const App = require.context("#{side}/controllers", true, /_controller\.js$/)

        Workarea.load(#{side.camelize}.controllers)
        Workarea.load(App)
        JS
      end

      create_file 'config/webpack/loaders/ejs.js', <<~JS
        module.exports = {
          test: /\\.ejs$/,
          enforce: 'pre',
          exclude: /node_modules/,
          use: ['ejs-compiled-loader']
        }
      JS

      inject_into_file 'config/webpack/environment.js', "environment.loaders.prepend('ejs', ejs)\n", before: 'module.exports = environment'
      inject_into_file 'config/webpack/environment.js', "const ejs = require('./loaders/ejs')\n", after: "const { environment } = require('@rails/webpacker')"
    end

    private

    def app_name
      Rails.application.class.module_parent_name.underscore
    end
  end
end
