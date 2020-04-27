module Workarea
  module Storefront
    class CategoryViewModel < ApplicationViewModel
      include DisplayContent
      include ProductBrowsing

      def breadcrumbs
        @breadcrumbs ||= Navigation::Breadcrumbs.new(model)
      end

      def cache_key
        @cache_key ||= "#{model.cache_key}/#{product_browse_cache_key}"
      end

      def browser_title
        if content.browser_title.present?
          content.browser_title
        else
          breadcrumbs.join(' - ')
        end
      end

      #
      # Products
      #
      #

      def search_query
        @search_query ||= Search::CategoryBrowse.new(
          options.except(:per_page).merge(
            category_ids: [model.id],
            rules: model.product_rules.usable,
            terms_facets: terms_facets - %w(category),
            range_facets: range_facets,
            sort: current_sorts
          )
        )
      end

      def products
        return @products if defined?(@products)

        view_models = search_query.results.map do |result|
          ProductViewModel.wrap(
            result[:model],
            result
              .merge(options)
              .merge(product_breadcrumb_params)
              .merge(facets: terms_facets)
          )
        end

        @products = PagedArray.from(view_models, page, per_page, total)
      end

      def product_breadcrumb_params
        { via: breadcrumbs.to_global_id }
      end

      #
      # Sorting
      #
      #

      def sort
        current_sorts.first
      end

      def sorts
        @sorts ||=
          begin
            tmp = Search::CategoryBrowse.available_sorts.reject do |sort|
              sort.slug == :relevance
            end

            tmp.map! { |s| [s.name, s.slug] }

            if model.featured_products?
              tmp.unshift(
                [I18n.t('workarea.storefront.products.featured'), :featured]
              )
            end

            tmp
          end
      end

      private

      def terms_facets
        model.terms_facets.presence ||
          Search::Storefront::Product.current_terms_facets
      end

      def range_facets
        model.range_facets.presence || Search::Settings.current.range_facets
      end

      def current_sorts
        @current_sorts ||=
          if invalid_sort? && model.featured_products?
            [:featured, model.default_sort]
          elsif invalid_sort?
            [model.default_sort]
          else
            [options[:sort]]
          end
      end

      # A blank options[:sort] counts as an invalid sort
      def invalid_sort?
        Search::CategoryBrowse
          .available_sorts
          .map(&:to_s)
          .exclude?(options[:sort])
      end
    end
  end
end
