module Workarea
  module Admin
    module Dashboards
      class StoreViewModel < ApplicationViewModel
        def insights
          @insights ||= InsightViewModel.wrap(
            Workarea::Insights::Base.by_dashboard('store').page(options[:page])
          )
        end
      end
    end
  end
end
