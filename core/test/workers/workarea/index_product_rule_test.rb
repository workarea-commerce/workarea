require 'test_helper'

module Workarea
  class IndexProductRuleTest < TestCase
    include TestCase::SearchIndexing

    def test_find_product_list_from_rule
      Sidekiq::Callbacks.enable IndexProductRule do
        product = create_product(name: 'Categorize This')
        category = create_category
        category.product_rules.create!(
          { name: 'search', operator: 'equals', value: 'Categorize' }
        )
        categorization = Categorization.new(product)

        assert_includes(categorization.to_models, category)
      end
    end
  end
end
