require 'test_helper'

module Workarea
  module Admin
    class RecommendationsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      setup :set_product

      def set_product
        @product = create_product
      end

      def test_updates_product_recommendations_settings
        patch admin.catalog_product_recommendations_path(@product),
          params: {
            sources: %w(automatic custom),
            settings: { product_ids_list: '1,2,3' }
          }

        assert_equal(1, Recommendation::Settings.count)
        settings = Recommendation::Settings.first
        assert_equal(@product.id, settings.id)
        assert_equal(%w(automatic custom), settings.sources)
        assert_equal(%w(1 2 3), settings.product_ids)
      end
    end
  end
end
