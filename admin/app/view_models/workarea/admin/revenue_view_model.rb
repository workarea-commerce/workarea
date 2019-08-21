module Workarea
  module Admin
    class RevenueViewModel < ApplicationViewModel
      def initialize(revenue_stream)
        @revenue_stream = revenue_stream
      end

      def total_revenue
        @total_revenue ||= @revenue_stream.sum(:last_four_weeks_revenue)
      end

      def top_sellers_revenue
        @top_sellers_revenue ||=
          @revenue_stream
            .top
            .limit(5)
            .sum(:last_four_weeks_revenue)
      end

      def name
        @revenue_stream.revenue_class.name.to_s.demodulize.pluralize
      end

      def to_h
        [
          {
            label: t('workarea.admin.insights.revenue.top_label', name: name),
            value: percentage(top_sellers_revenue)
          },
          {
            label: t('workarea.admin.insights.revenue.other_label', name: name),
            value: percentage(total_revenue - top_sellers_revenue)
          }
        ]
      end

      private

      def percentage(amount)
        return 0 if total_revenue.zero?
        (amount * 1.0 / total_revenue * 100).round(1)
      end
    end
  end
end
