require 'test_helper'

module Workarea
  module Search
    class Admin
      class PricingDiscountTest < TestCase
        def test_as_document
          discount = create_order_total_discount(promo_codes: ['10PERCENTOFF'])

          2.times do |i|
            create_placed_order(id: i, promo_codes: ['10PERCENTOFF'])
            MarkDiscountsAsRedeemed.new.perform(i)
          end

          mapper = PricingDiscount.new(discount)
          assert_equal(2, mapper.as_document[:total_redemptions])
        end

        def test_keywords
          promo_codes = ['10PERCENTOFF']
          discount = create_order_total_discount(promo_codes: promo_codes)
          mapper = PricingDiscount.new(discount)

          promo_codes.each do |promo_code|
            assert_includes(mapper.keywords, promo_code.downcase)
          end
        end
      end
    end
  end
end
