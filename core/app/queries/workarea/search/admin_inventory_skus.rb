module Workarea
  module Search
    class AdminInventorySkus
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def initialize(params = {})
        super(params.merge(type: 'inventory_sku'))
      end

      def facets
        super + [TermsFacet.new(self, 'policy')]
      end
    end
  end
end
