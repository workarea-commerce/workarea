module Workarea
  module Search
    class LuceneSyntaxValidator
      # Validate Lucene query syntax using Elasticsearch's `query_string` query.
      # Returns true if syntax is valid; false otherwise.
      def self.valid?(query)
        return true if query.blank?

        Storefront.current_index.search(
          query: {
            query_string: {
              query: query,
              fields: ['content.*']
            }
          },
          size: 0
        )

        true
      rescue ::Elasticsearch::Transport::Transport::ServerError,
             ::Elasticsearch::Transport::Transport::Errors::BadRequest
        false
      end
    end
  end
end
