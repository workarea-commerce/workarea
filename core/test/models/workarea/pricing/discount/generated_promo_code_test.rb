require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class GeneratedPromoCodeTest < TestCase
        def test_generated_promo_code
          code = GeneratedPromoCode.generate_code('WL-')
          assert_match(/WL-/i, code)
        end
      end
    end
  end
end
