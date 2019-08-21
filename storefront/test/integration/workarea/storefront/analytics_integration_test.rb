require 'test_helper'

module Workarea
  module Storefront
    class AnalyticsIntegrationTest < Workarea::IntegrationTest
      def test_saving_product_view
        post storefront.analytics_product_view_path(product_id: 'foo')
        assert_equal(1, Metrics::ProductByDay.first.views)
      end

      def test_saving_search
        post storefront.analytics_search_path(q: 'foo', total_results: '5')

        insights = Metrics::SearchByDay.first
        assert_equal(1, insights.searches)
        assert_equal(5, insights.total_results)
      end

      def test_saving_category_view
        post storefront.analytics_category_view_path(category_id: 'foo')
        assert_equal(1, Metrics::CategoryByDay.first.views)
      end

      def test_blocking_bots
        post storefront.analytics_product_view_path(product_id: 'foo'),
          headers: { 'HTTP_USER_AGENT' => 'Googlebot' }

        assert(Metrics::ProductByDay.count.zero?)
      end
    end
  end
end
