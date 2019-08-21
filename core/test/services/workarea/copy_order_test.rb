require 'test_helper'

module Workarea
  class CopyOrderTest < IntegrationTest
    setup :set_order

    def set_order
      @cart = create_order(
        items: [
          { product_id: 'PRODUCT1', sku: 'SKU1', quantity: 2 },
          { product_id: 'PRODUCT2', sku: 'SKU2', quantity: 3 }
        ]
      )

      @placed_order = create_placed_order
    end

    def test_basic_behavior
      copy = CopyOrder.new(@cart).tap(&:perform)

      assert(copy.new_order.persisted?)
      assert_not_equal(@cart, copy.new_order)
      assert_equal(@cart.items, copy.new_order.items)

      copy = CopyOrder.new(@placed_order).tap(&:perform)

      assert(copy.new_order.persisted?)
      assert_not_equal(@placed_order, copy.new_order)
      refute(copy.new_order.placed?)
      assert_equal(@placed_order.items, copy.new_order.items)
    end

    def test_canceling_the_original
      CopyOrder.new(@cart, cancel_original: true).tap(&:perform)
      refute(@cart.reload.canceled?)

      CopyOrder.new(@placed_order, cancel_original: true).tap(&:perform)
      assert(@placed_order.reload.canceled?)
      assert_equal(:canceled, Fulfillment.find(@placed_order.id).status)
    end

    def test_copying_checkout_info
      copy = CopyOrder.new(@placed_order).tap(&:perform)

      assert(copy.new_payment.persisted?)
      assert_equal(copy.new_order.id, copy.new_payment.id)

      assert(copy.new_shippings.all?(&:persisted?))
      assert(copy.new_shippings.all? { |s| s.order_id == copy.new_order.id })
    end

    def test_sets_copied_from
      copy = CopyOrder.new(@placed_order).tap(&:perform)
      assert_equal(copy.new_order.copied_from, @placed_order)
    end

    def test_copying_a_canceled_order
      @placed_order.cancel
      copy = CopyOrder.new(@placed_order).tap(&:perform)
      refute(copy.new_order.canceled?)
    end

    def test_resetting_timestamps
      @placed_order.placed_at = Time.current
      @placed_order.canceled_at = Time.current
      @placed_order.created_at = Time.current
      @placed_order.updated_at = Time.current
      @placed_order.checkout_started_at = Time.current
      @placed_order.save!

      copy = CopyOrder.new(@placed_order).tap(&:perform)

      assert_not_equal(copy.new_order.placed_at, @placed_order.placed_at)
      assert_not_equal(copy.new_order.canceled_at, @placed_order.canceled_at)
      assert_not_equal(copy.new_order.created_at, @placed_order.created_at)
      assert_not_equal(copy.new_order.updated_at, @placed_order.updated_at)
      assert_not_equal(
        copy.new_order.checkout_started_at,
        @placed_order.checkout_started_at
      )
    end

    def test_anonymize!
      user = create_user
      placed_order = create_placed_order(id: '2356', user_id: user.id, email: user.email)

      copy = CopyOrder.new(placed_order).tap(&:perform)
      assert(copy.new_order.email.present?)
      assert(copy.new_order.user_id.present?)
      assert(copy.new_payment.persisted?)
      assert(copy.new_shippings.all?(&:persisted?))

      copy.anonymize!
      refute(copy.new_order.email.present?)
      refute(copy.new_order.user_id.present?)
      refute(copy.new_payment.persisted?)
      assert(copy.new_shippings.none?(&:persisted?))
    end
  end
end
