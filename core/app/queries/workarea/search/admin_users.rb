module Workarea
  module Search
    class AdminUsers
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def self.available_sorts
        Sort::Collection.new(
          Sort.most_spent,
          Sort.most_orders,
          Sort.average_order_value
        )
      end

      def initialize(params = {})
        super(params.merge(type: 'user'))
      end

      def facets
        super + [TermsFacet.new(self, 'role')]
      end

      def sort
        Array.wrap(super).tap do |sort|
          current_sort =
            self.class.available_sorts.detect { |s| s.to_s == params[:sort] }

          if current_sort.present? && current_sort.field.present?
            sort.prepend(current_sort.field => current_sort.direction)
          end
        end
      end
    end
  end
end
