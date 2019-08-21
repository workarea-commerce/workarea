module Workarea
  module Admin
    module Reports
      class AverageOrderValueViewModel < ApplicationViewModel
        include GroupByTime

        def graph_data
          return {} if day_of_week?
          results.group_by(&:starts_at).transform_values { |v| (v || []).map(&:average_order_value) }
        end
      end
    end
  end
end
