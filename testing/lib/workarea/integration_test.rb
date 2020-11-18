module Workarea
  class IntegrationTest < ActionDispatch::IntegrationTest
    module Configuration
      extend ActiveSupport::Concern
      include TestCase::Setup
      include TestCase::Teardown

      included do
        setup do
          default_url_options[:locale] = nil
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

    module Locales
      def set_locales(*)
        super

        Workarea::Elasticsearch::Document.all.each(&:create_indexes!)
        Workarea::Search::Storefront.ensure_dynamic_mappings
      end
    end

    extend TestCase::Decoration
    include TestCase::Configuration
    include TestCase::Workers
    include TestCase::SearchIndexing
    include TestCase::Mail
    include TestCase::RunnerLocation
    include TestCase::Locales
    include TestCase::S3
    include TestCase::Encryption
    include TestCase::Geocoder
    include Factories
    include Configuration
    include Locales
  end
end
