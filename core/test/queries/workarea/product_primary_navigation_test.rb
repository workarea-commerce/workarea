require 'test_helper'

module Workarea
  class ProductPrimaryNavigationTest < IntegrationTest
    setup :set_product
    setup :set_categories
    setup :set_taxonomy

    def set_product
      @product = create_product
    end

    def set_categories
      @category_one = create_category(
        name: 'Oldest',
        created_at: 1.day.ago,
        product_ids: [@product.id]
      )

      @category_two = create_category(product_ids: [@product.id])
    end

    def set_taxonomy
      @primary_1 = create_taxon(name: 'Primary')
      @child_1 = create_taxon(parent: @primary_1, navigable: @category_one)
      @child_2 = create_taxon(parent: @child_1, navigable: @category_two)
    end

    def test_highest_category
      highest_category = ProductPrimaryNavigation.new(@product).highest_category
      assert_equal(@category_one.id, highest_category.id)
    end

    def test_oldest_category
      oldest_category = ProductPrimaryNavigation.new(@product).oldest_category
      assert_equal(@category_one.id, oldest_category.id)
    end

    def test_name
      name = ProductPrimaryNavigation.new(@product).name
      assert_equal('Primary', name)

      Navigation::Taxon.delete_all

      name = ProductPrimaryNavigation.new(@product).name
      assert_equal('Oldest', name)
    end
  end
end
