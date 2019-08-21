require 'test_helper'

module Workarea
  module Search
    class TermsFacetTest < TestCase
      def test_value_to_param
        facet = TermsFacet.new(stub_everything, 'color')
        assert_equal('red', facet.value_to_param(:red))
      end
    end
  end
end
