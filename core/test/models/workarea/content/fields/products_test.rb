require 'test_helper'

module Workarea
  class Content
    module Fields
      class ProductsTest < TestCase
        def test_typecast
          result = Products.new('foo').typecast([1, 2, 3])
          assert_equal(%w(1 2 3), result)
        end
      end
    end
  end
end
