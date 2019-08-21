require 'test_helper'

module Workarea
  module Storefront
    module ContentBlocks
      class ProductInsightsViewModelTest < Workarea::TestCase
        def test_finding_results
          create_product(id: 'foo')
          create_product(id: 'bar', active: false)
          create_product(id: 'baz')
          create_product(id: 'qux', active: false)
          create_product(id: 'thud')
          create_product(id: 'corge')
          create_hot_products(
            results: [
              { product_id: 'bar' },
              { product_id: 'baz' },
              { product_id: 'foo' },
              { product_id: 'qux' },
              { product_id: 'thud' },
              { product_id: 'corge' }
            ]
          )

          block = Content::Block.new(
            type_id: 'product_insights',
            data: { type: 'Hot Products' }
          )

          view_model = ContentBlocks::ProductInsightsViewModel.new(block)
          assert_equal(%w(baz foo thud corge), view_model.products.map(&:id))
          assert(view_model.products.all? { |p| p.is_a?(ProductViewModel) })
        end

        def test_falling_back
          create_product(id: 'foo')
          create_product(id: 'bar')
          create_product(id: 'baz')
          create_product(id: 'qux')
          create_product(id: 'thud')
          create_product(id: 'corge')

          create_hot_products(
            results: [
              { product_id: 'bar' },
              { product_id: 'baz' },
              { product_id: 'foo' }
            ]
          )

          block = Content::Block.new(
            type_id: 'product_insights',
            data: { type: 'Hot Products' }
          )

          view_model = ContentBlocks::ProductInsightsViewModel.new(block)
          assert_equal(%w(bar baz foo corge thud qux), view_model.products.map(&:id))

          create_top_products(
            results: [
              { product_id: 'bar' },
              { product_id: 'qux' },
              { product_id: 'thud' }
            ]
          )

          view_model = ContentBlocks::ProductInsightsViewModel.new(block)
          assert_equal(%w(bar baz foo qux thud corge), view_model.products.map(&:id))
        end
      end
    end
  end
end
