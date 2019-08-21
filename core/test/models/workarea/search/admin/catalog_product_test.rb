require 'test_helper'

module Workarea
  module Search
    class Admin
      class CatalogProductTest < TestCase
        include SearchIndexing

        setup :set_product

        def set_product
          @product = create_product
        end

        def test_keywords_includes_category_ids
          category = create_category(product_ids: [@product.id])
          search_model = CatalogProduct.new(@product)
          assert_includes(search_model.keywords, category.id)
        end

        def test_jump_to_search_text_includes_variant_names
          @product.variants.first.update!(name: 'Foo')
          search_model = CatalogProduct.new(@product)

          assert_includes(search_model.jump_to_search_text, 'Foo')
        end

        def test_adds_no_images_to_issues_if_no_images
          @product.images = []

          facets = CatalogProduct.new(@product).facets[:issues]
          assert_includes(facets, t('workarea.alerts.issues.no_images'))
        end

        def test_adds_no_description_to_issues_if_no_description
          @product.description = nil

          facets = CatalogProduct.new(@product).facets[:issues]
          assert_includes(facets, t('workarea.alerts.issues.no_description'))
        end

        def test_adds_no_variants_to_issues_if_no_variants
          @product.variants = []

          facets = CatalogProduct.new(@product).facets[:issues]
          assert_includes(facets, t('workarea.alerts.issues.no_variants'))
        end

        def test_adds_no_categories_to_issues_if_no_categories
          Catalog::Category.delete_all

          facets = CatalogProduct.new(@product).facets[:issues]
          assert_includes(facets, t('workarea.alerts.issues.no_categories'))
        end

        def test_adds_low_inventory_to_issues_if_low_inventory
          create_inventory(
            id: @product.skus.first,
            policy: 'standard',
            available: Workarea.config.low_inventory_threshold - 1
          )

          facets = CatalogProduct.new(@product).facets[:issues]
          assert_includes(facets, t('workarea.alerts.issues.low_inventory'))
        end

        def test_adds_variant_missing_details_to_issues
          product = create_product(variants: [{ sku: 'SKU' }])
          facets = CatalogProduct.new(product).facets[:issues]
          assert_includes(facets, t('workarea.alerts.issues.variants_missing_details'))

          product.variants.first.details = { 'Color' => %w(red) }
          facets = CatalogProduct.new(product).facets[:issues]
          refute_includes(facets, t('workarea.alerts.issues.variants_missing_details'))
        end

        def test_adds_inconsistent_variant_details_to_issues
          product = create_product(
            variants: [
              { sku: 'SKU', details: { 'Color' => %w(red), 'Size' => %w(L) } },
              { sku: 'SKU', details: { 'Color' => %w(red) } }
            ]
          )
          facets = CatalogProduct.new(product).facets[:issues]
          assert_includes(facets, t('workarea.alerts.issues.inconsistent_variant_details'))

          product.variants.last.details['Size'] = %w(M)
          facets = CatalogProduct.new(product).facets[:issues]
          refute_includes(facets, t('workarea.alerts.issues.inconsistent_variant_details'))
        end

        def test_adds_template_type_to_facets
          facets = CatalogProduct.new(@product).facets[:template]
          assert_equal('generic', facets)
        end

        def test_autocomplete_matches_id_and_skus
          search_model = CatalogProduct.new(@product)
          assert_includes(search_model.jump_to_search_text, @product.id)
          assert_includes(search_model.jump_to_search_text, @product.skus.first)
        end

        def test_search_text
          colors = %w(Red Green Blue)
          product = create_product(filters: { 'Color' => colors })
          search_model = CatalogProduct.new(product)

          colors.each do |color|
            assert_includes(search_model.filter_values, color)
            assert_includes(search_model.search_text, color)
            refute_includes(search_model.jump_to_search_text, color)
          end

          assert_includes(search_model.keywords, product.id)
          assert_includes(search_model.keywords, product.skus.first)
        end

        def test_autocomplete_matches_variant_names
          @product.variants.first.update!(name: 'Test Variant')
          search_model = CatalogProduct.new(@product)
          assert_includes(search_model.jump_to_search_text, 'Test Variant')
        end
      end
    end
  end
end
