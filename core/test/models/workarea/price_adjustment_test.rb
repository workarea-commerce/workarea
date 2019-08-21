require 'test_helper'

module Workarea
  class PriceAdjustmentTest < TestCase
    def test_discount
      price_adjustment = PriceAdjustment.new

      price_adjustment.amount = -1.to_m
      assert(price_adjustment.discount?)

      price_adjustment.data = { 'override' => true }
      refute(price_adjustment.discount?)

      price_adjustment.amount = 5.to_m
      price_adjustment.data = { 'discount_value' => 1 }
      assert(price_adjustment.discount?)

      price_adjustment.data['override'] = true
      assert(price_adjustment.discount?)

      price_adjustment.amount = 5.to_m
      price_adjustment.data = {}
      refute(price_adjustment.discount?)
    end
  end
end
