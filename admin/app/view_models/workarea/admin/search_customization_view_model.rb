module Workarea
  module Admin
    class SearchCustomizationViewModel < ApplicationViewModel
      include CommentableViewModel
      include ContentableViewModel
      include FeaturedProductsViewModel

      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def insights
        @insights ||= Insights::SearchViewModel.wrap(model, options)
      end
    end
  end
end
