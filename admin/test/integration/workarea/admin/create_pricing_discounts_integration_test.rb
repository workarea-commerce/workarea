require 'test_helper'

module Workarea
  module Admin
    class CreatePricingDiscountsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creates_a_buy_some_get_some_discount
        post admin.create_pricing_discounts_path,
          params: {
            type: 'buy_some_get_some',
            discount: {
              name: 'Test Discount',
              active: true,
              purchase_quantity: 1,
              apply_quantity: 1,
              percent_off: 50,
              max_applications: 1,
              promo_codes_list: 'TEST_CODE'
            }
          }

        assert_equal(1, Pricing::Discount.count)
        discount = Pricing::Discount.first
        assert(discount.instance_of?(Pricing::Discount::BuySomeGetSome))
        assert_equal('Test Discount', discount.name)
        assert(discount.active)
        assert_equal(1, discount.purchase_quantity)
        assert_equal(1, discount.apply_quantity)
        assert_equal(50, discount.percent_off)
        assert_equal(1, discount.max_applications)
        assert_equal(%w(test_code), discount.promo_codes)
      end

      def test_creates_a_quantity_fixed_price_discount
        post admin.create_pricing_discounts_path,
          params: {
            type: 'quantity_fixed_price',
            discount: {
              name: 'Test Discount',
              active: true,
              quantity: 2,
              price: 10,
              product_ids: ['PRODUCT'],
              category_ids: ['CATEGORY'],
              max_applications: 1,
              promo_codes_list: 'TEST_CODE'
            }
          }

        assert_equal(1, Pricing::Discount.count)
        discount = Pricing::Discount.first
        assert(discount.instance_of?(Pricing::Discount::QuantityFixedPrice))
        assert_equal('Test Discount', discount.name)
        assert(discount.active)
        assert_equal(2, discount.quantity)
        assert_equal(10.to_m, discount.price)
        assert_equal(['PRODUCT'], discount.product_ids)
        assert_equal(['CATEGORY'], discount.category_ids)
        assert_equal(1, discount.max_applications)
        assert_equal(%w(test_code), discount.promo_codes)
      end

      def test_creates_a_category_discount
        post admin.create_pricing_discounts_path,
          params: {
            type: 'category',
            discount: {
              name: 'Test Discount',
              active: false,
              category_ids: %w(1 2),
              amount_type: 'flat',
              amount: 5,
              order_total_operator: 'greater_than',
              order_total: 100
            }
          }

        assert_equal(1, Pricing::Discount.count)
        discount = Pricing::Discount.first
        assert(discount.instance_of?(Pricing::Discount::Category))
        assert_equal('Test Discount', discount.name)
        refute(discount.active)
        assert_equal(%w(1 2), discount.category_ids)
        assert_equal(:flat, discount.amount_type)
        assert_equal(5, discount.amount)
        assert_equal(:greater_than, discount.order_total_operator)
        assert_equal(100.to_m, discount.order_total)
      end

      def test_creates_a_free_gift_discount
        create_product(variants: [{ sku: 'SKU' }])

        post admin.create_pricing_discounts_path,
          params: {
            type: 'free_gift',
            discount: {
              name: 'Test Discount',
              active: true,
              sku: 'SKU'
            }
          }

        assert_equal(1, Pricing::Discount.count)
        discount = Pricing::Discount.first
        assert(discount.instance_of?(Pricing::Discount::FreeGift))
        assert_equal('Test Discount', discount.name)
        assert(discount.active)
        assert_equal('SKU', discount.sku)
      end

      def test_creates_an_order_total_discount
        post admin.create_pricing_discounts_path,
          params: {
            type: 'order_total',
            discount: {
              name: 'Test Discount',
              active: true,
              amount_type: 'flat',
              amount: 5
            }
          }

        assert_equal(1, Pricing::Discount.count)
        discount = Pricing::Discount.first
        assert(discount.instance_of?(Pricing::Discount::OrderTotal))
        assert_equal('Test Discount', discount.name)
        assert(discount.active)
        assert_equal(:flat, discount.amount_type)
        assert_equal(5, discount.amount)
      end

      def test_creates_a_product_discount
        post admin.create_pricing_discounts_path,
          params: {
            type: 'product',
            discount: {
              name: 'Test Discount',
              active: false,
              amount_type: 'flat',
              amount: 5,
              product_ids: %w(1 2),
              item_quantity: 2
            }
          }

        assert_equal(1, Pricing::Discount.count)
        discount = Pricing::Discount.first
        assert(discount.instance_of?(Pricing::Discount::Product))
        assert_equal('Test Discount', discount.name)
        refute(discount.active)
        assert_equal(:flat, discount.amount_type)
        assert_equal(5, discount.amount)
        assert_equal(%w(1 2), discount.product_ids)
        assert_equal(2, discount.item_quantity)
      end

      def test_creates_a_product_attribute_discount
        post admin.create_pricing_discounts_path,
          params: {
            type: 'product_attribute',
            discount: {
              name: 'Test Discount',
              active: true,
              amount_type: 'flat',
              amount: 5,
              attribute_name: 'foo',
              attribute_value: 'bar',
              item_quantity: 2
            }
          }

        assert_equal(1, Pricing::Discount.count)
        discount = Pricing::Discount.first
        assert(discount.instance_of?(Pricing::Discount::ProductAttribute))
        assert_equal('Test Discount', discount.name)
        assert(discount.active)
        assert_equal(:flat, discount.amount_type)
        assert_equal(5, discount.amount)
        assert_equal('foo', discount.attribute_name)
        assert_equal('bar', discount.attribute_value)
        assert_equal(2, discount.item_quantity)
      end

      def test_creates_a_shipping_discount
        post admin.create_pricing_discounts_path,
          params: {
            type: 'shipping',
            discount: {
              name: 'Test Discount',
              active: false,
              shipping_service: 'Ground',
              amount: 5
            }
          }

        assert_equal(1, Pricing::Discount.count)
        discount = Pricing::Discount.first
        assert(discount.instance_of?(Pricing::Discount::Shipping))
        assert_equal('Test Discount', discount.name)
        refute(discount.active)
        assert_equal('Ground', discount.shipping_service)
        assert_equal(5.to_m, discount.amount)
      end

      def test_save_publish
        discount = discount = create_shipping_discount(
          active: false,
          name: 'Test Discount',
          shipping_service: 'Ground',
          amount: 5
        )

        post admin.save_publish_create_pricing_discount_path(discount),
          params: { activate: 'now' }

        assert(discount.reload.active?)

        discount.update_attributes!(active: false)

        post admin.save_publish_create_pricing_discount_path(discount),
          params: { activate: 'new_release', release: { name: '' } }

        assert(Release.empty?)
        assert(response.ok?)
        refute(response.redirect?)
        refute(discount.reload.active?)

        post admin.save_publish_create_pricing_discount_path(discount),
          params: { activate: 'new_release', release: { name: 'Foo' } }

        refute(discount.reload.active?)
        assert_equal(1, Release.count)
        release = Release.first
        assert_equal('Foo', release.name)
        release.as_current { assert(discount.reload.active?) }

        release = create_release
        discount.update_attributes!(active: false)

        post admin.save_publish_create_pricing_discount_path(discount),
          params: { activate: release.id }

        refute(discount.reload.active?)
        release.as_current { assert(discount.reload.active?) }
      end
    end
  end
end
