require 'test_helper'

module Workarea
  module Admin
    class PricingOverridesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def order
        @order ||= create_order
      end

      def test_setting_price_overrides_for_an_order
        patch admin.pricing_override_path(order.id),
          params: {
            override: {
              subtotal_adjustment: '10.00',
              shipping_adjustment: '1.00'
            }
          }

        assert_redirected_to(storefront.cart_path)

        override = Pricing::Override.first
        assert_equal(-10.to_m, override.subtotal_adjustment)
        assert_equal(-1.to_m, override.shipping_adjustment)
      end

      def test_setting_item_price_overrides_for_an_order
        patch admin.pricing_override_path(order.id),
          params: {
            override: {
              item_prices: {
                '123' => '5.25',
                '234' => ''
              },
              shipping_adjustment: '1.00'
            }
          }

        assert_redirected_to(storefront.cart_path)

        override = Pricing::Override.first
        assert_equal(-1.to_m, override.shipping_adjustment)
        assert_equal(5.25.to_m, override.item_price_for_id('123'))
        assert_nil(override.item_price_for_id('234'))
      end

      def test_creating_a_comment_with_overrides
        patch admin.pricing_override_path(order.id),
          params: {
            override: {
              subtotal_adjustment: '10.00',
              shipping_adjustment: '1.00'
            },
            comment: 'test comment'
          }

        assert_equal(1, Pricing::Override.count)
        assert_equal(1, order.reload.comments.count)
      end

      def test_not_having_permission
        admin_user.update(super_admin: false, admin: true, orders_manager: false)
        get admin.edit_pricing_override_path(order.id)

        assert_redirected_to(admin.root_path)
        assert_equal(
          t('workarea.admin.authorization.unauthorized_area'),
          flash[:error]
        )
      end
    end
  end
end
