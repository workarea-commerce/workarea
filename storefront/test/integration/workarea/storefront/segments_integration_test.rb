require 'test_helper'

module Workarea
  module Storefront
    class SegmentsIntegrationTest < Workarea::IntegrationTest
      include Storefront::IntegrationTest

      def test_life_cycle_segments
        Workarea.config.loyal_customers_min_orders = 3
        create_life_cycle_segments

        get storefront.current_user_path(format: 'json')
        assert_equal(
          Segment::FirstTimeVisitor.instance.id.to_s,
          response.headers['X-Workarea-Segments']
        )

        cookies[:sessions] = 2
        get storefront.current_user_path(format: 'json')
        assert_equal(
          Segment::ReturningVisitor.instance.id.to_s,
          response.headers['X-Workarea-Segments']
        )

        complete_checkout

        get storefront.current_user_path(format: 'json')
        segments = response.headers['X-Workarea-Segments'].split(',')
        assert_equal(2, segments.size)
        assert_includes(segments, Segment::FirstTimeCustomer.instance.id.to_s)
        assert_includes(segments, Segment::ReturningVisitor.instance.id.to_s)

        complete_checkout

        get storefront.current_user_path(format: 'json')
        segments = response.headers['X-Workarea-Segments'].split(',')
        assert_equal(2, segments.size)
        assert_includes(segments, Segment::ReturningVisitor.instance.id.to_s)
        assert_includes(segments, Segment::ReturningCustomer.instance.id.to_s)

        complete_checkout

        get storefront.current_user_path(format: 'json')
        segments = response.headers['X-Workarea-Segments'].split(',')
        assert_equal(3, segments.size)
        assert_includes(segments, Segment::ReturningVisitor.instance.id.to_s)
        assert_includes(segments, Segment::ReturningCustomer.instance.id.to_s)
        assert_includes(segments, Segment::LoyalCustomer.instance.id.to_s)
      end
    end
  end
end
