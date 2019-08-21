require 'test_helper'

module Workarea
  module Pricing
    class DiscountTest < TestCase
      class TrueDiscount < Discount
        add_qualifier :foo?

        def foo?(order, shipping = nil)
          true
        end
      end

      class FalseDiscount < Discount
        add_qualifier :foo?

        def foo?(order, shipping = nil)
          false
        end
      end

      def test_auto_deactivate
        one = create_category_discount(active: true)
        two = create_category_discount(active: true, auto_deactivate: false)

        Discount.auto_deactivate

        one.reload
        two.reload

        assert(one.auto_deactivated?)
        refute(one.active?)
        refute(two.auto_deactivated?)
        assert(two.active?)
      end

      def test_comparison_operator # <==>
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

        product = create_product_discount
        product_attribute = create_product_attribute_discount

        assert_equal(-1, product <=> product_attribute)
        assert_equal(1, product_attribute <=> product)
        assert_equal(0, product <=> product)

        product_1 = create_product_discount(id: 1)
        product_2 = create_product_discount(id: 2)

        assert_equal(-1, product_1 <=> product_2)
      end

      def test_qualifies?
        refute(Discount.new.qualifies?(Workarea::Order.new))

        order = Workarea::Order.new(items: [{ sku: 'SKU' }])
        assert(TrueDiscount.new.qualifies?(order))
        refute(FalseDiscount.new.qualifies?(order))
      end

      def test_last_redemption
        discount = Discount.create!(name: 'discount')
        discount.log_redemption('foo@bar.com')
        latest = discount.log_redemption('baz@bar.com')

        assert_equal(latest, discount.last_redemption)
      end

      def test_auto_deactivates_at
        discount = Discount.create!(name: 'discount')
        last_redemption = 1.day.ago
        discount.redemptions.create!(
          email: 'foo@bar.com',
          created_at: last_redemption
        )

        auto_deactivation_at =
          last_redemption + Workarea.config.discount_staleness_ttl

        assert_equal(auto_deactivation_at.to_i, discount.auto_deactivates_at.to_i)
      end
    end
  end
end
