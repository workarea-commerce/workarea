require 'test_helper'

module Workarea
  module Search
    class Storefront
      class ProductTest < IntegrationTest
        def test_sku_returns_only_skus_that_have_inventory
          inventory = create_inventory(
            id: 'SKU1',
            policy: 'standard',
            available: 10
          )

          create_inventory(
            id: 'SKU',
            policy: 'standard',
            available: 10
          )

          product = Catalog::Product.new(
            variants: [{ sku: 'SKU' }, { sku: 'SKU1' }]
          )
          search_model = Product.new(product)

          assert_equal(2, search_model.sku.length)
          assert_includes(search_model.sku, 'SKU')
          assert_includes(search_model.sku, 'SKU1')

          inventory.update_attributes!(available: 0)
          search_model = Product.new(product)
          assert_equal(['SKU'], search_model.sku)
        end

        def test_facets
          product = Catalog::Product.new
          refute_includes(Product.new(product).facets.keys, :category)
        end

        def test_skus
          product = Catalog::Product.new(
            variants: [{ sku: 'SKU' }, { sku: 'SKU1' }, { sku: 'SKU1' }]
          )
          search_model = Product.new(product)
          assert_equal(2, search_model.skus.length)

          product.variants.first.active = false
          search_model = Product.new(product)
          assert_equal(1, search_model.skus.length)
        end

        def test_variant_count
          product = Catalog::Product.new(
            variants: [{ sku: 'SKU' }, { sku: 'SKU1' }, { sku: 'SKU1' }]
          )
          search_model = Product.new(product)
          assert_equal(3, search_model.variant_count)

          product.variants.first.active = false
          search_model = Product.new(product)
          assert_equal(2, search_model.variant_count)
        end

        def test_score_calculation
          product = create_product

          over_year_ago = create_product_by_week(
            product_id: product.id,
            orders: 9999,
            reporting_on: Time.zone.local(2017, 12, 4)
          )

          two_weeks_ago = create_product_by_week(
            product_id: product.id,
            orders: 1,
            reporting_on: Time.zone.local(2018, 11, 25)
          )

          last_week = create_product_by_week(
            product_id: product.id,
            orders: 1,
            reporting_on: Time.zone.local(2018, 12, 2)
          )

          this_week = create_product_by_week(
            product_id: product.id,
            orders: 1,
            reporting_on: Time.zone.local(2018, 12, 5)
          )

          travel_to Time.zone.local(2018, 12, 5)

          Workarea.config.score_decay = 0.5
          Workarea.config.sorting_score_ttl = 1.year

          search_model = Product.new(product)
          assert_equal(1.75, search_model.orders_score)
        end

        def test_product_missing_from_storefront_index
          product = create_product
          Storefront.delete_indexes!
          assert(Product.new(product).destroy)
        end
      end
    end
  end
end
