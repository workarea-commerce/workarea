module Workarea
  module Admin
    module Reports
      class InsightsViewModel < ApplicationViewModel
        def type_options
          @type_options ||= [[t('workarea.admin.reports.insights.all_insights'), nil]] +
            Workarea::Insights::Base.distinct(:_type).map do |type|
              [type.demodulize.titleize, type]
            end
        end

        def feed
          @feed ||= InsightViewModel.wrap(query.page(options[:page]))
        end

        def type
          options[:type]
        end

        private

        def query
          if type.present?
            type.constantize.all
          else
            Workarea::Insights::Base.all
          end
        end
      end
    end
  end
end
