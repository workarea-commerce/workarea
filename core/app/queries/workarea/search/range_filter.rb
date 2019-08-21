module Workarea
  module Search
    class RangeFilter < Filter

      def query_clause
        return {} unless current_value.present?
        { range: { name => { options => current_value } } }
      end

      def system_name
        @system_name ||= name + suffix
      end

      private

      def suffix
        if %w(lt lte).include?(options.to_s)
          '_less_than'
        elsif %w(gt gte).include?(options.to_s)
          '_greater_than'
        end
      end
    end
  end
end
