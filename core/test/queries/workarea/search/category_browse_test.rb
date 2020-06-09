require 'test_helper'

module Workarea
  module Search
    class CategoryBrowseTest < IntegrationTest
      def test_ensures_inventory
        product = create_product(active: true, variants: [{ sku: '1234' }])
        category = create_category(product_ids: [product.id])
        create_inventory(id: '1234', available: 0)

        search = CategoryBrowse.new(category_ids: [category.id])
        assert_equal(0, search.total)
      end

      def test_active_products
        product = create_product(active: false, variants: [{ sku: '1234' }])
        category = create_category(product_ids: [product.id])
        create_inventory(id: '1234', available: 10)

        assert_equal(0, CategoryBrowse.new(category_ids: [category.id]).total)

        release = create_release
        release.as_current { product.update_attributes!(active: true) }
        IndexProduct.perform(product.reload)

        assert_equal(0, CategoryBrowse.new(category_ids: [category.id]).total)

        release.as_current do
          assert_equal(1, CategoryBrowse.new(category_ids: [category.id]).total)
        end
      end

      def test_respects_category_date_rules
        products = [
          create_product(created_at: Time.zone.parse('2013/8/24')),
          create_product(created_at: Time.zone.parse('2013/8/25')),
          create_product(created_at: Time.zone.parse('2013/8/26'))
        ]

        search = CategoryBrowse.new(
          rules: [
            ProductRule.new(
              name: 'created_at',
              operator: 'less_than_or_equal',
              value: '2013/8/25'
            )
          ]
        )

        result_ids = search.results.map { |r| r[:model].id }

        assert_includes(result_ids, products.first.id)
        assert_includes(result_ids, products.second.id)
        refute_includes(result_ids, products.third.id)
      end

      def test_respects_category_sale_rules
        products = [
          create_product(
            variants: [{ sku: 'SKU1' }]
          ),
          create_product(
            variants: [{ sku: 'SKU2', on_sale: true }]
          ),
          create_product(
            variants: [{ sku: 'SKU3', on_sale: false }]
          )
        ]

        search = CategoryBrowse.new(
          rules: [
            ProductRule.new(
              name: 'on_sale',
              operator: 'equals',
              value: 'false'
            )
          ]
        )

        result_ids = search.results.map { |r| r[:model].id }

        assert_includes(result_ids, products.first.id)
        refute_includes(result_ids, products.second.id)
        assert_includes(result_ids, products.third.id)
      end

      def test_matching_featured_in_category_rule
        product_one = create_product
        product_two = create_product
        product_three = create_product

        other_category = create_category(
          product_rules: [],
          product_ids: [product_one.id, product_two.id]
        )

        search = CategoryBrowse.new(
          rules: [
            ProductRule.new(
              name: 'category',
              operator: 'equal',
              value: other_category.id
            )
          ]
        )

        result_ids = search.results.map { |r| r[:model].id }

        assert_includes(result_ids, product_one.id)
        assert_includes(result_ids, product_two.id)
        refute_includes(result_ids, product_three.id)
      end

      def test_excluding_featured_in_category_rule
        product_one = create_product
        product_two = create_product
        product_three = create_product

        other_category = create_category(
          product_rules: [],
          product_ids: [product_one.id, product_two.id]
        )

        search = CategoryBrowse.new(
          rules: [
            ProductRule.new(
              name: 'category',
              operator: 'not_equal',
              value: other_category.id
            )
          ]
        )

        result_ids = search.results.map { |r| r[:model].id }

        refute_includes(result_ids, product_one.id)
        refute_includes(result_ids, product_two.id)
        assert_includes(result_ids, product_three.id)
      end

      def test_matching_rules_and_featured_in_category_rule
        product_one = create_product(name: 'Foo')
        product_two = create_product
        product_three = create_product
        product_four = create_product(name: 'Bar')

        other_category = create_category(
          product_rules: [{ name: 'search', operator: 'equals', value: 'foo' }],
          product_ids: [product_two.id]
        )
        another_category = create_category(
          product_rules: [{ name: 'search', operator: 'equals', value: 'bar' }]
        )

        search = CategoryBrowse.new(
          rules: [
            ProductRule.new(
              name: 'category',
              operator: 'equals',
              value: [other_category.id, another_category.id].join(',')
            )
          ]
        )

        result_ids = search.results.map { |r| r[:model].id }

        assert_includes(result_ids, product_one.id)
        assert_includes(result_ids, product_two.id)
        refute_includes(result_ids, product_three.id)
        assert_includes(result_ids, product_four.id)
      end

      def test_adds_the_selected_sort
        products = [
          create_product(created_at: Time.new(2013, 8, 24)),
          create_product(created_at: Time.new(2013, 8, 25)),
          create_product(created_at: Time.new(2013, 8, 26))
        ]

        search = CategoryBrowse.new(
          sort: 'newest',
          rules: [
            ProductRule.new(name: 'search', operator: 'equals', value: '*')
          ]
        )

        result_ids = search.results.map { |r| r[:model].id }
        assert_equal(products.reverse.map(&:id), result_ids)
      end

      def test_handles_multiple_category_sorts
        featured_product = create_product
        category = create_category(product_ids: [featured_product.id])

        products = [
          create_product(created_at: Time.new(2013, 8, 24)),
          create_product(created_at: Time.new(2013, 8, 25)),
          create_product(created_at: Time.new(2013, 8, 26))
        ]

        search = CategoryBrowse.new(
          category_ids: [category.id],
          sort: %w(featured newest),
          rules: [
            ProductRule.new(name: 'search', operator: 'equals', value: '*')
          ]
        )

        result_ids = search.results.map { |r| r[:model].id }

        assert_equal(
          [featured_product.id] + products.reverse.map(&:id),
          result_ids
        )
      end

      def test_facets
        products = [
          create_product(
            variants: [{ sku: '1', regular: 3.to_m }],
            filters: { color: %w(Green Red Blue), size: %w(Small) }
          ),

          create_product(
            variants: [{ sku: '2', regular: 6.to_m }],
            filters: { color: %w(Red Blue), size: %w(Medium) }
          ),

          create_product(
            variants: [
              { sku: '3', regular: 7.to_m },
              { sku: '4', regular: 11.to_m }
            ],
            filters: { color: %w(Blue), size: %w(Medium Large) }
          )
        ]

        category = create_category(product_ids: products.map(&:id))

        search = CategoryBrowse.new(
          category_ids: [category.id],
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

        search = CategoryBrowse.new(
          category_ids: [category.id],
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

      def test_out_of_stock_products_showing_at_the_end
        in_stock_standard = create_product(id: '1', variants: [{ sku: '1' }])
        in_stock = create_product(id: '2', variants: [{ sku: '2' }])
        out_of_stock = create_product(id: '3', variants: [{ sku: '3' }])

        create_inventory(id: '1', policy: 'displayable_when_out_of_stock', available: 5)
        create_inventory(id: '2', policy: 'displayable_when_out_of_stock', available: 0)
        create_inventory(id: '3', policy: 'standard', available: 5)

        search = CategoryBrowse.new(
          category_ids: [create_category.id],
          sort: %w(newest),
          rules: [
            ProductRule.new(name: 'search', operator: 'equals', value: '*')
          ]
        )

        assert_equal(%w(3 1 2), search.results.map { |r| r[:model].id })
      end

      def test_out_of_stock_products_respecting_featured_products
        in_stock_standard = create_product(id: '1', variants: [{ sku: '1' }])
        in_stock = create_product(id: '2', variants: [{ sku: '2' }])
        out_of_stock = create_product(id: '3', variants: [{ sku: '3' }])

        create_inventory(id: '1', policy: 'displayable_when_out_of_stock', available: 5)
        create_inventory(id: '2', policy: 'displayable_when_out_of_stock', available: 0)
        create_inventory(id: '3', policy: 'standard', available: 5)

        category = create_category(product_ids: %w(1 2 3), product_rules: [])
        search = CategoryBrowse.new(sort: %w(featured), category_ids: [category.id])
        assert_equal(%w(1 2 3), search.results.map { |r| r[:model].id })
      end

      def test_different_products_by_segment
        segment_one = create_segment(name: 'One')
        segment_two = create_segment(name: 'Two')
        product_one = create_product(id: '1', active: true, active_segment_ids: [segment_one.id])
        product_two = create_product(id: '2', active: true, active_segment_ids: [segment_two.id])
        product_three = create_product(id: '3', active: false, active_segment_ids: [segment_one.id])
        product_four = create_product(id: '4', active: true)
        product_five = create_product(id: '5', active: false)
        rules = [ProductRule.new(name: 'search', operator: 'equals', value: '*')]

        search = CategoryBrowse.new(rules: rules)
        result_ids = search.results.map { |r| r[:model].id }

        refute_includes(result_ids, product_one.id)
        refute_includes(result_ids, product_two.id)
        refute_includes(result_ids, product_three.id)
        assert_includes(result_ids, product_four.id)
        refute_includes(result_ids, product_five.id)

        Segment.with_current(segment_one) do
          search = CategoryBrowse.new(rules: rules)
          result_ids = search.results.map { |r| r[:model].id }

          assert_includes(result_ids, product_one.id)
          refute_includes(result_ids, product_two.id)
          refute_includes(result_ids, product_three.id)
          assert_includes(result_ids, product_four.id)
          refute_includes(result_ids, product_five.id)
        end

        Segment.with_current(segment_two) do
          search = CategoryBrowse.new(rules: rules)
          result_ids = search.results.map { |r| r[:model].id }

          refute_includes(result_ids, product_one.id)
          assert_includes(result_ids, product_two.id)
          refute_includes(result_ids, product_three.id)
          assert_includes(result_ids, product_four.id)
          refute_includes(result_ids, product_five.id)
        end

        Segment.with_current(segment_one, segment_two) do
          search = CategoryBrowse.new(rules: rules)
          result_ids = search.results.map { |r| r[:model].id }

          assert_includes(result_ids, product_one.id)
          assert_includes(result_ids, product_two.id)
          refute_includes(result_ids, product_three.id)
          assert_includes(result_ids, product_four.id)
          refute_includes(result_ids, product_five.id)
        end
      end

      def test_featured_product_changes_in_a_release
        one = create_product
        two = create_product
        three = create_product(name: 'Foo', active: false)
        category = create_category(product_ids: [one.id, two.id], product_rules: [])
        release = create_release(publish_at: 1.week.from_now)

        release.as_current do
          three.update!(name: 'Bar', active: true, default_category_id: category.id)
          category.update!(product_ids: [three.id, one.id, two.id])
          search = CategoryBrowse.new(sort: %w(featured), category_ids: [category.id])
          sorts = search.results.pluck(:raw).pluck('_source').pluck('sorts').pluck(category.id.to_s)
          assert_equal([0, 1, 2], sorts)
        end

        release.as_current do
          category.update!(product_ids: [one.id, two.id, three.id])
          search = CategoryBrowse.new(sort: %w(featured), category_ids: [category.id])
          sorts = search.results.pluck(:raw).pluck('_source').pluck('sorts').pluck(category.id.to_s)
          assert_equal([0, 1, 2], sorts)
        end
      end
    end
  end
end
