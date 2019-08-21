module Workarea
  module Storefront
    module PaginationHelper
      def pagination_path_for(page: 1)
        new_query_string_params = request.query_parameters.merge(page: page)
        "#{request.path}?#{new_query_string_params.to_query}"
      end

      def pagination_data(collection)
        {
          currentPage: collection.current_page,
          lastPage: collection.last_page?,
          nextPageUrl: pagination_path_for(page: collection.current_page + 1)
        }.to_json
      end

      def show_pagination?(collection)
        collection.total_pages > 1 && !collection.last_page?
      end
    end
  end
end
