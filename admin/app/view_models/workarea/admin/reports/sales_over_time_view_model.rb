module Workarea
  module Admin
    module Reports
      class SalesOverTimeViewModel < ApplicationViewModel
        include GroupByTime

        def graph_data
          return [] if day_of_week?
          results.group_by(&:starts_at).transform_values { |v| (v || []).map(&:revenue) }
        end
      end
    end
  end
end
