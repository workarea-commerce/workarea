module Workarea
  module Search
    class ProductRules
      RULE_OPERATOR_MAP = {
        'greater_than' => :gt,
        'greater_than_or_equal' => :gte,
        'less_than' => :lt,
        'less_than_or_equal' => :lte
      }

      attr_reader :rules, :ignore_category_ids

      def initialize(rules, ignore_category_ids: [])
        @rules = rules || []

        # Used to track which category rules are already included to avoid an
        # infinite recursion.
        @ignore_category_ids = ignore_category_ids
      end

      # Processes category rules into filters to be used
      # by Elasticsearch.
      #
      # @return [Array<Hash>]
      #
      def to_a
        @filters ||= rules.inject([]) do |memo, rule|
          if rule.category?
            memo.push(*category_clauses_for(rule))
          elsif rule.search?
            memo.push(*search_clauses_for(rule))
          elsif rule.product_exclusion?
            memo.push(product_exclusion_clause_for(rule))
          elsif rule.equality?
            memo.push(*equality_clauses_for(rule))
          elsif rule.inequality?
            memo.push(bool: { must_not: equality_clauses_for(rule) })
          elsif rule.comparison?
            memo.push(*comparison_clauses_for(rule))
          end

          memo
        end.uniq
      end

      private

      def search_clauses_for(rule)
        [{ query_string: { query: rule.value } }]
      end

      def equality_clauses_for(rule)
        if rule.sale?
          [{ term: { rule.field => rule.true? } }]
        else
          [{ terms: { rule.field => rule.terms } }]
        end
      end

      def category_clauses_for(rule)
        ids = rule.terms.map(&:to_s) - ignore_category_ids.map(&:to_s)
        return [] unless ids.any?

        if rule.operator == 'not_equal'
          [{ bool: { must_not: combined_category_rules(ids) } }]
        else
          [{ bool: { should: combined_category_rules(ids) } }]
        end
      end

      def combined_category_rules(ids)
        Catalog::Category.any_in(id: ids).flat_map do |category|
          featured_product_clauses = [
            { term: { 'facets.category_id' => category.id.to_s } }
          ]

          rules_clauses = ProductRules
                            .new(
                              category.product_rules,
                              ignore_category_ids: ids + ignore_category_ids
                            )
                            .to_a

          if rules_clauses.blank?
            featured_product_clauses
          else
            [
              {
                bool: {
                  should: featured_product_clauses +
                            [{ bool: { must: rules_clauses }}]
                }
              }
            ]
          end
        end
      end

      def comparison_clauses_for(rule)
        [
          {
            range: {
              rule.field => { RULE_OPERATOR_MAP[rule.operator] => rule.value }
            }
          }
        ]
      end

      def product_exclusion_clause_for(rule)
        {
          bool: {
            must_not: {
              terms: {
                'keywords.catalog_id' => rule.terms.map(&:downcase)
              }
            }
          }
        }
      end
    end
  end
end
