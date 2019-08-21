module Workarea
  module Admin
    module Dashboards
      class CatalogViewModel < ApplicationViewModel
        def insights
          @insights ||= InsightViewModel.wrap(
            Workarea::Insights::Base.by_dashboard('catalog').page(options[:page])
          )
        end
      end
    end
  end
end
