require 'test_helper'

module Workarea
  class BulkAction
    class SequentialProductEditTest < Workarea::IntegrationTest
      def test_finding_product_by_index
        one = create_product
        two = create_product(name: 'Foo A')
        three = create_product(name: 'Foo B')
        four = create_product(name: 'Foo C')

        edit = SequentialProductEdit.new(
          ids: [
            one.to_global_id,
            two.to_global_id,
            three.to_global_id,
            four.to_global_id
          ]
        )

        assert_equal(one, edit.find_product(0))
        assert_equal(two, edit.find_product(1))
        assert_equal(three, edit.find_product(2))
        assert_equal(four, edit.find_product(3))

        assert_equal(one, edit.find_product('0'))
        assert_equal(two, edit.find_product('1'))
        assert_equal(three, edit.find_product('2'))
        assert_equal(four, edit.find_product('3'))

        query = Search::AdminProducts.new(q: 'foo', sort: 'name_asc')
        edit = SequentialProductEdit.new(query_id: query.to_global_id)

        assert_equal(two, edit.find_product(0))
        assert_equal(three, edit.find_product(1))
        assert_equal(four, edit.find_product(2))
      end
    end
  end
end
