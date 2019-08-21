require 'test_helper'

module Workarea
  class CopyProductTest < TestCase
    def test_perform
      product = create_product(
        id: 'FOOBAR',
        name: 'Foo Bar Product',
        slug: 'foobar',
        variants: [{ sku: 'SKU1' }]
      )

      copy = CopyProduct.new(product, id: 'FOOBAZ').perform
      assert(copy.persisted?)
      assert_equal('Foo Bar Product', copy.name)
      assert_equal('SKU1', copy.variants.first.sku)
      assert_equal('FOOBAZ', copy.id)
      assert_equal('foo-bar-product', copy.slug)

      copy = CopyProduct.new(product, id: 'FOOBAZ').perform
      refute(copy.persisted?)
      assert(copy.errors.present?)
    end
  end
end
