require 'test_helper'

module Workarea
  module Admin
    class ProductsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_updates_a_product
        product = create_product(variants: [])

        patch admin.catalog_product_path(product),
          params: { product: { name: 'Test Product', active: true } }

        product.reload
        assert_equal('Test Product', product.name)
        assert(product.active)
      end

      def test_updating_hash_fields_in_locales
        set_locales(available: [:en, :es], default: :en, current: :en)
        product = create_product(filters_translations: { 'en' => { 'Size' => ['Large'] } })

        patch admin.catalog_product_path(product, locale: 'es'),
          params: { new_filters: %w(Color Roja) }

        assert_equal(
          { 'en' => { 'Size' => ['Large'] }, 'es' => { 'Color' => ['Roja'] } },
          product.reload.filters_translations
        )
      end

      def test_returns_a_list_of_filters
        create_product(filters:  { 'Color' => 'Blue' })

        get admin.filters_catalog_products_path(
            format: 'json',
            name: 'Color',
            q: 'B'
          )

        results = JSON.parse(response.body)
        assert_equal(
          [{ 'label' => 'Blue', 'value' => 'Blue' }],
          results['results']
        )
      end

      def test_returns_a_list_of_details
        create_product(details: { color: 'Red' })

        get admin.details_catalog_products_path(
            format: 'json',
            name: 'color',
            q: 'R'
          )

        results = JSON.parse(response.body)

        assert_equal(
          [{ 'label' => 'Red', 'value' => 'Red' }],
          results['results']
        )
      end

      def test_autocompletes_partial_queries_when_xhr
        product = create_product(name: 'Test Product')
        create_top_products(results: [{ product_id: product.id }])

        get admin.catalog_products_path(format: 'json', q: 'tes'), xhr: true

        results = JSON.parse(response.body)
        assert_equal(1, results['results'].length)
        assert(results['results'].first['label'].present?)
        assert_equal(product.id, results['results'].first['value'])
        assert(results['results'].first['top'])
        refute(results['results'].first['trending'])
      end

      def test_destroy
        product = create_product
        delete admin.catalog_product_path(product)
        assert_equal(0, Catalog::Product.count)
      end
    end
  end
end
