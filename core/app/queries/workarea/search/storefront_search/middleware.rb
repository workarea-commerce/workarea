module Workarea
  module Search
    class StorefrontSearch
      module Middleware
        extend ActiveSupport::Concern

        included do
          include I18n::DefaultUrlOptions
          include Workarea::Storefront::Engine.routes.url_helpers
          include Workarea::Storefront::NavigationHelper

          attr_reader :params, :customization
        end

        def initialize(params, customization)
          @params = params
          @customization = customization
        end

        def call(response)
          raise(NotImplementedError)
        end
      end
    end
  end
end
