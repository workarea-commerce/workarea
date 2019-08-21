require 'test_helper'

module Workarea
  class ProcessProductRecommendationsTest < Workarea::TestCase
    def test_processing_recent_orders
      Order.create!(
        placed_at: Time.current,
        items: [
          { product_id: '1', sku: 'SKU' },
          { product_id: '2', sku: 'SKU' }
        ]
      )

      2.times do
        Order.create!(
          placed_at: Time.current,
          items: [
            { product_id: '1', sku: 'SKU' },
            { product_id: '3', sku: 'SKU' }
          ]
        )
      end

      ProcessProductRecommendations.new.perform

      predictor = Recommendation::ProductPredictor.new
      assert_equal(%w(3 2), predictor.similarities_for('1'))
    end

    def test_within_expiration
      Order.create!(
        placed_at: Time.current,
        items: [
          { product_id: '1', sku: 'SKU' },
          { product_id: '2', sku: 'SKU' }
        ]
      )

      travel_to((Workarea.config.recommendation_expiration + 1.day).from_now)

      2.times do
        Order.create!(
          placed_at: Time.current,
          items: [
            { product_id: '1', sku: 'SKU' },
            { product_id: '3', sku: 'SKU' }
          ]
        )
      end

      ProcessProductRecommendations.new.perform

      predictor = Recommendation::ProductPredictor.new
      assert_equal(%w(3), predictor.similarities_for('1'))
    end
  end
end
