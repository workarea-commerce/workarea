require 'test_helper'

module Workarea
  module Metrics
    class UserTest < TestCase
      def test_save_order
        first = Time.zone.local(2018, 11, 14)
        User.save_order(
          email: 'bcrouse@workarea.com',
          revenue: 5.to_m,
          discounts: -1.to_m,
          at: first
        )

        assert_equal(1, User.count)

        user = User.first
        assert_equal(first.to_i, user.first_order_at.to_i)
        assert_equal(first.to_i, user.last_order_at.to_i)
        assert_equal(1, user.orders)
        assert_equal(5, user.revenue)
        assert_equal(-1, user.discounts)

        last = Time.zone.local(2018, 11, 15)
        User.save_order(
          email: 'bcrouse@workarea.com',
          revenue: 3.to_m,
          discounts: -1.to_m,
          at: last
        )

        assert_equal(1, User.count)

        user.reload
        assert_equal(first.to_i, user.first_order_at.to_i)
        assert_equal(last.to_i, user.last_order_at.to_i)
        assert_equal(2, user.orders)
        assert_equal(8, user.revenue)
        assert_equal(-2, user.discounts)
      end

      def test_save_cancellation
        first = Time.zone.local(2018, 11, 14)

        User.save_order(
          email: 'bcrouse@workarea.com',
          revenue: 50.to_m,
          at: first
        )

        User.save_cancellation(
          email: 'bcrouse@workarea.com',
          refund: -5.to_m,
          at: first
        )

        assert_equal(1, User.count)

        user = User.first
        assert_equal(1, user.cancellations)
        assert_equal(-5, user.refund)
        assert_equal(45, user.revenue)

        last = Time.zone.local(2018, 11, 15)

        User.save_cancellation(
          email: 'bcrouse@workarea.com',
          refund: -3.to_m,
          at: last
        )

        assert_equal(1, User.count)

        user.reload
        assert_equal(2, user.cancellations)
        assert_equal(-8, user.refund)
        assert_equal(42, user.revenue)
      end

      def test_save_affinity
        2.times do
          User.save_affinity(
            id: 'bcrouse@workarea.com',
            action: 'viewed',
            product_ids: %w(foo bar),
            category_ids: 'baz',
            search_ids: %(qoo)
          )
        end

        assert_equal(1, User.count)
        user = User.first
        assert_equal('bcrouse@workarea.com', user.id)
        assert_equal(%w(foo bar foo bar), user.viewed.product_ids)
        assert_equal(%w(baz baz), user.viewed.category_ids)
        assert_equal(%w(qoo qoo), user.viewed.search_ids)

        assert_changes -> { user.reload.updated_at } do
          User.save_affinity(
            id: 'bcrouse@workarea.com',
            action: 'purchased',
            product_ids: %w(foo bar)
          )
        end

        assert_equal(1, User.count)
        user.reload
        assert_equal('bcrouse@workarea.com', user.id)
        assert_equal(%w(foo bar foo bar), user.viewed.product_ids)
        assert_equal(%w(baz baz), user.viewed.category_ids)
        assert_equal(%w(qoo qoo), user.viewed.search_ids)
        assert_equal(%w(foo bar), user.purchased.product_ids)
      end

      def test_save_affinity_limits_storage
        Workarea.config.max_affinity_items = 3

        4.times do
          User.save_affinity(
            id: 'bcrouse@workarea.com',
            action: 'viewed',
            product_ids: %w(foo bar),
            category_ids: 'baz',
            search_ids: %(qoo)
          )
        end

        user = User.first
        assert_equal(%w(foo bar foo), user.viewed.product_ids)
        assert_equal(%w(baz baz baz), user.viewed.category_ids)
        assert_equal(%w(qoo qoo qoo), user.viewed.search_ids)
      end

      def test_merging_metrics
        freeze_time

        first = User.create!(
          first_order_at: 2.weeks.ago,
          last_order_at: 1.day.ago,
          orders: 2,
          revenue: 100,
          discounts: -10,
          average_order_value: 50,
          cancellations: 1,
          refund: -20,
          viewed: { product_ids: ['foo'], category_ids: ['bar'], search_ids: ['baz'] },
          purchased: { product_ids: ['qoo'], category_ids: ['quo'], search_ids: ['qux'] }
        )

        first.merge!(User.new)
        first.reload
        assert_equal(1, Metrics::User.count)
        assert_equal(2.weeks.ago, first.first_order_at)
        assert_equal(1.day.ago, first.last_order_at)
        assert_equal(2, first.orders)
        assert_equal(100, first.revenue)
        assert_equal(-10, first.discounts)
        assert_equal(50, first.average_order_value)
        assert_equal(1, first.cancellations)
        assert_equal(-20, first.refund)
        assert_equal(['foo'], first.viewed.product_ids)
        assert_equal(['bar'], first.viewed.category_ids)
        assert_equal(['baz'], first.viewed.search_ids)
        assert_equal(['qoo'], first.purchased.product_ids)
        assert_equal(['quo'], first.purchased.category_ids)
        assert_equal(['qux'], first.purchased.search_ids)

        second = User.create!(id: 'foo').tap { |u| u.merge!(first) }
        second.reload
        assert_equal(1, Metrics::User.count)
        assert_equal(2.weeks.ago, second.first_order_at)
        assert_equal(1.day.ago, second.last_order_at)
        assert_equal(2, second.orders)
        assert_equal(100, second.revenue)
        assert_equal(-10, second.discounts)
        assert_equal(50, second.average_order_value)
        assert_equal(1, second.cancellations)
        assert_equal(-20, second.refund)
        assert_equal(['foo'], second.viewed.product_ids)
        assert_equal(['bar'], second.viewed.category_ids)
        assert_equal(['baz'], second.viewed.search_ids)
        assert_equal(['qoo'], second.purchased.product_ids)
        assert_equal(['quo'], second.purchased.category_ids)
        assert_equal(['qux'], second.purchased.search_ids)

        third = User.create!(
          first_order_at: 3.weeks.ago,
          last_order_at: 3.weeks.ago,
          orders: 2,
          revenue: 120,
          average_order_value: 60,
          viewed: { product_ids: ['one'], category_ids: ['two'], search_ids: ['three'] },
          purchased: { product_ids: ['four'], category_ids: ['five'], search_ids: ['six'] }
        )

        third.merge!(second)
        third.reload
        assert_equal(1, Metrics::User.count)
        assert_equal(3.weeks.ago, third.first_order_at)
        assert_equal(1.day.ago, third.last_order_at)
        assert_equal(4, third.orders)
        assert_equal(220, third.revenue)
        assert_equal(-10, third.discounts)
        assert_equal(55, third.average_order_value)
        assert_equal(1, third.cancellations)
        assert_equal(-20, third.refund)
        assert_equal(%w(one foo), third.viewed.product_ids)
        assert_equal(%w(two bar), third.viewed.category_ids)
        assert_equal(%w(three baz), third.viewed.search_ids)
        assert_equal(%w(four qoo), third.purchased.product_ids)
        assert_equal(%w(five quo), third.purchased.category_ids)
        assert_equal(%w(six qux), third.purchased.search_ids)
      end
    end
  end
end
