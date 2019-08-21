module Workarea
  module Storefront
    module ProductBrowsing
      extend ActiveSupport::Concern
      include Pagination

      def product_browse_cache_key
        @product_browse_cache_key ||= options
          .except(:user)
          .to_a
          .sort
          .flatten
          .reject(&:blank?)
          .join('/')
      end

      def has_filters?
        facets.any?(&:selected?)
      end

      def filters
        search_query.facets.reduce({}) do |memo, facet|
          memo[facet.system_name] = facet.selections if facet.selected?
          memo
        end
      end

      def facets
        search_query.facets.reject(&:useless?)
      end
    end
  end
end
