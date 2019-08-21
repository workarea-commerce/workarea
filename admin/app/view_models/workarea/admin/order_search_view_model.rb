module Workarea
  module Admin
    class OrderSearchViewModel < SearchViewModel
      def sorts
        Search::AdminOrders.available_sorts.map { |s| [s.name, s.slug] }
      end

      def sort
        return super if options[:sort].blank?
        Search::AdminOrders.available_sorts.find(options[:sort])
      end
    end
  end
end
