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

      def default_admin_sort
        [{ _score: :desc }, { updated_at: :desc }]
      end
    end
  end
end
