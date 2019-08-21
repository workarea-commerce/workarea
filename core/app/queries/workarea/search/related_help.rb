module Workarea
  module Search
    # TODO remove related help in v4
    class RelatedHelp
      include Query
      include Pagination

      document Search::Help

      def query
        {
          more_like_this: {
            min_term_freq: 1,
            min_doc_freq: 1,
            fields: %w(name facets.category body),
            ids: Array(params[:ids]),
            like_text: params[:like_text]
          }
        }
      end

      def size
        Workarea.config.max_admin_related_help
      end

      def results
        @_results ||=
          if results_with_url_matching.blank?
             use_more_like_this? ? super : []
          elsif use_more_like_this?
            combine_url_matching_with(super)
          else
            []
          end
      end

      def results_with_url_matching
        return [] unless params[:for_url].present?
        Workarea::Help::Article.find_matching_url(params[:for_url])
      end

      def use_more_like_this?
        params[:like_text].present? || params[:ids].present?
      end

      private

      def combine_url_matching_with(results)
        max = Workarea.config.max_admin_related_help

        items = results_with_url_matching.first(max) + results.items
        items.uniq!

        PagedArray.from(items.first(max), 1, max, max)
      end
    end
  end
end
