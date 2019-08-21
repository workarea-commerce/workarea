require 'test_helper'

module Workarea
  class IndexFulfillmentChangesTest < Workarea::TestCase
    include TestCase::SearchIndexing

    def test_indexing_from_fulfillment
      create_placed_order
      assert(Search::Admin.count.zero?)
      IndexFulfillmentChanges.new.perform(Fulfillment.first.id)
      assert_equal(Search::Admin.count, 1)
    end
  end
end
