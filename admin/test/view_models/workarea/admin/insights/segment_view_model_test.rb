require 'test_helper'

module Workarea
  module Admin
    module Insights
      class SegmentViewModelTest < TestCase
        def test_average_order_value
          segment = create_segment

          Metrics::SegmentByDay.inc(
            key: { segment_id: segment.id },
            at: Time.zone.local(2018, 10, 26),
            orders: 1,
            revenue: 10.to_m
          )

          Metrics::SegmentByDay.inc(
            key: { segment_id: segment.id },
            at: Time.zone.local(2018, 10, 27),
            orders: 1,
            revenue: 10.to_m
          )

          Metrics::SegmentByDay.inc(
            key: { segment_id: segment.id },
            at: Time.zone.local(2018, 10, 28),
            orders: 2,
            revenue: 15.to_m
          )

          Metrics::SegmentByDay.inc(
            key: { segment_id: segment.id },
            at: Time.zone.local(2018, 10, 29),
            orders: 3,
            revenue: 27.to_m
          )

          Metrics::SegmentByDay.inc(
            key: { segment_id: 'bar' },
            at: Time.zone.local(2018, 10, 27),
            orders: 2,
            revenue: 11.to_m
          )

          Metrics::SegmentByDay.inc(
            key: { segment_id: 'bar' },
            at: Time.zone.local(2018, 10, 28),
            orders: 3,
            revenue: 15.to_m
          )

          Metrics::SegmentByDay.inc(
            key: { segment_id: 'bar' },
            at: Time.zone.local(2018, 10, 29),
            orders: 4,
            revenue: 27.to_m
          )


          view_model = SegmentViewModel.wrap(segment, starts_at: '2018-10-28', ends_at: '2018-10-29')
          assert_equal(8.4, view_model.average_order_value)
          assert_equal(10, view_model.previous_average_order_value)
          assert_in_delta(-15.999, view_model.average_order_value_percent_change)

          view_model = SegmentViewModel.wrap(segment, starts_at: '2018-10-29', ends_at: '2018-10-30')
          assert_equal(9, view_model.average_order_value)
          assert_in_delta(8.333, view_model.previous_average_order_value)
          assert_in_delta(7.999, view_model.average_order_value_percent_change)
        end
      end
    end
  end
end
