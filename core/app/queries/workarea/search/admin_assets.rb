module Workarea
  module Search
    class AdminAssets
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def initialize(params = {})
        super(params.merge(type: 'asset'))
      end

      def facets
        super + [
          TermsFacet.new(self, 'file_type'),
          TermsFacet.new(self, 'image_dimensions')
        ]
      end
    end
  end
end
