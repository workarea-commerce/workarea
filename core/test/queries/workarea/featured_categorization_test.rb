require 'test_helper'

module Workarea
  class FeaturedCategorizationTest < TestCase
    include TestCase::Workers
    include TestCase::SearchIndexing

    setup :set_product

    def set_product
      @product = create_product
    end

    def test_all
      release = create_release(publish_at: 1.day.from_now)
      category_one = create_category
      category_two = create_category(product_ids: [@product.id])

      release.as_current do
        category_one.update!(product_ids: [@product.id])
        assert_equal(
          [category_two, category_one],
          FeaturedCategorization.new(@product.id).to_a
        )
      end

      release.changesets.destroy_all
      category_one.reload.update!(product_ids: [@product.id])

      release.as_current do
        category_one.update!(product_ids: [])
        assert_equal([category_two], FeaturedCategorization.new(@product.id).to_a)
      end

      create_release(publish_at: 2.days.from_now).as_current do
        assert_equal([category_two], FeaturedCategorization.new(@product.id).to_a)
      end
    end

    def test_categories_affected_by_current_release
      create_category
      assert_empty(FeaturedCategorization.new(@product.id).categories_affected_by_current_release)

      category_one = create_category
      release_one = create_release(publish_at: 1.day.from_now)
      release_one.as_current do
        category_one.update!(product_ids: [@product.id])

        categorization = FeaturedCategorization.new(@product.id)
        assert_equal([category_one], categorization.categories_affected_by_current_release)
        assert(categorization.categories_affected_by_current_release.first.featured_product?(@product.id))
      end

      release_two = create_release(publish_at: 2.days.from_now)
      release_two.as_current do
        category_one.update!(product_ids: ['foo'])

        categorization = FeaturedCategorization.new(@product.id)
        assert_equal([category_one], categorization.categories_affected_by_current_release)
        refute(categorization.categories_affected_by_current_release.first.featured_product?(@product.id))
      end

      assert_empty(FeaturedCategorization.new(@product.id).categories_affected_by_current_release)
    end
  end
end
