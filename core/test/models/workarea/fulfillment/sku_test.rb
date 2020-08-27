require 'test_helper'

module Workarea
  class Fulfillment
    class SkuTest < TestCase
      def test_validation
        sku = Sku.new(id: 'SKU1', policy: 'shipping')
        assert(sku.valid?)

        sku.policy = 'download'
        refute(sku.valid?)
        assert(sku.errors['file'].present?)

        sku.file = product_image_file_path
        assert(sku.valid?)
      end

      def test_find_or_initialize_all
        create_fulfillment_sku(id: 'sku1')
        skus = Sku.find_or_initialize_all(%w(sku1 sku2))

        assert_equal(2, skus.size)
        assert(skus.first.persisted?)
        refute(skus.second.persisted?)
      end

      def test_process!
        order = Order.new
        item = order.items.build(sku: 'SKU1')

        sku = Sku.new(id: 'SKU1', policy: 'shipping')
        assert_nil(sku.process!(order_item: item))

        sku = Sku.new(id: 'SKU1', policy: 'foobar')
        assert_raises(Sku::InvalidPolicy) { sku.process!(order_item: item) }

        sku = Sku.new(id: 'SKU1', policy: 'download')
        sku.process!(order_item: item)
        assert_equal(1, Fulfillment::Token.count)
      end

      def test_downloadable?
        sku = Sku.new(id: 'SKU1', policy: 'shipping')
        refute(sku.downloadable?)

        sku.policy = 'download'
        refute(sku.downloadable?)

        sku.file = product_image_file_path
        assert(sku.downloadable?)
      end
    end
  end
end
