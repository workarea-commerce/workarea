module Workarea
  class IntegrationTest < ActionDispatch::IntegrationTest
    module Configuration
      extend ActiveSupport::Concern

      included do
        setup do
          Mongoid.truncate!
          Workarea.redis.flushdb
          default_url_options[:locale] = nil
        end

        teardown do
          travel_back
        end
      end

      def set_current_user(user)
        Workarea::ApplicationController.subclasses.each do |klass|
          if klass.method_defined?(:current_user)
            klass.any_instance.stubs(:current_user).returns(user)
          end
        end
      end

      def set_current_admin(user)
        Workarea::ApplicationController.subclasses.each do |klass|
          if klass.method_defined?(:current_admin)
            klass.any_instance.stubs(:current_admin).returns(user)
          end
        end
      end
    end

    extend TestCase::Decoration
    include TestCase::Workers
    include TestCase::SearchIndexing
    include TestCase::Mail
    include TestCase::RunnerLocation
    include TestCase::Locales
    include TestCase::S3
    include Factories
    include Configuration
  end
end
