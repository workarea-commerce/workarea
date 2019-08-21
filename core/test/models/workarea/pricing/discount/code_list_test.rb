require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class CodeListTest < IntegrationTest
        def test_it_creates_promo_codes_upon_save
          code_list = create_code_list(count: 5)
          date_string = '2013/07/31'
          date = Date.parse(date_string)

          assert_equal(5, code_list.promo_codes.length)
          assert(code_list.reload.generation_complete?)

          code_list = create_code_list(expires_at: date_string)
          code_list.promo_codes.each do |code|
            assert_equal(date, code.expires_at.to_date)
          end
        end
      end
    end
  end
end
