module Workarea
  module Admin
    class UserSearchViewModel < SearchViewModel
      def sort
        model.class.available_sorts.detect { |s| s.to_s == options[:sort] } || super
      end

      def sorts
        super + model.class.available_sorts.map(&:to_a)
      end
    end
  end
end
