require 'test_helper'

module Workarea
  module Admin
    class ShippingSkusSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_management
        Workarea.config.shipping_options[:units] = :imperial

        visit admin.shipping_skus_path
        click_link t('workarea.admin.shipping_skus.index.button')

        fill_in 'sku[id]', with: 'SKU1'
        click_button 'create_sku'

        assert_text('Success')
        assert_text('SKU1')

        click_link t('workarea.admin.cards.attributes.title')
        fill_in 'sku[weight]', with: '4'
        click_button 'save_sku'

        assert_text('Success')
        assert_text('4.0oz')
        assert_text('0in')

        click_link t('workarea.admin.cards.attributes.title')
        fill_in 'sku[length]', with: '1'
        fill_in 'sku[width]', with: '2'
        fill_in 'sku[height]', with: '3'
        click_button 'save_sku'

        assert_text('Success')
        assert_text('4.0oz')
        assert_text('1in')
        assert_text('2in')
        assert_text('3in')

        visit admin.shipping_skus_path

        assert_text('SKU1')
        assert_text('4.0oz')
        assert_text('1in')
        assert_text('2in')
        assert_text('3in')

        Workarea.config.shipping_options[:units] = :metric

        visit admin.shipping_sku_path('SKU1')

        assert_text('4.0g')
        assert_text('1cm')
        assert_text('2cm')
        assert_text('3cm')
      end

      def test_view_shipping_sku_from_variant
        Workarea.config.shipping_options[:units] = :imperial
        product = create_product

        visit admin.catalog_product_variants_path(product)

        assert_text('0oz')

        click_link '0oz'

        assert_text("Shipping #{product.skus.first}")

        click_link t('workarea.admin.cards.attributes.title')
        fill_in 'sku[weight]', with: '6'
        click_button 'save_sku'

        assert_text('Success')
        assert_text('6.0oz')

        visit admin.catalog_product_variants_path(product)

        assert_text('6.0oz')
      end
    end
  end
end
