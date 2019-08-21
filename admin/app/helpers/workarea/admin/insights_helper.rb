module Workarea
  module Admin
    module InsightsHelper
      def insights_path_for(model)
        url_for(
          action: 'insights',
          controller: model.model_name.route_key,
          id: model,
          only_path: true
        )
      end

      def insights_number_to_percentage(number, options = {})
        number_to_percentage(
          number,
          options.reverse_merge(precision: number.zero? || number.abs > 5 ? 0 : 2)
        )
      end

      def insights_trend_icon(number)
        return nil if number.blank? || number.zero?

        if number > 0
          content_tag(:span, '⬆', style: 'color: green;') # TODO FIXME
        else
          content_tag(:span, '⬇', style: 'color: red;') # TODO FIXME
        end
      end

      def current_popular_searches
        @current_popular_searches ||= Workarea::Insights::PopularSearches.current.results.take(5)
      end

      def sparkline_analytics_data_for(data)
        return [0] if data.blank?
        return Array.new(data.size, 0) if data.max.zero?

        data.map { |p| [(p / data.max.to_f * 10).round - 1, 0].max }
      end
    end
  end
end
