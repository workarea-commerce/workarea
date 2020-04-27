require 'test_helper'

module Workarea
  module Search
    class ProductSearchTest < IntegrationTest
      def test_total
        create_product(name: 'Foo Product')
        create_product(name: 'Test Product', description: 'foo')

        # Does not use multipass, skips descriptions
        assert_equal(1, ProductSearch.new(q: 'foo').total)
      end

      def test_ensures_inventory
        create_product(active: true, variants: [{ sku: '1234' }])
        create_inventory(id: '1234', available: 0)
        assert_equal(0, ProductSearch.new(q: '*').total)
      end

      def test_active_products
        product = create_product(active: false, variants: [{ sku: '1234' }])
        create_inventory(id: '1234', available: 10)

        assert_equal(0, ProductSearch.new(q: '*').total)

        release = create_release
        release.as_current { product.update_attributes!(active: true) }
        IndexProduct.perform(product.reload)

        assert_equal(0, ProductSearch.new(q: '*').total)

        release.as_current do
          assert_equal(1, ProductSearch.new(q: '*').total)
        end
      end

      def test_facets
        create_product(
          variants: [{ sku: '1', regular: 3.to_m }],
          filters: { color: %w(Green Red Blue), size: %w(Small) }
        )

        create_product(
          variants: [{ sku: '2', regular: 6.to_m }],
          filters: { color: %w(Red Blue), size: %w(Medium) }
        )

        create_product(
          variants: [
            { sku: '3', regular: 7.to_m },
            { sku: '4', regular: 11.to_m }
          ],
          filters: { color: %w(Blue), size: %w(Medium Large) }
        )

        search = ProductSearch.new(
          q: '*',
          terms_facets: %w(color size),
          range_facets: {
            price: [
              { 'to' => 5 },
              { 'from' => 5, 'to' => 9.99 },
              { 'from' => 10 }
            ]
          }
        )

        assert_equal(3, search.facets.size)
        assert_equal(
          { 'Blue' => 3, 'Red' => 2, 'Green' => 1 },
          search.facets.first.results
        )
        assert_equal(
          { 'Medium' => 2, 'Large' => 1, 'Small' => 1 },
          search.facets.second.results
        )
        assert_equal(
          {
            { to: 5.0 } => 1,
            { from: 5.0, to: 9.99 } => 2,
            { from: 10.0 } => 1
          },
          search.facets.third.results
        )

        search = ProductSearch.new(
          q: '*',
          terms_facets: %w(color size),
          range_facets: {
            price: [
              { 'to' => 5 },
              { 'from' => 5, 'to' => 9.99 },
              { 'from' => 10 }
            ]
          },
          color: 'Red',
          size: 'Medium'
        )

        assert_equal(3, search.facets.size)
        assert_equal(
          { 'Blue' => 2, 'Red' => 1 },
          search.facets.first.results
        )
        assert_equal(
          { 'Medium' => 1, 'Small' => 1 },
          search.facets.second.results
        )
        assert_equal(
          { { from: 5.0, to: 9.99 } => 1 },
          search.facets.third.results
        )
      end

      def test_boosted_fields
        Settings.current.update_attributes!(
          boosts: {
            'name': 2,
            'category_name': 1,
            'details': 1,
            'facets': 2
          }
        )

        assert_equal(
          [
            'content.name^2',
            'content.category_name^1',
            'content.details^1',
            'content.facets^2'
          ],
          ProductSearch.new.boosted_fields
        )

        Settings.current.update_attributes!(
          boosts: {
            'name': 2,
            'description': 0.75,
            'category_name': 1,
            'details': 1,
            'facets': 2
          }
        )

        refinement = ProductSearch.new(pass: ProductSearch::PASSES.second)
        assert_equal(
          [
            'content.name^2',
            'content.description^0.75',
            'content.category_name^1',
            'content.details^1',
            'content.facets^2'
          ],
          refinement.boosted_fields
        )

        refinement = ProductSearch.new(pass: ProductSearch::PASSES.last)
        assert_equal(
          [
            'content.name^2',
            'content.description^0.75',
            'content.category_name^1',
            'content.details^1',
            'content.facets^2'
          ],
          refinement.boosted_fields
        )
      end

      def test_default_operator
        assert_equal('AND', ProductSearch.new.default_operator)

        search = ProductSearch.new(pass: ProductSearch::PASSES.second)
        assert_equal('AND', search.default_operator)

        search = ProductSearch.new(pass: ProductSearch::PASSES.last)
        assert_equal('OR', search.default_operator)
      end

      def test_rewritten_query
        create_product(id: '1', name: 'Foo')
        create_product(id: '2', name: 'Foo')
        create_product(id: '3', name: 'Foo')
        create_search_customization(id: 'bar', rewrite: 'foo')

        search = ProductSearch.new(q: 'bar')
        results = search.results.map { |r| r[:model].id }

        assert_equal(3, results.length)
        assert_includes(results, '1')
        assert_includes(results, '2')
        assert_includes(results, '3')
      end

      def test_unspecified_sort
        products = [create_product, create_product, create_product]
        create_search_customization(id: 'foo', product_ids: products.map(&:id))

        search = ProductSearch.new(q: 'foo', terms_facets: %w(color size))
        result_ids = search.results.map { |r| r[:model].id }

        assert_equal(products.map(&:id), result_ids)
      end

      def test_custom_sort
        products = [create_product, create_product, create_product]
        create_search_customization(id: 'foo', product_ids: products.map(&:id))

        search = ProductSearch.new(q: 'foo', terms_facets: %w(color size), sort: 'newest')
        result_ids = search.results.map { |r| r[:model].id }

        assert_equal(products.reverse.map(&:id), result_ids)
      end

      def test_views_score_factor
        create_product_by_week(product_id: '1', views: 0)
        create_product_by_week(product_id: '2', views: 5)
        create_product_by_week(product_id: '3', views: 10)
        create_product(id: '1', name: 'Foo A')
        create_product(id: '2', name: 'Foo B')
        create_product(id: '3', name: 'Foo C')

        search = ProductSearch.new(q: 'foo')
        assert_equal(%w(3 2 1), search.results.map { |r| r[:model].id })
      end

      def test_featured_products
        create_product(id: '1', name: 'Foo')
        create_product(id: '2', name: 'Foo')
        create_product(id: '3', name: 'Bar')

        search = ProductSearch.new(q: 'foo')
        results = search.results.map { |r| r[:model].id }

        assert_equal(2, results.length)
        assert_includes(results, '1')
        assert_includes(results, '2')

        customization = create_search_customization(
          id: 'foo',
          product_ids: %w(3 1 2)
        )

        search = ProductSearch.new(q: 'foo')
        assert_equal(%w(3 1 2), search.results.map { |r| r[:model].id })

        customization.destroy

        search = ProductSearch.new(q: 'foo')
        results = search.results.map { |r| r[:model].id }

        assert_equal(2, results.length)
        assert_includes(results, '1')
        assert_includes(results, '2')
      end

      def test_exact_name_phrase_matches
        Settings.current.update_attributes!(
          boosts: {
            'name': 1,
            'description': 2,
            'category_name': 1,
            'details': 1,
            'facets': 1
          }
        )

        create_product(id: '1', name: 'Bar', description: 'foo test one')
        create_product(id: '2', name: 'Foo test one')

        search = ProductSearch.new(
          q: 'foo test one',
          pass: ProductSearch::PASSES.last
        )

        assert_equal(%w(2 1), search.results.map { |r| r[:model].id })
      end

      def test_only_finds_active_customizations
        customization = Search::Customization.find_by_query('foo')
        search = ProductSearch.new(q: 'foo')
        assert_equal(customization, search.customization)

        customization.update!(active: false)
        search = ProductSearch.new(q: 'foo')
        refute_equal(customization, search.customization)
        refute(search.customization.persisted?)
      end

      def test_only_suggests_from_active_products
        create_product(id: '1', name: 'Cotton Shirt')
        create_product(id: '2', name: 'Cotton Shirt')
        create_product(id: '3', name: 'Linen Shirt', active: false)
        create_product(id: '4', name: 'Linen Shirt', active: false)

        search = ProductSearch.new(q: 'cotton shrit')
        assert_equal(['cotton shirt'], search.query_suggestions)

        search = ProductSearch.new(q: 'linne shirt')
        assert(search.query_suggestions.empty?)
      end

      def test_omits_suggestions_that_have_the_same_query_id
        create_product(id: '1', name: 'Cotton Shirt')
        create_product(id: '2', name: 'Cotton Shirt')
        create_product(id: '3', name: 'Linen Shirt', active: false)
        create_product(id: '4', name: 'Linen Shirt', active: false)

        search = ProductSearch.new(q: 'cotton shirts')
        assert(search.query_suggestions.empty?)
      end

      def test_blank_views_scores_allow_boosts_to_have_effect
        Settings.current.update_attributes!(
          boosts: {
            'name': 0,
            'description': 0,
            'category_name': 0,
            'details': 5,
            'facets': 1
          }
        )

        create_product(
          id: '1',
          details: { 'color' => 'Red' },
          filters: { 'color' => 'Foo' }
        )
        create_product(
          id: '2',
          details: { 'color' => 'Foo' },
          filters: { 'color' => 'Red' }
        )

        search = ProductSearch.new(q: 'foo')
        assert_equal(%w(2 1), search.results.map { |r| r[:model].id })
      end

      def test_out_of_stock_products_showing_at_the_end
        in_stock_standard = create_product(id: '1', variants: [{ sku: '1' }])
        in_stock = create_product(id: '2', variants: [{ sku: '2' }])
        out_of_stock = create_product(id: '3', variants: [{ sku: '3' }])

        create_inventory(id: '1', policy: 'displayable_when_out_of_stock', available: 5)
        create_inventory(id: '2', policy: 'displayable_when_out_of_stock', available: 0)
        create_inventory(id: '3', policy: 'standard', available: 5)

        search = ProductSearch.new(q: '*')
        assert_equal(%w(1 3 2), search.results.map { |r| r[:model].id })
      end

      def test_out_of_stock_products_respecting_featured_products
        in_stock_standard = create_product(id: '1', name: 'foo', variants: [{ sku: '1' }])
        in_stock = create_product(id: '2', name: 'foo', variants: [{ sku: '2' }])
        out_of_stock = create_product(id: '3', name: 'foo', variants: [{ sku: '3' }])

        create_inventory(id: '1', policy: 'displayable_when_out_of_stock', available: 5)
        create_inventory(id: '2', policy: 'displayable_when_out_of_stock', available: 0)
        create_inventory(id: '3', policy: 'standard', available: 5)

        create_search_customization(id: 'foo', product_ids: %w(1 2 3))
        search = ProductSearch.new(q: 'foo')
        assert_equal(%w(1 2 3), search.results.map { |r| r[:model].id })
      end

      def test_product_rules
        create_product(id: '1', name: 'Foo')
        create_product(id: '2', name: 'Foo Bar')
        create_product(id: '3', name: 'Foo Baz')
        create_product(id: '4', name: 'Bar')

        search = ProductSearch.new(q: 'foo')
        results = search.results.map { |r| r[:model].id }

        assert_equal(3, results.length)
        assert_includes(results, '1')
        assert_includes(results, '2')
        assert_includes(results, '3')

        customization = create_search_customization(
          id: 'foo',
          product_rules: [{
            name: 'excluded_products',
            operator: 'equals',
            value: '1'
          }]
        )

        search = ProductSearch.new(q: 'foo', rules: customization.product_rules)
        results = search.results.map { |r| r[:model].id }
        assert_equal(2, results.length)
        assert_includes(results, '2')
        assert_includes(results, '3')

        customization.destroy

        search = ProductSearch.new(q: 'foo')
        results = search.results.map { |r| r[:model].id }

        assert_equal(3, results.length)
        assert_includes(results, '1')
        assert_includes(results, '2')
        assert_includes(results, '3')
      end

      def test_accessing_raw_results
        create_product(name: 'Foo Product')
        result = ProductSearch.new(q: 'foo').results.first

        assert(result[:raw].present?)
        assert_kind_of(Float, result[:raw]['_score'])
      end

      def test_previewing_releases
        product = create_product(id: 'foo', variants: [{ sku: '1234', regular: 5 }])
        pricing = Pricing::Sku.find('1234')
        assert_equal([product], ProductSearch.new(q: '*').results.pluck(:model))

        release = create_release
        release.as_current { pricing.prices.first.update!(regular: 10) }
        IndexProduct.perform(product.reload)

        assert_equal([product], ProductSearch.new(q: '*').results.pluck(:model))
        release.as_current do
          assert_equal([product], ProductSearch.new(q: '*').results.pluck(:model))
        end
      end

      def test_locale
        # No simple way to run this test without fallbacks or localized fields
        return unless Workarea.config.localized_active_fields

        set_locales(available: [:en, :es], default: :en, current: :en)
        Search::Storefront.reset_indexes!

        product = create_product(active_translations: { 'en' => true, 'es' => false })

        I18n.locale = :es
        assert_equal([], ProductSearch.new(q: '*').results.pluck(:model))

        I18n.locale = :en
        assert_equal([product], ProductSearch.new(q: '*').results.pluck(:model))
      end
    end
  end
end
