require 'test_helper'

module Workarea
  module Admin
    class CategorizationsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      setup :set_models

      def set_models
        @product = create_product
        @category_one = create_category
        @category_two = create_category
        @category_three = create_category
      end

      def test_creation
        post admin.catalog_product_categorizations_path(@product),
          params: { category_ids: [@category_one.id, @category_two.id] }

        @category_one.reload
        @category_two.reload

        assert(@category_one.featured_product?(@product.id))
        assert(@category_two.featured_product?(@product.id))
      end

      def test_deletion
        @category_one.add_product(@product.id)
        delete admin.catalog_product_categorization_path(@product, @category_one)

        @category_one.reload
        refute(@category_one.featured_product?(@product.id))
      end

      def test_listing_default_category_candidates
        post admin.catalog_product_categorizations_path(@product),
          params: { category_ids: [@category_one.id, @category_three.id] }

        get admin.catalog_product_categorizations_path(@product, format: :json), xhr: true

        results = JSON.parse(response.body)
        assert(2, results['results'].length)
        assert(results['results'].first['value'], @category_one.id);
        assert(results['results'].last['value'], @category_three.id);
      end
    end
  end
end
