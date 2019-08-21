require 'test_helper'

module Workarea
  module Inventory
    class CaptureTest < TestCase
      setup :set_sku

      def set_sku
        @sku = create_inventory(
          id: 'SKU1',
          policy: 'allow_backorder',
          available: 1,
          backordered: 2,
          purchased: 0,
          backordered_until: Time.zone.parse('2017/7/18')
        )
      end

      def test_updates_the_sku_properties
        capture = Capture.new(@sku, 1, 1)
        capture.perform

        assert(capture.result[:success])
        assert_equal(1, capture.result[:available])
        assert_equal(1, capture.result[:backordered])
        assert_equal(
          Time.zone.parse('2017/7/18'),
          capture.result[:backordered_until]
        )

        @sku.reload
        assert_equal(0, @sku.available)
        assert_equal(1, @sku.backordered)
        assert_equal(1, @sku.sellable)
        assert_equal(2, @sku.purchased)
      end

      def test_updates_the_sku_properties_without_sellable
        @sku.unset(:sellable)
        @sku.reload

        capture = Capture.new(@sku, 1, 1)
        capture.perform

        assert(capture.result[:success])
        assert_equal(1, capture.result[:available])
        assert_equal(1, capture.result[:backordered])
        assert_equal(
          Time.zone.parse('2017/7/18'),
          capture.result[:backordered_until]
        )

        @sku.reload
        assert_equal(0, @sku.available)
        assert_equal(1, @sku.backordered)
        assert_equal(0, @sku.sellable)
        assert_equal(2, @sku.purchased)
      end

      def test_handles_a_failure
        capture = Capture.new(@sku, 1, 1)
        Sku.update_all(available: 0, backordered: 0, sellable: 0)
        capture.perform

        refute(capture.result[:success])
        assert_equal(0, capture.result[:available])
        assert_equal(0, capture.result[:backordered])

        @sku.reload
        assert_equal(0, @sku.available)
        assert_equal(0, @sku.backordered)
        assert_equal(0, @sku.sellable)
        assert_equal(0, @sku.purchased)
      end

      def test_raises_an_error_if_about_to_capture_negative_inventory
        capture = Capture.new(@sku, 2, 1)
        assert_raises(InsufficientError) { capture.perform }

        @sku.reload
        assert_equal(1, @sku.available)
        assert_equal(2, @sku.backordered)
        assert_equal(3, @sku.sellable)
        assert_equal(0, @sku.purchased)

        capture = Capture.new(@sku, 1, 3)
        assert_raises(InsufficientError) { capture.perform }

        @sku.reload
        assert_equal(1, @sku.available)
        assert_equal(2, @sku.backordered)
        assert_equal(3, @sku.sellable)
        assert_equal(0, @sku.purchased)
      end
    end
  end
end
