require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class FreeGiftTest < TestCase
        include DiscountConditionTests::OrderTotal
        include DiscountConditionTests::PromoCodes

        def qualified_discount
          @qualified_discount ||= FreeGift.new(category_ids: ['CATEGORY'])
        end
        alias_method :order_total_discount, :qualified_discount
        alias_method :promo_codes_discount, :qualified_discount

        def discounted_order
          @discounted_order ||= Workarea::Order.new.tap do |order|
            order.items.build(category_ids: ['CATEGORY'])
          end
        end

        def test_catalog_qualifies?
          order = Workarea::Order.new
          order.items.build(
            product_id: 'PRODUCT',
            category_ids: ['CATEGORY']
          )

          discount = FreeGift.new
          assert(discount.catalog_qualifies?(order))

          discount = FreeGift.new(category_ids: ['CATEGORY1'])
          refute(discount.catalog_qualifies?(order))

          discount = FreeGift.new(category_ids: ['CATEGORY'])
          assert(discount.catalog_qualifies?(order))

          discount = FreeGift.new(product_ids: ['PRODUCT1'])
          refute(discount.catalog_qualifies?(order))

          discount = FreeGift.new(product_ids: ['PRODUCT'])
          assert(discount.catalog_qualifies?(order))

          discount = FreeGift.new(
            product_ids: ['PRODUCT1'],
            category_ids: ['CATEGORY1']
          )
          refute(discount.catalog_qualifies?(order))

          discount = FreeGift.new(
            product_ids: ['PRODUCT'],
            category_ids: ['CATEGORY1']
          )
          assert(discount.catalog_qualifies?(order))

          discount = FreeGift.new(
            product_ids: ['PRODUCT1'],
            category_ids: ['CATEGORY']
          )
          assert(discount.catalog_qualifies?(order))
        end

        def test_apply_does_not_create_duplicate_pricing_skus
          Pricing::Sku.create_indexes
          create_pricing_sku(id: 'GIFT', prices: [{ regular: 5.to_m }])

          discount = FreeGift.new(sku: 'GIFT')
          order = Pricing::Discount::Order.new(Workarea::Order.new)

          2.times { discount.apply(order) }

          assert_equal(1, Pricing::Sku.where(id: 'GIFT').count)
        end
      end
    end
  end
end
