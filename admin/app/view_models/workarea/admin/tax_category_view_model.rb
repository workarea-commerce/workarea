module Workarea
  module Admin
    class TaxCategoryViewModel < ApplicationViewModel
      def timeline
        @timeline ||= TimelineViewModel.new(model)
      end

      def newest_rates
        @newest_rates ||= rates.order(created_at: :desc).limit(10)
      end
    end
  end
end
