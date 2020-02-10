require 'test_helper'

module Workarea
  module Storefront
    class DiscountingMultipleSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      setup :set_discount_1
      setup :set_discount_2
      setup :create_supporting_data

      def set_discount_1
        @discount1 = create_order_total_discount(
          name: 'Discount1',
          amount_type: 'flat',
          amount: 1,
          promo_codes: ['PROMOCODE1']
        )
      end

      def set_discount_2
        @discount2 = create_order_total_discount(
          name: 'Discount2',
          amount_type: 'flat',
          amount: 2,
          promo_codes: ['PROMOCODE2']
        )
      end

      def test_disqualifying_a_discount_by_default
        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_no_content?('Discount1'))

        click_button t('workarea.storefront.carts.enter_promo_code_prompt')
        within '#promo_code_form' do
          fill_in 'promo_code', with: 'PROMOCODE1'
          click_button t('workarea.storefront.carts.add')
        end

        assert(page.has_content?('Discount1'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .4\.00/))

        click_button t('workarea.storefront.carts.enter_promo_code_prompt')
        within '#promo_code_form' do
          fill_in 'promo_code', with: 'PROMOCODE2'
          click_button t('workarea.storefront.carts.add')
        end

        assert(page.has_no_content?('Discount1'))
        assert(page.has_content?('Discount2'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .3\.00/))
      end

      def test_allowing_compatible_discounts
        @discount1.compatible_discount_ids = [@discount2.id.to_s]
        @discount1.save!

        @discount2.compatible_discount_ids = [@discount1.id.to_s]
        @discount2.save!

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_no_content?('Discount1'))

        click_button t('workarea.storefront.carts.enter_promo_code_prompt')
        within '#promo_code_form' do
          fill_in 'promo_code', with: 'PROMOCODE1'
          click_button t('workarea.storefront.carts.add')
        end

        assert(page.has_content?('Discount1'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .4\.00/))

        click_button t('workarea.storefront.carts.enter_promo_code_prompt')
        within '#promo_code_form' do
          fill_in 'promo_code', with: 'PROMOCODE2'
          click_button t('workarea.storefront.carts.add')
        end

        assert(page.has_content?('Discount1'))
        assert(page.has_content?('Discount2'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .2\.00/))
      end
    end
  end
end
