module Workarea
  module Search
    class ProductSearch
      include Query
      include Facets
      include ProductDisplayRules
      include ProductRulesFiltering
      include QuerySuggestions
      include Pagination
      include LoadProductResults

      document Search::Storefront

      PASSES = [0, 1, 2]

      def self.available_sorts
        Sort::Collection.new(
          Sort.relevance,
          Sort.top_sellers,
          Sort.popularity,
          Sort.newest,
          Sort.price_asc,
          Sort.price_desc
        )
      end

      def query
        result = {
          bool: {
            must: product_display_query_clauses + product_rules_query_clauses
          }
        }

        if params[:q].present? && !query_string.all?
          result[:bool][:must] << query_string_clause
        end

        result
      end

      def aggregations
        facets.map(&:aggregation).reduce(&:merge)
      end

      def post_filter
        {
          bool: {
            must: facets.map(&:post_filter_clause).reject(&:blank?)
          }
        }
      end

      def pass
        params[:pass] || PASSES.first
      end

      def customization
        return @customization if defined?(@customization)

        result = Customization.find_by_query(params[:q])
        @customization = result.active? ? result : Customization.new
      end

      def boosts
        result = Search::Settings.current.boosts.presence ||
                  Workarea.config.default_search_boosts

        result.with_indifferent_access
      end

      def boosted_fields
        text_fields = pass > PASSES.first ? boosts : boosts.except(:description)
        text_fields.map do |name, boost|
          "content.#{name}^#{boost || 1}"
        end
      end

      def default_operator
        pass > PASSES.second ? 'OR' : 'AND'
      end

      def sort
        result = []

        if selected_sort.field.present?
          result << {
            selected_sort.field => {
              order: selected_sort.direction,
              missing: '_last',
              unmapped_type: 'float'
            }
          }
        else
          result << {
            "sorts.#{query_string.id}" => {
              order: 'asc',
              missing: '_last',
              unmapped_type: 'float'
            }
          }
        end

        result << displayable_when_out_of_stock_sort_clause
        result << { _score: :desc }
        result << {
          'sorts.orders_score': {
            order: 'desc',
            missing: '_last',
            unmapped_type: 'float'
          }
        }

        result
      end

      def sorts
        Array(params[:sort])
      end

      def selected_sort
        self.class.available_sorts.find(params[:sort])
      end

      private

      def query_string_clause
        result = {
          bool: {
            minimum_number_should_match: 1,
            should: [
              {
                terms: {
                  'keywords.catalog_id': customization.product_ids.map(&:downcase)
                }
              },
              {
                function_score: {
                  query: {
                    bool: {
                      should: exact_match_query_clauses + [general_search_clause]
                    }
                  },
                  functions: exact_match_scoring_functions + [popularity_boost_function],
                  score_mode: 'sum',
                  boost_mode: 'sum'
                }
              }
            ]
          }
        }

        # Enforce dramatic name match boosting
        if query_string.phrase?
          result[:bool][:should] << {
            match: {
              'content.name': {
                query: query_string.sanitized,
                type: 'phrase',
                boost: Workarea.config.search_name_phrase_match_boost
              }
            }
          }
        end

        result
      end

      def general_search_clause
        if customization.rewrite?
          {
            query_string: {
              query: customization.rewrite,
              fields: boosted_fields,
              use_dis_max: true,
              default_operator: default_operator,
              tie_breaker: Workarea.config.search_dismax_tie_breaker
            }
          }
        else
          {
            multi_match: {
              query: query_string.sanitized,
              type: 'cross_fields',
              fields: boosted_fields,
              operator: default_operator,
              tie_breaker: Workarea.config.search_dismax_tie_breaker
            }
          }
        end
      end

      def exact_match_query_clauses
        [
          { term: { 'keywords.catalog_id': query_string.sanitized.downcase } },
          { term: { 'keywords.name': query_string.sanitized.downcase } },
          { term: { 'keywords.sku': query_string.sanitized.downcase } }
        ]
      end

      def exact_match_scoring_functions
        %w(keywords.name keywords.catalog_id keywords.sku).map do |field|
          {
            filter: { term: { field => query_string.sanitized.downcase } },
            weight: Workarea.config.search_exact_match_score
          }
        end
      end

      def popularity_boost_function
        {
          field_value_factor: {
            field: 'sorts.views_score',
            modifier: 'log1p',
            factor: Search::Settings.current.views_factor,
            missing: 0
          }
        }
      end
    end
  end
end
