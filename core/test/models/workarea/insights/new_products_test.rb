require 'test_helper'

module Workarea
  module Insights
    class NewProductsTest < TestCase
      setup :add_data, :time_travel

      def add_data
        create_product(id: 'five', created_at: Time.zone.local(2018, 10, 30, 23))
        create_product(id: 'four', created_at: Time.zone.local(2018, 10, 31, 5))
        create_product(id: 'three', created_at: Time.zone.local(2018, 10, 31, 11))
        create_product(id: 'two', created_at: Time.zone.local(2018, 10, 31, 17))
        create_product(id: 'one', created_at: Time.zone.local(2018, 10, 31, 23))
      end

      def time_travel
        travel_to Time.zone.local(2018, 11, 1)
      end

      def test_generate_monthly!
        NewProducts.generate_daily!
        assert_equal(1, NewProducts.count)

        new_products = NewProducts.first
        assert_equal(4, new_products.results.size)
        assert_equal('one', new_products.results.first['product_id'])
        assert_equal('two', new_products.results.second['product_id'])
        assert_equal('three', new_products.results.third['product_id'])
        assert_equal('four', new_products.results.fourth['product_id'])
      end
    end
  end
end
