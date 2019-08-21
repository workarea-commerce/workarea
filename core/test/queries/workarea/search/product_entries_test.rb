require 'test_helper'

module Workarea
  module Search
    class ProductEntriesTest < TestCase
      def test_entries
        products = Array.new(3) { create_product }

        assert_equal(1, ProductEntries.new(products.first).entries.size)
        assert_equal(3, ProductEntries.new(products).entries.size)
      end
    end
  end
end
