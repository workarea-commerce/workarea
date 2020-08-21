module Workarea
  module Search
    class AdminShippingSkus
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def initialize(params = {})
        super(params.merge(type: 'shipping_sku'))
      end
    end
  end
end
