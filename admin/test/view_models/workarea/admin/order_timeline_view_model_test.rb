require 'test_helper'

module Workarea
  module Admin
    class OrderTimelineViewModelTest < TestCase
      def test_ignores_blank_timestamps
        order = OrderViewModel.wrap(Order.new)
        assert(OrderTimelineViewModel.new(order).empty?)
      end

      def test_creation_entry
        user = create_user
        order = Order.new(user_id: user.id, created_at: Time.current)
        timeline = OrderTimelineViewModel.new(OrderViewModel.wrap(order))

        assert(timeline.entries.one?)
        assert_equal(:created, timeline.entries.first.slug)
        assert_equal(user, timeline.entries.first.modifier)
      end

      def test_impersonated_checkout
        user = create_user(admin: true)
        order = Order.new(checkout_by_id: user.id, created_at: Time.current)
        timeline = OrderTimelineViewModel.new(OrderViewModel.wrap(order))

        assert(timeline.entries.one?)
        assert_equal(:created, timeline.entries.first.slug)
        assert_equal(user, timeline.entries.first.modifier)
      end

      def test_placed_entry
        user = create_user
        order = Order.new(user_id: user.id, placed_at: Time.current)
        timeline = OrderTimelineViewModel.new(OrderViewModel.wrap(order))

        assert(timeline.entries.one?)
        assert_equal(:placed, timeline.entries.first.slug)
        assert_equal(user, timeline.entries.first.modifier)
      end

      def test_payment_entries
        user = create_user
        order = OrderViewModel.wrap(Order.new)
        payment = create_payment(id: order.id, store_credit: { amount: 5.to_m })
        transaction = create_transaction(
          payment: payment,
          tender_id: payment.store_credit.id,
          action: 'authorize'
        )

        transaction.audit_log_entries.create!(modifier: user)
        timeline = OrderTimelineViewModel.new(order)

        assert(timeline.entries.one?)
        assert_equal(:authorize, timeline.entries.first.slug)
        assert_equal(user, timeline.entries.first.modifier)
      end

      def test_shipped_fulfillment_entries
        user = create_user
        occured_at = Time.current
        order = OrderViewModel.wrap(Order.new)
        fulfillment = Fulfillment.create!(
          id: order.id,
          items: [
            {
              quantity: 1,
              events: [
                { status: 'shipped', quantity: 1, created_at: occured_at }
              ]
            }
          ]
        )
        fulfillment.audit_log_entries.create!(
          modifier: user,
          created_at: occured_at
        )
        timeline = OrderTimelineViewModel.new(order)

        assert(timeline.entries.one?)
        assert_equal(:shipped, timeline.entries.first.slug)
        assert_equal(user, timeline.entries.first.modifier)
      end

      def test_canceled_fulfillment_entries
        order = OrderViewModel.wrap(Order.new)
        Fulfillment.create!(
          id: order.id,
          items: [
            {
              quantity: 1,
              events: [
                { status: 'canceled', quantity: 1, created_at: Time.current }
              ]
            }
          ]
        )

        timeline = OrderTimelineViewModel.new(order)

        assert(timeline.entries.one?)
        assert_equal(:canceled_fulfillment, timeline.entries.first.slug)
      end

      def test_fulfillment_entry_grouping
        occured_at = Time.current
        order = OrderViewModel.wrap(Order.new)
        Fulfillment.create!(
          id: order.id,
          items: [
            {
              quantity: 2,
              events: [
                { status: 'shipped', quantity: 1, created_at: occured_at },
                { status: 'canceled', quantity: 1, created_at: occured_at }
              ]
            }
          ]
        )

        timeline = OrderTimelineViewModel.new(order)
        assert_equal(2, timeline.entries.length)
      end

      def test_entries_sorts_by_occurrance
        test_at = 10.minutes.ago
        order = create_placed_order(placed_at: 1.minute.ago)
        fulfillment = Fulfillment.find(order.id)
        fulfillment.items.first.events.build(
          status: 'shipped',
          quantity: 1,
          created_at: test_at,
          updated_at: test_at
        )
        fulfillment.save!

        order = OrderViewModel.wrap(order)
        timeline = OrderTimelineViewModel.new(order)
        assert_equal(:shipped, timeline.entries.last.slug)
      end

      def test_fake_user_for_guest_checkout
        order = create_order(email: 'foo@bar.com', created_at: Time.current)
        create_payment(
          id: order.id,
          address: {
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            street_2: 'Second Floor',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US',
            phone_number: '2159251800'
          }
        )

        timeline = OrderTimelineViewModel.new(OrderViewModel.wrap(order))

        assert(timeline.entries.one?)
        assert_equal(:created, timeline.entries.first.slug)
        refute(timeline.entries.first.modifier.persisted?)
        assert_equal('foo@bar.com', timeline.entries.first.modifier.email)
        assert_equal('Ben Crouse', timeline.entries.first.modifier.name)
      end

      def test_comment_entries
        user = create_user
        order = Order.new(created_at: 1.day.ago)
        comment = create_comment(commentable: order, author_id: user.id)
        timeline = OrderTimelineViewModel.new(OrderViewModel.wrap(order))

        assert_equal(2, timeline.entries.size)
        assert_equal(:comment, timeline.entries.first.slug)
        assert_equal(user, timeline.entries.first.modifier)
        assert_equal(comment, timeline.entries.first.model.model)
      end

      def test_copied_entries
        user = create_user
        order = create_placed_order(placed_at: 1.day.ago)
        copy = CopyOrder.new(order)
        Mongoid::AuditLog.record(user) { copy.perform }
        timeline = OrderTimelineViewModel.new(OrderViewModel.wrap(order))

        assert_equal(4, timeline.entries.size)
        assert_equal(:copied, timeline.entries.first.slug)
        assert_equal(user, timeline.entries.first.modifier)
        assert_equal(copy.new_order, timeline.entries.first.model)
      end
    end
  end
end
