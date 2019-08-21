module Workarea
  module Search
    class AdminFulfillmentSkus
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def initialize(params = {})
        super(params.merge(type: 'fulfillment_sku'))
      end

      def facets
        super + [TermsFacet.new(self, 'policy')]
      end
    end
  end
end
