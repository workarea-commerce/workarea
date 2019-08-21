require 'test_helper'

module Workarea
  module Admin
    class ProductRulesPreviewViewModelTest < TestCase
      def test_only_uses_active_rules
        customization = create_search_customization(
          id: 'foo',
          product_rules: [
            { name: 'excluded_products', operator: 'equals', value: '1' },
            { name: 'excluded_products', operator: 'equals', value: '2', active: false }
          ]
        )

        view_model = ProductRulesPreviewViewModel.wrap(customization)
        assert(view_model.display_results?)
        assert_equal(customization.product_rules.take(1), view_model.search.params[:rules])

        category = create_category(
          product_rules: [
            { name: 'excluded_products', operator: 'equals', value: '1' },
            { name: 'excluded_products', operator: 'equals', value: '2', active: false }
          ]
        )

        view_model = ProductRulesPreviewViewModel.wrap(category)
        assert(view_model.display_results?)
        assert_equal(category.product_rules.take(1), view_model.search.params[:rules])

        category.product_rules.first.update!(active: false)
        view_model = ProductRulesPreviewViewModel.wrap(category)
        refute(view_model.display_results?)
        assert_empty(view_model.search.params[:rules])
      end
    end
  end
end
