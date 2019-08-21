require 'test_helper'

module Workarea
  module Search
    class RangeFacetTest < TestCase
      def test_value_to_param
        facet = RangeFacet.new(stub_everything, 'price')
        assert_equal('10-20',facet.value_to_param('10-20'))
        assert_equal('10-20',facet.value_to_param(from: 10, to: 20))
        assert_equal('*-20',facet.value_to_param(to: 20))
        assert_equal('10-*',facet.value_to_param(from: 10))
      end
    end
  end
end
