require 'test_helper'

module Workarea
  module Search
    class AdminTest < TestCase
      def test_keywords_include_tags_when_available
        tag = 'foo'
        product = Search::Admin.for(create_product(tags: [tag]))
        order = Search::Admin.for(create_placed_order)

        assert_includes(product.keywords, tag)
        assert_includes(product.keywords, product.model.id)
        assert_includes(order.keywords, order.model.id)
        refute_includes(order.keywords, tag)
      end
    end
  end
end
