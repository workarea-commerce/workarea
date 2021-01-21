require 'test_helper'

module Workarea
  class Order
    class QueriesTest < TestCase
      attr_reader :email, :user

      setup :setup_user

      def setup_user
        @email = 'bcrouse@workarea.com'
        @user = create_user(email: email)
      end

      def test_expired_and_abandoned
        a_long_long_time_ago = (Workarea.config.order_expiration_period + 1.day).ago

        open_order = create_order
        open_order.update_attribute(:updated_at, a_long_long_time_ago)

        checkout_order = create_order
        checkout_order.update_attribute(:checkout_started_at, a_long_long_time_ago)
        checkout_order.update_attribute(:updated_at, a_long_long_time_ago)

        placed_order = create_placed_order
        placed_order.update_attribute(:updated_at, a_long_long_time_ago)
        placed_order.update_attribute(:checkout_started_at, a_long_long_time_ago)

        assert_includes(Order.expired, open_order)
        refute_includes(Order.expired_in_checkout, open_order)

        assert_includes(Order.expired_in_checkout, checkout_order)
        refute_includes(Order.expired, checkout_order)

        refute_includes(Order.expired, placed_order)
        refute_includes(Order.expired_in_checkout, placed_order)
      end

      def test_find_current_when_logged_in
        previous_order = create_order(user_id: 'foo')
        result = Order.find_current(user_id: 'foo')

        assert(previous_order.persisted?)
        assert_kind_of(Order, result)
        assert(result.persisted?)
        assert_equal(previous_order, result)
      end

      def test_find_current_when_guest
        result = Order.find_current(user_id: 'foo')

        assert_kind_of(Order, result)
        assert_equal('foo', result.user_id)
        refute(result.persisted?)
      end

      def test_find_current_unplaced
        order = create_placed_order
        result = Order.find_current(id: order.id, user_id: 'foo')

        assert_kind_of(Order, result)
        refute_equal(result, order)
        assert_equal('foo', result.user_id)
      end

      def test_find_current_missing_id
        Order.where(user_id: '1234').delete_all
        result = Order.find_current(id: '1234', user_id: 'foo')

        assert_kind_of(Order, result)
        refute(result.persisted?)
        assert_equal('foo', result.user_id)
      end

      def test_recent
        placed_orders = [
          Order.create!(user_id: user.id, placed_at: Time.current),
          Order.create!(user_id: user.id, placed_at: 1.minute.ago),
          Order.create!(user_id: user.id, placed_at: 2.minutes.ago)
        ]
        other_user_order = Order.create!(user_id: 'other_id', placed_at: 1.hour.ago)
        _old_order = Order.create!(user_id: user.id, placed_at: 2.hours.ago)
        unplaced_order = Order.create!(user_id: user.id, placed_at: nil)

        assert_equal(3, Order.recent(user.id).options[:limit])
        assert_equal(placed_orders, Order.recent(user.id).to_a)
        refute_equal(unplaced_order, Order.recent(user.id, 5).to_a)
        refute_equal(other_user_order, Order.recent(user.id, 10).to_a)
      end

      def test_totals
        Order.create!(email: email, total_price: 1.to_m)
        Order.create!(email: email, placed_at: 1.hour.ago, total_price: 1.to_m)
        Order.create!(email: email, placed_at: 5.hours.ago, total_price: 1.to_m)

        assert_equal(2.to_m, Order.totals)
        assert_equal(1.to_m, Order.totals(2.hours.ago, Time.current))
      end

      def test_total_placed
        Order.create!(email: email)
        Order.create!(email: email, placed_at: 1.hour.ago)
        Order.create!(email: email, placed_at: 5.hours.ago)

        assert_equal(2, Order.total_placed)
        assert_equal(1, Order.total_placed(2.hours.ago, Time.current))
      end

      def test_recent_placed
        Order.create!(email: email)
        Order.create!(email: email, placed_at: 1.hour.ago)
        Order.create!(email: email, placed_at: 5.hours.ago)

        assert_equal(2, Order.recent_placed.to_a.length)
        assert_equal(1, Order.recent_placed(1).to_a.length)
      end

      def test_need_reminding
        placed = Order.create!(placed_at: 1.hour.ago)
        reminded = Order.create!(reminded_at: 1.hour.ago)
        fraud = Order.create!(fraud_suspected_at: 1.hour.ago)
        not_abandoned = Order.create!(email: email)
        abandoned = Order.create!(email: email, checkout_started_at: 2.hours.ago, items: [{ product_id: '1', sku: 2 }])
        empty = Order.create!(email: email, checkout_started_at: 2.hours.ago, items: [])
        no_info = Order.create!
        results = Order.need_reminding.to_a

        refute_includes(results, placed)
        refute_includes(results, reminded)
        refute_includes(results, fraud)
        refute_includes(results, no_info)
        refute_includes(results, not_abandoned)
        refute_includes(results, empty)
        assert_includes(results, abandoned)
      end

      def test_average_order_value
        Order.create!(email: email, total_value: 1.to_m)
        Order.create!(email: email, placed_at: 1.hour.ago, total_value: 1.to_m, total_price: 1.to_m)
        Order.create!(email: email, placed_at: 5.hours.ago, total_value: 2.to_m, total_price: 3.to_m)

        assert_equal(2.to_m, Order.average_order_value)
        assert_equal(1.to_m, Order.average_order_value(2.hours.ago, Time.current))
      end
    end
  end
end
