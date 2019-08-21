module Workarea
  module Search
    module ProductRulesFiltering
      def product_rule_filters
        @product_rule_filters ||= ProductRules.new(params[:rules]).to_a
      end

      def product_rules_query_clauses
        return [] if product_rule_filters.blank?
        product_rule_filters
      end
    end
  end
end
