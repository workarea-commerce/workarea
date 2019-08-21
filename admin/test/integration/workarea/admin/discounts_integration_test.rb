require 'test_helper'

module Workarea
  module Admin
    class DiscountsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_updates_a_discount
        discount = create_shipping_discount(
          name: 'Test Discount',
          active: true,
          shipping_service: 'Ground',
          amount: 5
        )

        patch admin.pricing_discount_path(discount),
          params: {
            discount: {
              name: 'Edit Test Discount',
              shipping_service: 'Next Day',
              amount: 4
            }
          }

        discount.reload
        assert_equal('Edit Test Discount', discount.name)
        assert_equal('Next Day', discount.shipping_service)
        assert_equal(4.to_m, discount.amount)
      end

      def test_removes_a_discount
        discount = create_shipping_discount(
          name: 'Test Discount',
          active: true,
          shipping_service: 'Ground',
          amount: 5
        )

        delete admin.pricing_discount_path(discount)
        assert(Pricing::Discount.empty?)
      end

      def test_autocompletes_partial_queries_when_xhr
        discount = create_product_discount(name: 'Test')
        create_top_discounts(results: [{ discount_id: discount.id }])

        get admin.pricing_discounts_path(format: 'json', q: 'tes'), xhr: true

        results = JSON.parse(response.body)
        assert_equal(1, results['results'].length)
        assert(results['results'].first['label'].present?)
        assert_equal(discount.id.to_s, results['results'].first['value'])
        assert(results['results'].first['top'])
      end
    end
  end
end
