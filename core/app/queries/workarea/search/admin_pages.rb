module Workarea
  module Search
    class AdminPages
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def initialize(params = {})
        super(params.merge(type: 'content_page'))
      end
    end
  end
end
