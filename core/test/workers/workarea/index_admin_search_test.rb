require 'test_helper'

module Workarea
  class IndexAdminSearchTest < TestCase
    def test_should_enqueue
      refute(IndexAdminSearch.should_enqueue?(create_order))
      assert(IndexAdminSearch.should_enqueue?(create_placed_order))
    end
  end
end
