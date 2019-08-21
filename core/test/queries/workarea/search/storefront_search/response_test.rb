require 'test_helper'

module Workarea
  module Search
    class StorefrontSearch
      class ResponseTest < TestCase
        def test_only_uses_active_product_rules
          customization = create_search_customization(
            id: 'foo',
            product_rules: [
              { name: 'excluded_products', operator: 'equals', value: '1' },
              { name: 'excluded_products', operator: 'equals', value: '2', active: false }
            ]
          )

          response = Response.new(q: 'foo', customization: customization)
          assert_equal(customization.product_rules.take(1), response.query.params[:rules])

          customization.product_rules.first.update!(active: false)
          response.reset!(q: 'foo')
          assert_empty(response.query.params[:rules])
        end
      end
    end
  end
end
