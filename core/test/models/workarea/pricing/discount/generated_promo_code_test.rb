require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class GeneratedPromoCodeTest < TestCase
        def test_generated_promo_code
          code = GeneratedPromoCode.generate_code('WL-')
          assert_match(/WL-/i, code)
        end

        def test_not_expired_scope
          code_list = create_code_list

          expired     = code_list.promo_codes.create!(code: 'exp',    expires_at: 1.day.ago)
          nil_expiry  = code_list.promo_codes.create!(code: 'nilexp', expires_at: nil)
          future      = code_list.promo_codes.create!(code: 'future', expires_at: 1.day.from_now)

          results = code_list.promo_codes.not_expired.to_a
          assert_includes(results, nil_expiry)
          assert_includes(results, future)
          refute_includes(results, expired)
        end
      end
    end
  end
end
