require 'test_helper'

module Workarea
  module Inventory
    class TransactionTest < TestCase
      setup :setup_order

      def setup_order
        @order_id = '124'
        @sku = 'SKU'
        @quantity = 2
        @items = { @sku => @quantity }
        @txn = Transaction.from_order(@order_id, @items)
      end

      def test_from_order
        assert_equal(@order_id, @txn.order_id)
        assert_equal(@sku, @txn.items.first.sku)
        assert_equal(@quantity, @txn.items.first.total)
      end

      def test_purchase_can_purchase_with_no_inventory
        @txn.purchase

        assert_equal(1, @txn.items.length)
        assert_equal(0, @txn.items.first.available)
        assert_equal(0, @txn.items.first.backordered)
      end

      def test_purchase_can_purchase_with_standard_inventory_setup
        create_inventory(id: @sku, policy: 'standard', available: @quantity)

        @txn.purchase
        assert_equal(1, @txn.items.length)
        assert_equal(@quantity, @txn.items.first.available)
        assert_equal(0, @txn.items.first.backordered)
      end

      def test_purchase_can_purchase_a_backordered_inventory
        create_inventory(
          id: @sku,
          policy: 'allow_backorder',
          available: 0,
          backordered: @quantity
        )

        @txn.purchase
        assert_equal(1, @txn.items.length)
        assert_equal(0, @txn.items.first.available)
        assert_equal(@quantity, @txn.items.first.backordered)
      end

      def test_purchase_error
        create_inventory(id: @sku, policy: 'standard', available: 0)
        @txn.purchase

        refute(@txn.captured?)
        assert(@txn.errors[:base].present?)
      end

      def test_rollback_rolls_back_each_item_and_marks_self_as_not_captured
        sku_1 = create_inventory(id: 'SKU1', available: 1, purchased: 0)
        sku_2 = create_inventory(id: 'SKU2', available: 1, purchased: 0)

        txn = Transaction.new(order_id: @order_id, captured: true)
        txn.items.build(sku: 'SKU1', total: 1)
        txn.items.build(sku: 'SKU2', total: 1)

        txn.purchase
        txn.rollback

        refute(txn.captured?)
        assert_equal(0, txn.items.first.available)
        assert_equal(0, txn.items.first.backordered)
        assert_equal(1, txn.items.first.total)
        assert_equal(0, txn.items.second.available)
        assert_equal(0, txn.items.second.backordered)
        assert_equal(1, txn.items.second.total)

        sku_1.reload
        assert_equal(1, sku_1.available)
        assert_equal(0, sku_1.purchased)

        sku_2.reload
        assert_equal(1, sku_2.available)
        assert_equal(0, sku_2.purchased)
      end

      def test_restock
        sku_1 = create_inventory(id: 'SKU1', available: 2, purchased: 0)
        sku_2 = create_inventory(id: 'SKU2', available: 1, purchased: 0)

        txn = Transaction.new(order_id: @order_id, captured: true)
        txn.items.build(sku: 'SKU1', total: 2)
        txn.items.build(sku: 'SKU2', total: 1)

        txn.purchase
        txn.restock('SKU1' => 1)

        assert(txn.captured?)
        assert_equal(1, txn.items.first.available)
        assert_equal(0, txn.items.first.backordered)
        assert_equal(1, txn.items.second.available)
        assert_equal(0, txn.items.second.backordered)

        sku_1.reload
        assert_equal(1, sku_1.available)
        assert_equal(1, sku_1.purchased)

        sku_2.reload
        assert_equal(0, sku_2.available)
        assert_equal(1, sku_2.purchased)
      end

      def test_backordered_restock
        sku = create_inventory(
          id: 'SKU1',
          policy: 'allow_backorder',
          available: 2,
          backordered: 2,
          purchased: 0
        )

        txn = Transaction.new(order_id: @order_id, captured: true)
        txn.items.build(sku: 'SKU1', total: 4)

        txn.purchase
        txn.restock('SKU1' => 3)

        assert(txn.captured?)
        assert_equal(0, txn.items.first.available)
        assert_equal(1, txn.items.first.backordered)

        sku.reload
        assert_equal(2, sku.available)
        assert_equal(1, sku.backordered)
        assert_equal(1, sku.purchased)
      end

      def test_backordered_restock_with_expired_backorder
        sku = create_inventory(
          id: 'SKU1',
          policy: 'allow_backorder',
          available: 2,
          backordered: 2,
          backordered_until: 1.week.from_now,
          purchased: 0
        )

        txn = Transaction.new(order_id: @order_id, captured: true)
        txn.items.build(sku: 'SKU1', total: 4)

        txn.purchase

        travel_to 2.weeks.from_now
        txn.restock('SKU1' => 3)

        assert(txn.captured?)
        assert_equal(0, txn.items.first.available)
        assert_equal(1, txn.items.first.backordered)

        sku.reload
        assert_equal(3, sku.available)
        assert_equal(0, sku.backordered)
        assert_equal(1, sku.purchased)
      end
    end
  end
end
