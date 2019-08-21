require 'test_helper'

module Workarea
  module Admin
    class CreateCatalogProductsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create
        post admin.create_catalog_products_path,
          params: {
            product: {
              name: 'Test Product',
              slug: 'foo-bar',
              tag_list: 'foo,bar,baz',
              template: 'test'
            }
          }

        assert_equal(1, Catalog::Product.count)
        product = Catalog::Product.first

        assert_equal('Test Product', product.name)
        assert_equal('foo-bar', product.slug)
        assert_equal(%w(foo bar baz), product.tags)
        assert_equal('test', product.template)
        refute(product.active?)
      end

      def test_save_variants
        product = create_product(variants: [])

        post admin.save_variants_create_catalog_product_path(product),
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

        post admin.save_variants_create_catalog_product_path(product),
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

      def test_save_images
        product = create_product

        post admin.save_images_create_catalog_product_path(product),
          params: {
            images: [{ image: product_image_file_path, option: 'blue' }]
          }

        product.reload

        assert_equal(1, product.images.length)
        assert(product.images.first.image.present?)
        assert_equal('blue', product.images.first.option)

        post admin.save_images_create_catalog_product_path(product),
          params: {
            updates: {
              product.images.first.id => { option: 'green' }
            }
          }

        product.reload

        assert_equal(1, product.images.length)
        assert(product.images.first.image.present?)
        assert_equal('green', product.images.first.option)
      end

      def test_save_details
        product = create_product(filters: {}, details: {})

        post admin.save_details_create_catalog_product_path(product),
          params: {
            filters: ['Color', 'Red'],
            details: ['Material', 'Cotton']
          }

        product.reload
        assert_equal(['Red'], product.filters['Color'])
        assert_equal(['Cotton'], product.details['Material'])
      end

      def test_save_content
        product = create_product(description: '')

        post admin.save_content_create_catalog_product_path(product),
          params: { product: { description: 'foo' } }

        product.reload
        assert_equal('foo', product.description)
      end

      def test_save_categorization
        product = create_product
        category = create_category(product_ids: [])

        post admin.save_categorization_create_catalog_product_path(product),
          params: { category_ids: [category.id] }

        category.reload
        assert_equal([product.id], category.product_ids)
      end

      def test_publish
        product = create_product
        create_release(name: 'Foo Release', publish_at: 1.week.from_now)
        get admin.publish_create_catalog_product_path(product)

        assert(response.ok?)
        assert_includes(response.body, 'Foo Release')
      end

      def test_save_publish
        product = create_product(active: false)

        post admin.save_publish_create_catalog_product_path(product),
          params: { activate: 'now' }

        assert(product.reload.active?)

        product.update_attributes!(active: false)

        post admin.save_publish_create_catalog_product_path(product),
          params: { activate: 'new_release', release: { name: '' } }

        assert(Release.empty?)
        assert(response.ok?)
        refute(response.redirect?)
        refute(product.reload.active?)

        post admin.save_publish_create_catalog_product_path(product),
          params: { activate: 'new_release', release: { name: 'Foo' } }

        refute(product.reload.active?)
        assert_equal(1, Release.count)
        release = Release.first
        assert_equal('Foo', release.name)
        release.as_current { assert(product.reload.active?) }

        release = create_release
        product.update_attributes!(active: false)

        post admin.save_publish_create_catalog_product_path(product),
          params: { activate: release.id }

        refute(product.reload.active?)
        release.as_current { assert(product.reload.active?) }
      end
    end
  end
end
