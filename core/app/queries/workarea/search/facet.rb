module Workarea
  module Search
    class Facet < Filter

      def selections
        Array(params[system_name]).reject(&:blank?)
      end

      def aggregation_filter
        {
          bool: {
            must: search
                    .facets
                    .reject { |f| f.system_name == system_name }
                    .map(&:post_filter_clause)
                    .reject(&:blank?)
          }
        }
      end

      def useless?
        selections.blank? &&
          (results.empty? || (results.one? && results.first.last == total))
      end

      def selected?(value = nil)
        return false if selections.blank?
        value.blank? || selections.include?(value_to_param(value))
      end

      def params_for(value)
        value = value_to_param(value)
        result = valid_params

        if selected?(value) && result[system_name].present?
          result[system_name].delete(value)
        else
          result[system_name] = Array(result[system_name])
          result[system_name] << value
        end

        result.delete_if { |_, v| v.blank? }
      end

      def query_clause
        # no op, facets will be applied in post_filter to allow aggregation
        # to display all options without being affected by selections.
      end

      def type
        raise NotImplementedError
      end

      def aggregation
        raise NotImplementedError
      end

      def post_filter_clause
        raise NotImplementedError
      end

      def results
        raise NotImplementedError
      end

      def value_to_param(value)
        raise NotImplementedError
      end
    end
  end
end
