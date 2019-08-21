require 'test_helper'

module Workarea
  class KeepProductIndexFreshTest < TestCase
    include SearchIndexing

    setup :set_config
    teardown :unset_config

    def set_config
      @current = Workarea.config.stale_products_size
      Workarea.config.stale_products_size = 1
    end

    def unset_config
      Workarea.config.stale_products_size = @current
    end

    def test_indexes_never_indexed_products
      assert_equal(0, Search::Storefront.count)

      3.times { create_product }
      KeepProductIndexFresh.new.perform

      assert_equal(1, Search::Storefront.count)
    end

    def test_indexes_stale_products
      product_1 = create_product
      product_2 = create_product
      product_3 = create_product

      IndexProduct.perform(product_1)
      IndexProduct.perform(product_2)
      IndexProduct.perform(product_3)

      current_last_indexed_at = product_1.reload.last_indexed_at

      travel_to(Time.current + 1.second)
      KeepProductIndexFresh.new.perform

      product_1.reload
      assert(product_1.last_indexed_at > current_last_indexed_at)
    end
  end
end
