module Workarea
  module Search
    class AdminProducts
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def initialize(params = {})
        super(params.merge(type: 'product'))
      end

      def facets
        super + current_terms_facets + current_range_facets + product_facets
      end

      def current_terms_facets
        Settings.current.terms_facets.map do |name|
          TermsFacet.new(self, name)
        end
      end

      def current_range_facets
        Settings.current.range_facets.keys.map do |name|
          RangeFacet.new(self, name, Settings.current.range_facets[name])
        end
      end

      def product_facets
        [
          TermsFacet.new(self, 'issues'),
          TermsFacet.new(self, 'template')
        ]
      end
    end
  end
end
