require 'test_helper'

module Workarea
  class Storefront::ProductViewModel::CacheKeyTest < TestCase
    def test_omit_nil_options
      product = create_product(
        variants: [ { sku: 'SKU', details: { 'color' => %w(red) } } ]
      )
      options = { 'color' => 'red', nil => :foo }
      key = Storefront::ProductViewModel::CacheKey.new(product, options)

      assert_includes(key.to_s, 'red')
      refute_includes(key.to_s, 'foo')
    end
  end
end
