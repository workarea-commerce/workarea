module Workarea
  module Search
    class DateFilter < Filter
      def query_clause
        return {} unless current_value.present?
        { range: { name => { options => query_value.to_s(:iso8601) } } }
      end

      def query_value
        result = Time.zone.parse(current_value.to_s)

        if greater_than? && !time_specified?
          result.beginning_of_day
        elsif less_than? && !time_specified?
          result.end_of_day
        else
          result
        end
      end

      def system_name
        @system_name ||= name + suffix
      end

      def less_than?
        %w(lt lte).include?(options.to_s)
      end

      def greater_than?
        %w(gt gte).include?(options.to_s)
      end

      def time_specified?
        parsed = Time.zone.parse(current_value.to_s)
        parsed != parsed.beginning_of_day
      end

      private

      def suffix
        if less_than?
          '_less_than'
        elsif greater_than?
          '_greater_than'
        end
      end
    end
  end
end
