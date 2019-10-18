module Workarea
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    desc File.read(File.expand_path('../USAGE', __FILE__))

    def add_requires
      require_workarea = <<~CODE

        # Workarea must be required before other gems to ensure control over Rails.env
        # for running tests
        require 'workarea/core'
        require 'workarea/admin'
        require 'workarea/storefront'

      CODE

      inject_into_file(
        'config/application.rb',
        require_workarea,
        before: 'Bundler.require(*Rails.groups)'
      )
    end

    def mount_routes
      route "mount Workarea::Storefront::Engine => '/', as: 'storefront'"
      route "mount Workarea::Admin::Engine => '/admin', as: 'admin'"
      route "mount Workarea::Api::Engine => '/api', as: 'api'" if Workarea::Plugin.installed?(:api)
      route "mount Workarea::Core::Engine => '/'"
    end

    def create_initializer
      template('initializer.rb.erb', 'config/initializers/workarea.rb')
    end

    def configure_sidekiq
      environment "require 'sidekiq/testing/inline'\n", env: 'development'
      environment '# Run Sidekiq tasks synchronously so that Sidekiq is not required in Development', env: 'development'
    end

    def configure_puma
      remove_file 'config/puma.rb'
      create_file 'config/puma.rb', <<~TEXT
        require 'workarea/configuration/puma'
        Workarea::Configuration::Puma.load(self)
      TEXT
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

    private

    def app_name
      Rails.application.class.parent_name.underscore
    end
  end
end
