require 'test_helper'

module Workarea
  module Search
    class AdminDiscountsTest < TestCase
      include SearchIndexing

      def test_sort
        one = create_product_discount(name: 'Foo')
        two = create_product_discount(name: 'Bar')
        three = create_product_discount(name: 'Baz')

        5.times { two.log_redemption('bcrouse@workarea.com') }
        3.times { three.log_redemption('bcrouse@workarea.com') }
        2.times { one.log_redemption('bcrouse@workarea.com') }

        IndexAdminSearch.perform(one)
        IndexAdminSearch.perform(two)
        IndexAdminSearch.perform(three)

        search = AdminDiscounts.new(sort: 'redemptions')
        assert_equal([two, three, one], search.results)
      end
    end
  end
end
