require 'test_helper'

module Workarea
  class PricingOverrideParamsTest < TestCase
    def test_to_h
      params = PricingOverrideParams.new(subtotal_adjustment: '3.50')
      assert_equal({ 'subtotal_adjustment' => -3.5 }, params.to_h)

      user = create_user
      params = PricingOverrideParams.new(
        {
          subtotal_adjustment: '3.50',
          shipping_adjustment: '-1'
        },
        user
      )

      assert_equal(
        {
          'subtotal_adjustment' => -3.5,
          'shipping_adjustment' => 1.0,
          'created_by_id' => user.id
        },
        params.to_h
      )
    end
  end
end
