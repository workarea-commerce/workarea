require 'test_helper'

module Workarea
  module Admin
    class BulkActionSequentialProductEditsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_publish
        bulk_action = create_sequential_product_edit
        post admin.publish_bulk_action_sequential_product_edit_path(bulk_action),
          params: { activate: 'new_release', release: { name: '' } }

        assert(Release.empty?)
        assert(response.ok?)
        refute(response.redirect?)

        post admin.publish_bulk_action_sequential_product_edit_path(bulk_action),
          params: { activate: 'new_release', release: { name: 'Foo' } }

        assert_equal(1, Release.count)
        assert_equal('Foo', Release.first.name)
      end

      def test_redirection
        one = create_product
        two = create_product
        bulk_action = create_sequential_product_edit(
          ids: [one.to_global_id.to_param, two.to_global_id.to_param]
        )

        patch admin.product_bulk_action_sequential_product_edit_path(bulk_action, index: 0),
          params: { product: { name: 'Test Product' } }

        assert_redirected_to(
          admin.product_bulk_action_sequential_product_edit_path(
            bulk_action,
            index: 1
          )
        )

        patch admin.product_bulk_action_sequential_product_edit_path(bulk_action, index: 1),
          params: { product: { name: 'Test Product' } }

        assert_redirected_to(admin.catalog_products_path)
      end

      def test_saving_product
        product = create_product
        bulk_action = create_sequential_product_edit(
          ids: [product.to_global_id.to_param]
        )

        patch admin.product_bulk_action_sequential_product_edit_path(bulk_action, index: 0),
          params: {
            product: {
              name: 'Test Product',
              slug: 'foo-bar',
              tag_list: 'foo,bar,baz',
              template: 'test'
            }
          }

        product.reload
        assert_equal('Test Product', product.name)
        assert_equal('foo-bar', product.slug)
        assert_equal(%w(foo bar baz), product.tags)
        assert_equal('test', product.template)
      end

      def test_saving_variants
        product = create_product(variants: [])
        bulk_action = create_sequential_product_edit(
          ids: [product.to_global_id.to_param]
        )

        patch admin.product_bulk_action_sequential_product_edit_path(bulk_action, index: 0),
          params: {
            variants: [
              {
                sku: '1234',
                detail_1_name: 'Color',
                detail_1_value: 'Red',
                price: '24',
                inventory: '99'
              },
              {
                sku: '5678',
                detail_1_name: 'Color',
                detail_1_value: 'Green',
                price: '26',
                inventory: '9'
              }
            ]
          }

        product.reload
        assert_equal(2, product.variants.length)
        assert_equal('1234', product.variants.first.sku)
        assert_equal(['Red'], product.variants.first.details['Color'])
        assert_equal('5678', product.variants.second.sku)
        assert_equal(['Green'], product.variants.second.details['Color'])

        pricing = Pricing::Sku.find('1234')
        assert_equal(24.to_m, pricing.sell_price)

        inventory = Inventory::Sku.find('1234')
        assert_equal(99, inventory.available)

        pricing = Pricing::Sku.find('5678')
        assert_equal(26.to_m, pricing.sell_price)

        inventory = Inventory::Sku.find('5678')
        assert_equal(9, inventory.available)

        patch admin.product_bulk_action_sequential_product_edit_path(bulk_action, index: 0),
          params: {
            variants: [
              {
                id: product.variants.first.id,
                sku: 'CHANGED',
                detail_1_name: 'Color',
                detail_1_value: 'Red',
                price: '25',
                inventory: '101'
              },
              {
                id: product.variants.second.id,
                sku: '',
                detail_1_name: 'Color',
                detail_1_value: 'Green',
                price: '26',
                inventory: '9'
              }
            ]
          }

        product.reload
        assert_equal(1, product.variants.length)
        assert_equal('CHANGED', product.variants.first.sku)
        assert_equal(['Red'], product.variants.first.details['Color'])

        pricing = Pricing::Sku.find('CHANGED')
        assert_equal(25.to_m, pricing.sell_price)

        inventory = Inventory::Sku.find('CHANGED')
        assert_equal(101, inventory.available)
      end

      def test_saving_images
        product = create_product(images: [])
        bulk_action = create_sequential_product_edit(
          ids: [product.to_global_id.to_param]
        )

        patch admin.product_bulk_action_sequential_product_edit_path(bulk_action, index: 0),
          params: {
            new_images: [{ image: product_image_file_path, option: 'blue' }]
          }

        product.reload

        assert_equal(1, product.images.length)
        assert(product.images.first.image.present?)
        assert_equal('blue', product.images.first.option)

        patch admin.product_bulk_action_sequential_product_edit_path(bulk_action, index: 0),
          params: {
            image_updates: {
              product.images.first.id => { option: 'green' }
            }
          }

        product.reload

        assert_equal(1, product.images.length)
        assert(product.images.first.image.present?)
        assert_equal('green', product.images.first.option)
      end

      def test_saving_details_and_filters
        product = create_product(filters: {}, details: {})
        bulk_action = create_sequential_product_edit(
          ids: [product.to_global_id.to_param]
        )

        patch admin.product_bulk_action_sequential_product_edit_path(bulk_action, index: 0),
          params: {
            filters: ['Color', 'Red'],
            details: ['Material', 'Cotton']
          }

        product.reload
        assert_equal(['Red'], product.filters['Color'])
        assert_equal(['Cotton'], product.details['Material'])
      end
    end
  end
end
