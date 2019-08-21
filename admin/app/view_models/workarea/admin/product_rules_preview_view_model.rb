module Workarea
  module Admin
    class ProductRulesPreviewViewModel < ApplicationViewModel
      delegate :total, :page, :per_page, to: :search

      def self.wrap(model, options = {})
        return model.map { |m| wrap(m, options) } if model.is_a?(Enumerable)

        view_model_class = [
          "Workarea::Admin",
          "#{model.class.model_name.param_key.camelize}ProductRulesViewModel"
        ].join('::')

        view_model_class.constantize.new(model, options)
      rescue
        new(model, options)
      end

      # Fetches search results of products for category. Extends
      # search class with {Search::AdminProductRulesPreview} to allow
      # overriding display rules.
      #
      # @return [Workarea::Search::CategoryBrowse]
      #   enumerable collection of the search results
      #
      def search
        @search ||= Search::CategoryBrowse.new(
          rules: model.product_rules.usable,
          sort: model.default_sort,
          page: options[:page] || 1,
          show_all: show_all?
        ).tap { |s| s.extend(Search::AdminProductRulesPreview) }
      end

      # Provides all products found from search results
      #
      # @return [Workarea::PagedArray<Workarea::Admin::ProductViewModel>]
      #
      def results
        @results ||= PagedArray.from(
          search.results.map do |r|
            Admin::ProductViewModel.new(r[:model], inventory: r[:inventory])
          end,
          search.page,
          search.per_page,
          search.total
        )
      end

      def show_all?
        options[:show_all].to_s =~ /true/
      end

      def display_results?
        model.product_rules.usable.present?
      end

      def base_query
        return unless model.respond_to?(:query)
        model.query
      end
    end
  end
end
