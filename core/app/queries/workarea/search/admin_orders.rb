module Workarea
  module Search
    class AdminOrders
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def self.available_sorts
        Sort::Collection.new(
          Sort.relevance,
          Sort.modified,
          Sort.name_asc,
          Sort.total,
          Sort.newest_placed,
          Sort.oldest_placed
        )
      end

      def initialize(params = {})
        super(params.merge(type: 'order'))
      end

      def facets
        super + [
          TermsFacet.new(self, 'order_status'),
          TermsFacet.new(self, 'payment_status'),
          TermsFacet.new(self, 'fulfillment_status'),
          TermsFacet.new(self, 'traffic_referrer')
        ]
      end

      def filters
        [
          DateFilter.new(self, 'placed_at', :gte),
          DateFilter.new(self, 'placed_at', :lte),
          RangeFilter.new(self, 'total_price', :gte),
          RangeFilter.new(self, 'total_price', :lt)
        ]
      end

      def current_sort
        AdminOrders.available_sorts.find(params[:sort])
      end
    end
  end
end
