module Workarea
  module Search
    class StorefrontSearch
      class ExactMatches
        include StorefrontSearch::Middleware

        def call(response)
          exact_match = find_exact_match(response)

          if response.customization.new_record? && !response.has_filters? && exact_match.present?
            response.redirect = product_path(exact_match)
          else
            yield
          end
        end

        def find_exact_match(response)
          exact_matches = find_exact_matches(response)

          # Depending on boost settings and configs, sometimes scores can exceed
          # the exact match threshold. Only render an exact match if it's a single match.
          return unless exact_matches.one?

          Elasticsearch::Serializer.deserialize(exact_matches.first['_source'])
        end

        def find_exact_matches(response)
          hits = response.query.response.dig('hits', 'hits')
          hits.select { |h| h['_score'] >= Workarea.config.search_exact_match_score }
        end
      end
    end
  end
end
