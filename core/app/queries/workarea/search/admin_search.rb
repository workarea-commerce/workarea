module Workarea
  module Search
    class AdminSearch
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def self.available_sorts
        AdminSorting.available_sorts
      end
    end
  end
end
