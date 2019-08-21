module Workarea
  module Admin::ProductsHelper
    def format_variant_options(hash)
      hash.map do |name, value|
        joined = value.is_a?(Array) ? value.join(', ') : value
        "#{content_tag(:strong, name)}: #{joined}"
      end.join(', ').html_safe
    end
  end
end
