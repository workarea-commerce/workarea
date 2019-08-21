module Workarea
  module Admin
    class CategoryViewModel < ApplicationViewModel
      include CommentableViewModel
      include ContentableViewModel
      include FeaturedProductsViewModel

      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def breadcrumbs
        @breadcrumbs ||= Navigation::Breadcrumbs.new(model)
      end

      def breadcrumb_string
        options.fetch(:source, {})[:breadcrumbs] || breadcrumbs.join(' > ')
      end

      def insights
        @insights ||= Insights::CategoryViewModel.wrap(model, options)
      end

      def sort_options
        Search::CategoryBrowse
          .available_sorts
          .map { |s| [s.name, s.slug] }
          .reject { |s| s.last == :relevance }
      end

      # Returns an array of arrays that each contain a human readable value and
      # and a value that is used in a category's rule :field field.
      #
      # @return [Array]
      #
      def rule_fields
        Search::Storefront::Product.current_product_rule_fields.to_a.map do |field|
          [field.first.to_s.titleize, field.last]
        end
      end

      def products
        @products ||= Storefront::CategoryViewModel.new(model).products
      end

      def price_facet
        @price_facet ||= range_facets['price'] || []
      end

      def products_count
        @products_count ||= model.products.count
      end
    end
  end
end
