require 'test_helper'

module Workarea
  module Admin
    class PromoCodeViewModelTest < TestCase
      def test_list_name_returns_the_codes_list_name
        list = create_code_list(name: 'Test List', count: 1)
        promo_code = Pricing::Discount::GeneratedPromoCode.create(
          code: 'test code',
          code_list: list
        )
        view_model = Admin::PromoCodeViewModel.new(promo_code)
        assert_equal('Test List', view_model.list_name)
      end
    end
  end
end
