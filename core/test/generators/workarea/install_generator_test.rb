require 'test_helper'
require 'generators/workarea/install/install_generator'

module Workarea
  class InstallGeneratorTest < GeneratorTest
    tests Workarea::InstallGenerator
    destination Dir.mktmpdir

    setup do
      prepare_destination

      FileUtils.mkdir_p("#{destination_root}/config/initializers")

      File.open "#{destination_root}/config/application.rb", 'w' do |file|
        file.write "Bundler.require(*Rails.groups)"
      end
      File.open "#{destination_root}/config/routes.rb", 'w' do |file|
        file.write "Rails.application.routes.draw do\n\nend"
      end

      FileUtils.mkdir("#{destination_root}/config/environments")

      File.open "#{destination_root}/config/environments/development.rb", 'w' do |file|
        file.write "Rails.application.configure do\n\nend"
      end

      FileUtils.mkdir("#{destination_root}/test")
      FileUtils.touch("#{destination_root}/test/test_helper.rb")

      FileUtils.mkdir("#{destination_root}/db")

      FileUtils.mkdir("#{destination_root}/public")
      FileUtils.touch("#{destination_root}/public/favicon.ico")

      run_generator
    end

    def test_requires
      assert_file 'config/application.rb' do |file|
        assert_match(%(require 'workarea'), file)
      end
    end

    def test_routes
      assert_file 'config/routes.rb' do |file|
        assert_match(%(mount Workarea::Storefront::Engine => '/', as: 'storefront'), file)
        assert_match(%(mount Workarea::Admin::Engine => '/admin', as: 'admin'), file)
        assert_match(%(mount Workarea::Core::Engine => '/'), file)
      end
    end

    def test_initializer
      assert_file 'config/initializers/workarea.rb' do |file|
        assert_match(%(config.site_name =), file)
        assert_match(%(config.host =), file)
      end
    end

    def test_sidekiq_inline
      assert_file 'config/environments/development.rb' do |file|
        assert_match(%(require 'sidekiq/testing/inline'), file)
      end
    end

    def test_test_helper
      assert_file 'test/test_helper.rb' do |file|
        assert_match(%(require 'workarea/test_help'), file)
      end
    end

    def test_test_helper
      assert_file 'db/seeds.rb' do |file|
        assert_match(%(require 'workarea/seeds'), file)
      end
    end

    def test_favicon
      assert_no_file 'public/favicon.ico'
    end

    def test_development_mailer_port
      assert_file 'config/environments/development.rb' do |file|
        assert_match(%(config.action_mailer.default_url_options = { port: 3000 }), file)
      end
    end
  end
end
