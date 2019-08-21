require 'test_helper'

module Workarea
  class IndexProductTest < Workarea::TestCase
    include TestCase::SearchIndexing

    def test_perform
      product = create_product
      indexed_at = product.last_indexed_at

      IndexProduct.perform(product)
      product.reload

      refute_equal(indexed_at, product.last_indexed_at)
    end
  end
end
