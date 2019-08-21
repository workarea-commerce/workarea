require 'test_helper'

module Workarea
  class BulkIndexProductsTest < Workarea::TestCase

    def test_peform
      Workarea::Search::Storefront.reset_indexes!

      Sidekiq::Callbacks.disable(IndexProduct) do
        products = Array.new(2) { create_product }

        assert_equal(0, Search::Storefront.count)
        BulkIndexProducts.new.perform(products.map(&:id))
        assert_equal(2, Search::Storefront.count)
      end
    end
  end
end
