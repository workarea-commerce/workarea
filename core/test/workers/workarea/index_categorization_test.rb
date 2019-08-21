require 'test_helper'

module Workarea
  class IndexCategorizationTest < TestCase
    include TestCase::SearchIndexing

    def test_product_not_in_category_after_removal_of_all_rules
      product = create_product(name: 'Categorize This')
      category = create_category(
        product_rules: [
          { name: 'search', operator: 'equals', value: 'Categorize' }
        ]
      )
      IndexCategorization.perform(category)
      categories = Categorization.new(product).to_models

      assert_includes(categories, category)
      assert(category.product_rules.destroy_all)

      IndexCategorization.perform(category.reload)
      categories = Categorization.new(product).to_models

      refute_includes(categories, category)
    end
  end
end
