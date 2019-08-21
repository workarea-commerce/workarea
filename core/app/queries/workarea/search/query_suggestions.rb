module Workarea
  module Search
    module QuerySuggestions
      def query_suggestions
        @query_suggestions ||=
          begin
            return [] unless response['suggest'].present?

            phrase = response['suggest']['spelling_correction'].first
            original_query = QueryString.new(params[:q])

            if phrase.present?
              phrase['options']
                .select { |o| o['collate_match'] }
                .map { |o| o['text'] }
                .reject { |o| QueryString.new(o).id == original_query.id }
                .take(3)
            else
              []
            end
          end
      end

      def should_use_suggestion?
        total.zero? && query_suggestions.any?
      end

      def query_suggestion_response
        @query_suggestion_response ||=
          begin
            new_query = self.class.new(q: query_suggestions.first).body
            self.class.document.new.search(new_query)
          end
      end

      def sanitized_query
        @sanitized_query ||= QueryString.new(params[:q]).sanitized
      end

      # TODO: for v4, rework query to remove dependency on ProductDisplayRules
      # Currently preventing non-product searches (i.e. content) from using
      # query suggestions without stubbing #product_display_query_clauses.
      def suggest
        {
          spelling_correction: {
            text: query_string.sanitized,
            phrase: {
              field: 'suggestion_content',
              direct_generator: [
                {
                  field: 'suggestion_content',
                  min_doc_freq: Workarea.config.search_suggestion_min_doc_freq
                }
              ],
              collate: {
                prune: true,
                query: {
                  bool: {
                    must: product_display_query_clauses + [
                      { match_phrase: { suggestion_content: '{{suggestion}}' } }
                    ]
                  }
                }.to_json
              }
            }
          }
        }
      end
    end
  end
end
