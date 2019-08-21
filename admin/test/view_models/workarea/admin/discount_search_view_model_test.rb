require 'test_helper'

module Workarea
  module Admin
    class DiscountSearchViewModelTest < TestCase
      def test_sort_returns_redemptions_when_selected
        view_model = DiscountSearchViewModel.new(mock)
        refute_equal(Sort.redemptions.to_s, view_model.sort)

        view_model = DiscountSearchViewModel.new(
          mock,
          sort: Sort.redemptions.to_s
        )

        assert_equal(Sort.redemptions.to_s, view_model.sort)
      end

      def test_sorts_includes_redemptions
        assert_includes(
          DiscountSearchViewModel.new(mock).sorts,
          Sort.redemptions.to_a
        )
      end
    end
  end
end
