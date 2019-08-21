require 'test_helper'

module Workarea
  module Storefront
    class CategoryViewModelTest < TestCase
      include SearchIndexing
      include ProductBrowsingViewModelTest

      def product_browsing_view_model_class
        CategoryViewModel
      end

      setup :set_category

      def set_category
        @category = create_category(default_sort: 'top_sellers')
      end

      def test_browser_title
        create_taxon(name: 'Foo', navigable: @category)
        view_model = CategoryViewModel.new(@category)
        assert_equal('Home - Foo', view_model.browser_title)
      end

      def test_products
        products = [
          create_product(name: 'Foo 1', filters: { 'color' => 'Red' }),
          create_product(name: 'Foo 2', filters: { 'color' => 'Green' })
        ]

        BulkIndexProducts.perform_by_models(products)
        @category.product_rules.create!(
          name: 'search',
          operator: 'equals',
          value: 'foo'
        )
        view_model = CategoryViewModel.new(@category)

        assert_equal('top_sellers', view_model.sort)

        assert(
          view_model
            .products
            .first
            .instance_of?(ProductViewModel)
        )
      end

      def test_rules
        @category.product_rules.create!(
          name: 'search',
          operator: 'equals',
          value: 'foo'
        )
        @category.product_rules.create!(
          name: 'search',
          operator: 'equals',
          value: 'bar',
          active: false
        )

        view_model = CategoryViewModel.new(@category)
        assert_equal(
          @category.product_rules.take(1),
          view_model.search_query.params[:rules]
        )
      end

      def test_sorts
        view_model = CategoryViewModel.new(@category)
        refute_includes(view_model.sorts.map(&:last), :featured)

        @category.product_ids = %w(1 2 3)
        view_model = CategoryViewModel.new(@category)
        assert_includes(view_model.sorts.map(&:last), :featured)
      end
    end
  end
end
