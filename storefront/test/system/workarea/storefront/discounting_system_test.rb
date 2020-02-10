require 'test_helper'

module Workarea
  module Storefront
    class DiscountingSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      setup :create_supporting_data
      setup :add_user_data

      def test_product_promo_code_discount
        create_product_discount(
          name: 'Integration Item Discount',
          amount_type: 'flat',
          amount: 1,
          promo_codes: ['PROMOCODE'],
          product_ids: [@product.id]
        )

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')

        assert(page.has_no_content?('Integration Item Discount'))
        assert(page.has_no_content?(/#{t('workarea.storefront.orders.total')} .4.00/))

        click_button t('workarea.storefront.carts.enter_promo_code_prompt')
        within '#promo_code_form' do
          fill_in 'promo_code', with: 'PROMOCODE'
          click_button t('workarea.storefront.carts.add')
        end

        assert(page.has_content?('Integration Item Discount'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .4.00/))

        start_user_checkout

        assert(page.has_content?('Integration Item Discount'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .4.00/))
      end

      def test_category_discount
        category = create_category(product_ids: [@product.id])

        create_category_discount(
          name: 'Integration Item Discount',
          amount_type: 'flat',
          amount: 1,
          category_ids: [category.id]
        )

        add_product_to_cart

        assert(page.has_content?('Integration Item Discount'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .4.00/))
      end

      def test_buy_one_get_one_discounts
        create_buy_some_get_some_discount(
          name: 'Test Discount',
          purchase_quantity: 1,
          apply_quantity: 1,
          percent_off: 100,
          product_ids: [@product.id]
        )

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_no_content?('Test Discount'))

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_content?('Test Discount'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .5.00/))
      end

      def test_quantity_fixed_price_discounts
        create_quantity_fixed_price_discount(
          name: 'Test Discount',
          quantity: 3,
          price: 10,
          product_ids: [@product.id]
        )

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_no_content?('Test Discount'))

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_no_content?('Test Discount'))

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_content?('Test Discount'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .10.00/))
      end

      def test_free_gift_discounts
        free_product = create_product(
          name: 'Free Product',
          variants: [{ sku: 'FREESKU', regular: 5.to_m }]
        )

        create_free_gift_discount(
          name: 'Free Item Discount',
          sku: free_product.skus.first,
          promo_codes: ['PROMOCODE']
        )

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        within '.product-list__info' do
          assert(page.has_no_content?('Free Product'))
        end

        click_button t('workarea.storefront.carts.enter_promo_code_prompt')
        within '#promo_code_form' do
          fill_in 'promo_code', with: 'PROMOCODE'
          click_button t('workarea.storefront.carts.add')
        end

        assert(page.has_content?('Free Product'))
        assert(page.has_content?('FREESKU'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .5.00/))

        start_user_checkout
        assert(page.has_content?('Free Product'))
        assert(page.has_content?('FREESKU'))
      end

      def test_order_total_discounts
        create_order_total_discount(
          name: 'Test Discount',
          amount_type: 'flat',
          amount: 1,
          promo_codes: ['PROMOCODE']
        )

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_no_content?('Test Discount'))

        click_button t('workarea.storefront.carts.enter_promo_code_prompt')
        within '#promo_code_form' do
          fill_in 'promo_code', with: 'PROMOCODE'
          click_button t('workarea.storefront.carts.add')
        end

        assert(page.has_content?('Test Discount'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .4.00/))

        start_user_checkout

        assert(page.has_content?('Test Discount'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .11.77/))
      end

      def test_product_attribute_discount
        create_product_attribute_discount(
          name: 'Test Discount',
          amount_type: 'percent',
          amount: 20,
          attribute_name: 'foo',
          attribute_value: 'bar'
        )

        @product.details['foo'] = 'bar'
        @product.save!

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_content?('Test Discount'))
        assert(page.has_content?('1.00'))
        assert(page.has_content?('4.00'))

        start_user_checkout

        assert(page.has_content?('Test Discount'))
        assert(page.has_content?('1.00'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .11.77/))
      end

      def test_single_use_discount
        create_order_total_discount(
          name: 'Test Discount',
          amount_type: 'flat',
          amount: 1,
          single_use: true
        )

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_content?('Test Discount'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .4.00/))

        start_user_checkout

        assert(page.has_content?('Test Discount'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .11.77/))

        click_button t('workarea.storefront.checkouts.place_order')

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_content?(@product.name))

        visit storefront.checkout_path

        assert(page.has_no_content?('Test Discount'))
        assert(page.has_no_content?(/#{t('workarea.storefront.orders.total')} .11.77/))
      end

      def test_generated_promo_code
        code_list = create_code_list

        create_order_total_discount(
          name: 'Test Discount',
          amount_type: 'percent',
          amount: 20,
          generated_codes_id: code_list.id
        )

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')

        click_button t('workarea.storefront.carts.enter_promo_code_prompt')
        within '#promo_code_form' do
          fill_in 'promo_code', with: code_list.promo_codes.first.code
          click_button t('workarea.storefront.carts.add')
        end

        assert(page.has_content?('Test Discount'))
        assert(page.has_content?('1.00'))
        assert(page.has_content?('4.00'))

        start_user_checkout

        assert(page.has_content?('Test Discount'))
        assert(page.has_content?('1.00'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .11.77/))

        click_button t('workarea.storefront.checkouts.place_order')

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')

        click_button t('workarea.storefront.carts.enter_promo_code_prompt')
        within '#promo_code_form' do
          fill_in 'promo_code', with: code_list.promo_codes.first.code
          click_button t('workarea.storefront.carts.add')
        end

        assert(page.has_content?('Error'))
      end

      def test_product_discount
        create_product_discount(
          name: 'Test Discount',
          amount_type: 'flat',
          amount: 1,
          product_ids: [@product.id]
        )

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_content?('Test Discount'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .4.00/))
      end

      def test_user_tag_discount
        user = User.find_by_email('bcrouse@workarea.com')
        user.update!(tag_list: 'vip')

        create_order_total_discount(
          name: 'Test Discount',
          amount_type: 'flat',
          amount: 1,
          user_tags: ['vip']
        )

        add_product_to_cart
        click_link t('workarea.storefront.carts.view_cart')
        assert(page.has_no_content?('Test Discount'))

        start_user_checkout

        assert(page.has_content?('Test Discount'))
        assert(page.has_content?(/#{t('workarea.storefront.orders.total')} .11.77/))
      end
    end
  end
end
