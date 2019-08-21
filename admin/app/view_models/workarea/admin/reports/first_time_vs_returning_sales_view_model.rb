module Workarea
  module Admin
    module Reports
      class FirstTimeVsReturningSalesViewModel < ApplicationViewModel
        include GroupByTime

        def graph_data
          return [] if day_of_week?
          results.group_by(&:starts_at).transform_values { |v| (v || []).map(&:percent_returning) }
        end
      end
    end
  end
end
