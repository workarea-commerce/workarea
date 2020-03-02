module Workarea
  module Storefront
    class SearchViewModel < ApplicationViewModel
      include Pagination
      include ProductBrowsing
      include SearchContent
      include SearchCustomizationContent

      def search_query
        query
      end

      def products
        @products ||=
          begin
            view_models = query.results.map do |result|
              ProductViewModel.wrap(
                result[:model],
                result.merge(options).merge(product_breadcrumb_params).merge(params)
              )
            end

            PagedArray.from(view_models, page, per_page, total)
          end
      end

      def product_breadcrumb_params
        { via: Navigation::SearchResults.new(search_query.params).to_gid_param }
      end

      def query_suggestions
        @query_suggestions ||=
          begin
            all = Recommendation::Searches.find(options[:q]) +
              model.query_suggestions

            all.uniq.take(3)
          end
      end

      def sort
        query.class.available_sorts.find(options[:sort])
      end

      def sorts
        query.class.available_sorts.map { |s| [s.name, s.slug] }
      end
    end
  end
end
