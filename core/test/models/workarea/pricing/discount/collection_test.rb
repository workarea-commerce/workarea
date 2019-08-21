require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class CollectionTest < TestCase
        def test_all
          Workarea.config.discount_application_order = %w(
            Workarea::Pricing::Discount::Product
            Workarea::Pricing::Discount::ProductAttribute
            Workarea::Pricing::Discount::Category
            Workarea::Pricing::Discount::BuySomeGetSome
            Workarea::Pricing::Discount::QuantityFixedPrice
            Workarea::Pricing::Discount::FreeGift
            Workarea::Pricing::Discount::Shipping
            Workarea::Pricing::Discount::OrderTotal
          )

          buy_some_get_some = create_buy_some_get_some_discount
          category = create_category_discount
          free_gift = create_free_gift_discount
          order_total = create_order_total_discount
          product_attribute = create_product_attribute_discount
          product = create_product_discount
          fixed_price = create_quantity_fixed_price_discount
          shipping = create_shipping_discount

          collection = Collection.new

          assert_equal(product, collection.all[0])
          assert_equal(product_attribute, collection.all[1])
          assert_equal(category, collection.all[2])
          assert_equal(buy_some_get_some, collection.all[3])
          assert_equal(fixed_price, collection.all[4])
          assert_equal(free_gift, collection.all[5])
          assert_equal(shipping, collection.all[6])
          assert_equal(order_total, collection.all[7])
        end
      end
    end
  end
end
