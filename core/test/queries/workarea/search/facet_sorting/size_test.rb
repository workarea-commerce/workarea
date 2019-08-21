require 'test_helper'

module Workarea
  module Search
    class FacetSorting
      class SizeTest < TestCase
        def test_call
          Workarea.config.search_facet_size_sort = %(XS S M L XL)

          results = { 'M' => 50, 'L' => 40, 'S' => 30, 'XL' => 20, 'XS' => 10 }
          assert_equal(
            { 'XS' => 10, 'S' => 30, 'M' => 50, 'L' => 40, 'XL' => 20 },
            Size.call(:size, results)
          )

          results = { 'M' => 50, 'Small' => 40, 'XXL' => 30, 'XL' => 20 }
          assert_equal(
            { 'M' => 50, 'XL' => 20, 'Small' => 40, 'XXL' => 30 },
            Size.call(:size, results)
          )
        end
      end
    end
  end
end
