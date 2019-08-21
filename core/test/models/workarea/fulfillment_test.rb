require 'test_helper'

module Workarea
  class FulfillmentTest < TestCase
    setup :stub_mailers

    # We don't care to test mailers here, they're tested as part of integration
    # and/or system tests.
    def stub_mailers
      Storefront::FulfillmentMailer.stubs(:shipped).returns(stub_everything)
      Storefront::FulfillmentMailer.stubs(:canceled).returns(stub_everything)
    end

    def test_find_statuses
      assert_equal(
        { '1234' => :not_available, '5678' => :not_available },
        Fulfillment.find_statuses(*%w(1234 5678))
      )

      fulfillment = Fulfillment.new(id: '1234')
      fulfillment.items.build(
        quantity: 1,
        events: [{ status: 'shipped', quantity: 1 }]
      )
      fulfillment.save!

      fulfillment = Fulfillment.new(id: '5678')
      fulfillment.items.build(
        quantity: 2,
        events: [{ status: 'shipped', quantity: 1 }]
      )
      fulfillment.save!

      assert_equal(
        { '1234' => :shipped, '5678' => :partially_shipped },
        Fulfillment.find_statuses(*%w(1234 5678))
      )
    end

    def test_status_is_not_available_if_not_persisted
      assert_equal(:not_available, Fulfillment.new.status)
    end

    def test_find_package
      order = create_placed_order

      fulfillment = Fulfillment.find(order.id)
      fulfillment.ship_items('abc', [{ 'id' => order.items.first.id, 'quantity' => 2 }])

      assert_equal('abc', fulfillment.find_package('abc').tracking_number)
      assert_equal('abc', fulfillment.find_package('ABC').tracking_number)
      assert_equal('abc', fulfillment.find_package('AbC').tracking_number)

      assert_nil(fulfillment.find_package('fake'))
      assert_nil(fulfillment.find_package(nil))
    end

    def test_status_is_open_if_there_are_no_items
      assert_equal(:open, Fulfillment.create!.status)
    end

    def test_status_is_shipped_when_all_items_are_shipped
      fulfillment = Fulfillment.create!(
        items: [
          {
            quantity: 1,
            events: [{ status: 'shipped', quantity: 1 }]
          }
        ]
      )
      assert_equal(:shipped, fulfillment.status)
    end

    def test_status_is_shipped_if_all_non_canceled_items_are_shipped
      fulfillment = Fulfillment.create!(
        items: [
          {
            quantity: 2,
            events: [
              { status: 'shipped', quantity: 1 },
              { status: 'canceled', quantity: 1 }
            ]
          }
        ]
      )

      assert_equal(:shipped, fulfillment.status)
    end

    def test_status_is_partially_shipped_when_only_some_are_shipped
      fulfillment = Fulfillment.create!(
        items: [
          quantity: 2,
          events: [{ status: 'shipped', quantity: 1 }]
        ]
      )

      assert_equal(:partially_shipped, fulfillment.status)
    end

    def test_status_is_canceled_if_all_items_are_canceled
      fulfillment = Fulfillment.create!(
        items: [
          {
            quantity: 1,
            events: [{ status: 'canceled', quantity: 1 }]
          }
        ]
      )

      assert_equal(:canceled, fulfillment.status)
    end

    def test_marked_item_shipped
      fulfillment = Fulfillment.new(items: [{ order_item_id: '1', quantity: 1 }])
      event = fulfillment.mark_item_shipped(
        id: '1',
        quantity: 1,
        tracking_number: '1Z',
        foo: 'bar'
      )

      assert_equal('shipped', event.status)
      assert_equal(1, event.quantity)
      assert_equal(
        { 'tracking_number' => '1Z', 'foo' => 'bar' },
        event.data
      )
    end

    def test_ship_items_adds_the_shipped_events_to_the_items
      fulfillment = Fulfillment.new(items: [{ order_item_id: '1' }])
      fulfillment.ship_items('1Z', [{ 'id' => '1', 'quantity' => 1 }])

      refute(fulfillment.new_record?)
      assert_equal(1, fulfillment.items.first.events.length)
      assert_equal('shipped', fulfillment.items.first.events.first.status)
      assert_equal('1z', fulfillment.items.first.events.first.data[:tracking_number])
      assert(fulfillment.items.first.events.first.created_at.present?)
    end

    def test_ship_items_ignores_items_with_quantity_zero
      fulfillment = Fulfillment.new(items: [
        { order_item_id: '1' },
        { order_item_id: '2' }
      ])
      fulfillment.ship_items('1Z', [
        { 'id' => '1', 'quantity' => 1 },
        { 'id' => '2', 'quantity' => 0 }
      ])

      assert_equal(0, fulfillment.items.last.events.length)
    end

    def test_cancel_items_adds_the_canceled_events_to_the_items
      fulfillment = Fulfillment.new(
                      items: [
                        { order_item_id: '1' },
                        { order_item_id: '2' }
                      ]
                    )
      fulfillment.cancel_items([
        { 'id' => '1', 'quantity' => 1 },
        { 'id' => '2', 'quantity' => 0 }
      ])

      refute(fulfillment.new_record?)
      assert_equal(1, fulfillment.items.first.events.length)
      assert_equal('canceled', fulfillment.items.first.events.first.status)
      assert_equal(0, fulfillment.items.second.events.length)
      assert(fulfillment.items.first.events.first.created_at.present?)
    end

    def test_pending_returns_items_that_are_not_completely_shipped
      fulfillment = Fulfillment.new
      fulfillment.items.build(
        order_item_id: '1',
        quantity: 1,
        events: [{ status: 'shipped', quantity: 1 }]
      )
      item_1 = fulfillment.items.build(order_item_id: '2', quantity: 2)
      item_2 = fulfillment.items.build(order_item_id: '3', quantity: 1)

      assert_includes(fulfillment.pending_items, item_1)
      assert_includes(fulfillment.pending_items, item_2)
    end

    def test_pending_does_not_include_items_with_0
      fulfillment = Fulfillment.new(items: [{ order_item_id: '1' }])
      assert_empty(fulfillment.pending_items)
    end

    def test_canceled_items_returns_items_with_their_quantity_canceled
      fulfillment = Fulfillment.new
      fulfillment.items.build(order_item_id: '1', quantity: 1)
      item_1 = fulfillment.items.build(
        order_item_id: '2',
        quantity: 2,
        events: [{ status: 'canceled', quantity: 2 }]
      )
      item_2 = fulfillment.items.build(
        order_item_id: '3',
        quantity: 1,
        events: [{ status: 'canceled', quantity: 1 }]
      )

      assert_includes(fulfillment.canceled_items, item_1)
      assert_includes(fulfillment.canceled_items, item_2)
    end

    def test_canceled_items_does_not_include_items_with_0_canceled
      fulfillment = Fulfillment.new(items: [{ order_item_id: '1' }])
      fulfillment.cancel_items([{'id' => '1', 'quantity' => 0}])
      assert_equal([], fulfillment.canceled_items)
    end
  end
end
