require 'test_helper'

module Workarea
  class BulkIndexAdminTest < Workarea::TestCase

    def test_peform
      Workarea::Search::Admin.reset_indexes!

      Sidekiq::Callbacks.disable(IndexAdminSearch) do
        products = Array.new(2) { create_product }

        assert_equal(0, Search::Admin.count)
        BulkIndexAdmin.new.perform(
          products.first.class.name,
          products.map(&:id)
        )
        assert_equal(2, Search::Admin.count)

        content = Array.new(2) { create_content }
        content << Content.for(create_page) # should not be indexed

        BulkIndexAdmin.new.perform(
          content.first.class.name,
          content.map(&:id)
        )
        assert_equal(4, Search::Admin.count)
      end
    end
  end
end
