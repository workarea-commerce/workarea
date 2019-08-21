module Workarea
  module Search
    class AdminCategories
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def initialize(params = {})
        super(params.merge(type: 'category'))
      end

      def facets
        super + [TermsFacet.new(self, 'issues')]
      end
    end
  end
end
