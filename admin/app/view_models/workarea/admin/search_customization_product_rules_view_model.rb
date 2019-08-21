module Workarea
  module Admin
    class SearchCustomizationProductRulesViewModel < ProductRulesPreviewViewModel
      # Fetches search results of products for product search. Extends
      # search class with {Search::AdminProductRulesPreview} to allow
      # overriding display rules.
      #
      # @return [Workarea::Search::ProductSearch]
      #   enumerable collection of the search results
      #
      def search
        @search ||= Search::ProductSearch.new(
          q: model.query,
          rules: model.product_rules.usable,
          page: options[:page] || 1,
          show_all: show_all?
        ).tap { |s| s.extend(Search::AdminProductRulesPreview) }
      end

      def display_results?
        true # With query we can always show preview even without rules
      end
    end
  end
end
