require 'test_helper'

module Workarea
  class IndexSkusTest < Workarea::TestCase
    include TestCase::SearchIndexing

    def test_touching_the_product
      create_product(variants: [{ sku: 'SKU' }])
      assert(Search::Storefront.count.zero?)
      IndexSkus.new.perform('SKU')
      assert_equal(Search::Storefront.count, 1)
    end
  end
end
