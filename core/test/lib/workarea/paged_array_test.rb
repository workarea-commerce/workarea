require 'test_helper'

module Workarea
  class PagedArrayTest < TestCase
    def test_can_be_initialized_with_defaults
      arr = PagedArray.new
      assert_equal(1, arr.current_page)
      assert_equal(0, arr.total_count)
    end
  end
end
