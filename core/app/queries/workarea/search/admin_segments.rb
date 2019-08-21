module Workarea
  module Search
    class AdminSegments
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def initialize(params = {})
        super(params.merge(type: 'segment'))
      end
    end
  end
end
