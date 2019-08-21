module Workarea
  module Search
    class AdminReleasables
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def query
        result = super
        result[:bool][:must] << { term: { releasable: true } }
        result
      end
    end
  end
end
