module Workarea
  module Search
    class Categorization
      include Query
      include CategorizationFiltering

      document Search::Storefront

      def query
        { bool: { must: category_query_clauses } }
      end
    end
  end
end
