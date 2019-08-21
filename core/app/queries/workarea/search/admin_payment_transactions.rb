module Workarea
  module Search
    class AdminPaymentTransactions
      include Query
      include AdminIndexSearch
      include AdminSorting
      include Pagination

      document Search::Admin

      def initialize(params = {})
        super(params.merge(type: 'transaction'))
      end

      def facets
        super + [
          TermsFacet.new(self, 'auth_status'),
          TermsFacet.new(self, 'tender_type'),
          TermsFacet.new(self, 'transaction')
        ]
      end
    end
  end
end
