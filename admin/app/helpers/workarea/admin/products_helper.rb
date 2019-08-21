module Workarea
  module Admin::ProductsHelper
    def format_variant_options(hash)
      hash.map do |name, value|
        joined = value.is_a?(Array) ? value.join(', ') : value
        "#{content_tag(:strong, name)}: #{joined}"
      end.join(', ').html_safe
    end

    def summary_inventory_status_css_classes(product)
      status_issue_class =
        if !product.active?
          'product-summary--inactive'
        elsif !product.inventory.available?
          "product-summary--#{product.inventory.status.to_s.dasherize}"
        end

      return [] unless status_issue_class.present?
      return [] if product.inventory.any?(&:displayable_when_out_of_stock?)
      [status_issue_class, 'product-summary--status-issue']
    end
  end
end
