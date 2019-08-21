module Workarea
  module Admin
    module ProductRulesHelper
      def product_rule_types_options
        Search::Storefront::Product.current_product_rule_fields.keys.map do |key|
          translated = t(
            "workarea.admin.fields.#{key}",
            default: key.to_s.humanize
          )

          [translated.downcase, key]
        end
      end

      def product_rule_operators
        ProductRule::OPERATORS.map { |o| [o.humanize.downcase, o] }
      end

      def category_rule_names_for(rule)
        Catalog::Category
          .any_in(id: rule.terms)
          .map(&:name)
          .join(', ')
      end

      def exclude_products_rule_names_for(rule)
        Catalog::Product
          .any_in(id: rule.terms)
          .map(&:name)
          .join(', ')
      end

      def render_product_rule_fields_for(rule)
        render "workarea/admin/product_rules/fields/#{rule.slug}", rule: rule
      rescue ActionView::MissingTemplate
        render "workarea/admin/product_rules/fields/generic", rule: rule
      end

      def render_product_rule_summary_for(rule)
        render "workarea/admin/product_rules/summaries/#{rule.slug}", rule: rule
      rescue ActionView::MissingTemplate
        render "workarea/admin/product_rules/summaries/generic", rule: rule
      end

      def product_rules_show_all_query_string(show_all: true)
        "?#{request.query_parameters.merge('show_all' => show_all).to_query}"
      end
    end
  end
end
