require 'test_helper'

module Workarea
  module Admin
    module Insights
      class ProductViewModelTest < TestCase
        def test_average_price_data
          Metrics::ProductByDay.inc(
            key: { product_id: 'foo' },
            at: Time.zone.local(2018, 10, 26),
            orders: 1,
            units_sold: 2,
            merchandise: 10.to_m,
            discounts: 0.to_m,
            revenue: 10.to_m
          )

          Metrics::ProductByDay.inc(
            key: { product_id: 'foo' },
            at: Time.zone.local(2018, 10, 27),
            orders: 1,
            units_sold: 2,
            merchandise: 10.to_m,
            discounts: 0.to_m,
            revenue: 10.to_m
          )

          Metrics::ProductByDay.inc(
            key: { product_id: 'foo' },
            at: Time.zone.local(2018, 10, 28),
            orders: 2,
            units_sold: 4,
            merchandise: 20.to_m,
            discounts: -5.to_m,
            revenue: 15.to_m
          )

          Metrics::ProductByDay.inc(
            key: { product_id: 'foo' },
            at: Time.zone.local(2018, 10, 29),
            orders: 3,
            units_sold: 6,
            merchandise: 30.to_m,
            discounts: -3.to_m,
            revenue: 27.to_m
          )

          Metrics::ProductByDay.inc(
            key: { product_id: 'bar' },
            at: Time.zone.local(2018, 10, 27),
            orders: 2,
            units_sold: 3,
            merchandise: 11.to_m,
            discounts: 0.to_m,
            revenue: 11.to_m
          )

          Metrics::ProductByDay.inc(
            key: { product_id: 'bar' },
            at: Time.zone.local(2018, 10, 28),
            orders: 3,
            units_sold: 5,
            merchandise: 21.to_m,
            discounts: -6.to_m,
            revenue: 15.to_m
          )

          Metrics::ProductByDay.inc(
            key: { product_id: 'bar' },
            at: Time.zone.local(2018, 10, 29),
            orders: 4,
            units_sold: 7,
            merchandise: 31.to_m,
            discounts: -4.to_m,
            revenue: 27.to_m
          )

          product = create_product(id: 'foo')
          view_model = ProductViewModel.wrap(product, starts_at: '2018-10-28', ends_at: '2018-10-29')
          assert_equal(5.8, view_model.average_price)
          assert_equal(5.0, view_model.previous_average_price)
          assert_in_delta(15.999, view_model.average_price_percent_change)

          view_model = ProductViewModel.wrap(product, starts_at: '2018-10-29', ends_at: '2018-10-30')
          assert_equal(5.5, view_model.average_price)
          assert_in_delta(5.833, view_model.previous_average_price)
          assert_in_delta(-5.714, view_model.average_price_percent_change)
        end
      end
    end
  end
end
