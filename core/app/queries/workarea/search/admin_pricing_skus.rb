module Workarea
  module Search
    class AdminPricingSkus
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def initialize(params = {})
        super(params.merge(type: 'pricing_sku'))
      end
    end
  end
end
