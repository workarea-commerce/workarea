require 'test_helper'

module Workarea
  class CleanProductRecommendationsTest < TestCase
    def test_perform
      predictor = Recommendation::ProductPredictor.new
      predictor.orders.add_set('order_id', %w(product_one product_two))
      predictor.process!
      assert_equal(%w(product_two), predictor.similarities_for('product_one'))

      CleanProductRecommendations.new.perform('product_two')
      assert_equal([], predictor.similarities_for('product_one'))
    end
  end
end
