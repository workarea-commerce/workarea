require 'test_helper'

module Workarea
  module Storefront
    class RecommendationsViewModelTest < TestCase
      class FooRecommendations < RecommendationsViewModel
        def product_ids
          model
        end

        def result_count
          options[:result_count] || 2
        end
      end

      def test_respecting_active_products
        one = create_product(id: '1')
        create_product(id: '2', active: false)
        three = create_product(id: '3')

        view_model = FooRecommendations.new(%w(1 2 3))
        assert(view_model.products.all? { |vm| vm.is_a?(ProductViewModel) })
        assert_equal([one, three], view_model.products.map(&:model))
      end

      def test_respecting_purchasable_products
        one = create_product(id: '1')
        create_product(id: '2', purchasable: false)
        three = create_product(id: '3')

        view_model = FooRecommendations.new(%w(1 2 3))
        assert(view_model.products.all? { |vm| vm.is_a?(ProductViewModel) })
        assert_equal([one, three], view_model.products.map(&:model))
      end

      def test_falling_back_to_popular_products
        one = create_product(id: '1')
        create_product(id: '2')
        create_product(id: '3')
        create_top_products(results: [{ 'product_id' => '1' }])

        view_model = FooRecommendations.new([])
        assert(view_model.products.all? { |vm| vm.is_a?(ProductViewModel) })
        assert_equal([one], view_model.products.map(&:model))
      end

      def test_uniquing_products
        create_product(id: '1', name: 'Product One')
        create_product(id: '2', name: 'Product Two')
        create_top_products(
          results: [
            { 'product_id' => '1' },
            { 'product_id' => '2' }
          ]
        )

        view_model = FooRecommendations.new(%w(1 2), result_count: 4)
        assert_equal(2, view_model.size)
      end
    end
  end
end
