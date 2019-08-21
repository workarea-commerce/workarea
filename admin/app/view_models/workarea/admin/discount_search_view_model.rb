module Workarea
  module Admin
    class DiscountSearchViewModel < SearchViewModel
      def sort
        if options[:sort] == Sort.redemptions.to_s
          Sort.redemptions.to_s
        else
          super
        end
      end

      def sorts
        super + [Sort.redemptions.to_a]
      end
    end
  end
end
