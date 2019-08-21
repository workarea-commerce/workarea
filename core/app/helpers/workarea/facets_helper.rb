module Workarea
  module FacetsHelper
    def facet_path(facet, value)
      link_params = facet.params_for(value)
      link_params[:only_path] = true
      url_for(link_params)
    end

    def price_range_facet_text(range)
      result = ''

      if range[:from].blank?
        price = number_to_currency(range[:to].to_m)
        return t('workarea.facets.price_range.under', price: price).html_safe
      elsif range[:to].present?
        result << number_to_currency(range[:from].to_m)
      end

      if range[:from].present? && range[:to].present?
        result << ' - '
      end

      if range[:to].blank?
        price = number_to_currency(range[:from].to_m)
        return t('workarea.facets.price_range.over', price: price).html_safe
      elsif range[:from].present?
        result << number_to_currency(range[:to].to_m)
      end

      result.html_safe
    end

    def facet_hidden_inputs(facets)
      result = ''

      params.slice(*facets.map(&:system_name)).each_pair do |key, value|
        if value.respond_to?(:map)
          value.map do |val|
            result << hidden_field_tag(
              "#{key}[]",
              val,
              id: nil
            )
          end
        else
          result << hidden_field_tag("#{key}[]", value)
        end
      end

      result.html_safe
    end
  end
end
