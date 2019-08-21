require 'test_helper'

module Workarea
  class CleanRangeFacetsTest < TestCase
    def test_result
      cleaner = CleanRangeFacets.new(
        'price' => [
          { 'from' => '', 'to' => '9.99' },
          { 'from' => '10', 'to' => '' }
        ]
      )

      assert_equal(
        { 'price' => [{ 'to' => 9.99 }, { 'from' => 10 }] },
        cleaner.result
      )

      cleaner = CleanRangeFacets.new(
        'price' => [
          { 'from' => '', 'to' => '' },
          { 'from' => '10', 'to' => '' }
        ]
      )

      assert_equal({ 'price' => [{ 'from' => 10 }] }, cleaner.result)
    end
  end
end
