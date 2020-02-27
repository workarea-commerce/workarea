module Workarea
  module Admin
    module Insights
      class ProductViewModel < ApplicationViewModel
        include InsightsDetails

        insights_scope -> { Metrics::ProductByDay.by_product(model.id) }

        add_sparkline :orders
        add_summaries :views, :orders, :revenue, :units_sold, :merchandise, :discounts
        add_graph_data :views, :orders, :revenue, :units_sold

        def feed
          @feed ||= InsightViewModel.wrap(
            Workarea::Insights::Base.by_product(model.id).to_a
          )
        end

        def top?
          Workarea::Insights::TopProducts.current.include?(product_id: model.id)
        end

        def trending?
          Workarea::Insights::TrendingProducts.current.include?(product_id: model.id)
        end

        def skus
          @skus ||= skus_report.results.map { |r| OpenStruct.new(r) }
        end

        def skus_report
          @skus_report ||= Workarea::Reports::SalesBySku.new(
            skus: model.skus,
            starts_at: starts_at,
            ends_at: ends_at
          )
        end

        def average_price
          return nil if orders.zero?
          (merchandise - discounts) / units_sold
        end

        def previous_average_price
          return nil if previous_orders.zero?
          (previous_merchandise - previous_discounts) / previous_units_sold
        end

        def average_price_percent_change
          return nil if previous_average_price.blank?
          calculate_percent_change(previous_average_price, average_price)
        end
      end
    end
  end
end
