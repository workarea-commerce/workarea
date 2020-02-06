require 'test_helper'

module Workarea
  module Storefront
    class PricingOverridesSystemTest < Workarea::SystemTest
      include Admin::IntegrationTest
      include Storefront::SystemTest

      setup :setup_checkout_specs, :add_product_to_cart

      def test_overriding_order_pricing
        visit storefront.cart_path

        wait_for_xhr
        within_frame find('.admin-toolbar') do
          click_link t('workarea.admin.toolbar.adjust_order_pricing')
        end

        order = Order.not_placed.last

        assert_current_path(admin.edit_pricing_override_path(order.id))
        fill_in "override[item_prices][#{order.items.first.id}]", with: '1.50'
        click_button 'adjust_order_pricing'

        assert_current_path(storefront.cart_path)
        assert(page.has_content?(t('workarea.pricing_overrides.description')))
        assert(page.has_content?(/-.7\.00/)) # pricing override amount
        assert(page.has_content?('3.00')) # total
        click_link t('workarea.storefront.carts.checkout'), match: :first

        fill_in_shipping_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        click_button t('workarea.storefront.checkouts.continue_to_payment')
        assert_current_path(storefront.checkout_payment_path)

        fill_in_credit_card
        click_button t('workarea.storefront.checkouts.place_order')
        assert_current_path(admin.order_path(Order.placed.desc(:placed_at).first))
        assert(page.has_content?('Success'))
        assert(page.has_content?('10.70')) # total w/ shipping
      end

      def test_not_having_permission_to_override
        admin_user.update!(super_admin: false, admin: true, orders_manager: false)

        visit storefront.cart_path

        wait_for_xhr
        within_frame find('.admin-toolbar') do
          assert(page.has_no_content?(t('workarea.admin.toolbar.adjust_order_pricing')))
        end
      end
    end
  end
end
