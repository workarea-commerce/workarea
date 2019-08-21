module Workarea
  module Search
    class AdminDiscounts
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def initialize(params = {})
        super(params.merge(type: 'discount'))
      end

      def facets
        super + [TermsFacet.new(self, 'discount_type')]
      end

      def sort
        result = super || []

        if params[:sort] == Sort.redemptions.to_s
          result.prepend(Sort.redemptions.field => Sort.redemptions.direction)
        end

        result
      end
    end
  end
end
