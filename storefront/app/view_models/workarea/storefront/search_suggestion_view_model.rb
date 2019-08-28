module Workarea
  module Storefront
    class SearchSuggestionViewModel < ApplicationViewModel
      include I18n::DefaultUrlOptions
      include Storefront::Engine.routes.url_helpers
      include Search::LoadProductResults
      include AnalyticsHelper

      def to_h
        {
          value: name,
          type: type,
          image: image,
          url: url,
          analytics: analytics
        }
      end

      def source
        model['_source']
      end

      def name
        source['content']['name']
      end

      def type
        t("workarea.storefront.searches.#{suggestion_type.pluralize}")
      end

      # TODO this can be simplified in v4, when we can be confident the index
      # will always have relative paths stored for image cache.
      def image
        return if source['cache']['image'].blank?

        image_url = URI.parse(source['cache']['image'])

        if asset_host.present?
          image_url.scheme = asset_host.scheme
          image_url.host = asset_host.host
        end

        image_url.to_s
      end

      def asset_host
        URI.parse(Rails.application.config.action_controller.asset_host)
      rescue URI::InvalidURIError
        nil
      end

      def suggestion_type
        source['type']
      end

      def analytics
        return unless suggestion_type == 'product'

        product_analytics_data(product)
      end

      def product
        @product ||=
          begin
            loaded = load_model_from(model)

            Storefront::ProductViewModel.wrap(
              loaded[:model],
              loaded.slice(:inventory, :pricing)
            )
          end
      end

      def url
        if suggestion_type == 'product'
          product_path(product)
        elsif suggestion_type == 'search'
          search_path(q: name)
        elsif suggestion_type == 'category'
          category_path(source['slug'])
        elsif suggestion_type == 'page'
          page_path(source['slug'])
        end
      end
    end
  end
end
