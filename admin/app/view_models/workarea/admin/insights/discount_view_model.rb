module Workarea
  module Admin
    module Insights
      class DiscountViewModel < ApplicationViewModel
        include InsightsDetails

        insights_scope -> { Metrics::DiscountByDay.by_discount(model.id) }

        add_sparkline :orders, :discounts
        add_summaries :orders, :discounts, :revenue
        add_graph_data :orders, :discounts, :revenue

        def feed
          @feed ||= InsightViewModel.wrap(
            Workarea::Insights::Base.by_discount(model.id).to_a
          )
        end

        def top?
          Workarea::Insights::TopDiscounts.current.include?(discount_id: model.id)
        end
      end
    end
  end
end
