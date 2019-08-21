module Workarea
  module Search
    module AdminProductRulesPreview
      def product_display_query_clauses
        return [{ term: { type: 'product' } }] if params[:show_all]
        super
      end
    end
  end
end
