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

        metrics = User.create!(
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

        metrics.merge!(User.new)
        metrics.reload
        assert_equal(2.weeks.ago, metrics.first_order_at)
        assert_equal(1.day.ago, metrics.last_order_at)
        assert_equal(2, metrics.orders)
        assert_equal(100, metrics.revenue)
        assert_equal(-10, metrics.discounts)
        assert_equal(50, metrics.average_order_value)
        assert_equal(1, metrics.cancellations)
        assert_equal(-20, metrics.refund)
        assert_equal(['foo'], metrics.viewed.product_ids)
        assert_equal(['bar'], metrics.viewed.category_ids)
        assert_equal(['baz'], metrics.viewed.search_ids)
        assert_equal(['qoo'], metrics.purchased.product_ids)
        assert_equal(['quo'], metrics.purchased.category_ids)
        assert_equal(['qux'], metrics.purchased.search_ids)

        blank = User.create!(id: 'foo').tap { |u| u.merge!(metrics) }
        blank.reload
        assert_equal(2.weeks.ago, blank.first_order_at)
        assert_equal(1.day.ago, blank.last_order_at)
        assert_equal(2, blank.orders)
        assert_equal(100, blank.revenue)
        assert_equal(-10, blank.discounts)
        assert_equal(50, blank.average_order_value)
        assert_equal(1, blank.cancellations)
        assert_equal(-20, blank.refund)
        assert_equal(['foo'], blank.viewed.product_ids)
        assert_equal(['bar'], blank.viewed.category_ids)
        assert_equal(['baz'], blank.viewed.search_ids)
        assert_equal(['qoo'], blank.purchased.product_ids)
        assert_equal(['quo'], blank.purchased.category_ids)
        assert_equal(['qux'], blank.purchased.search_ids)

        existing = User.create!(
          first_order_at: 3.weeks.ago,
          last_order_at: 3.weeks.ago,
          orders: 2,
          revenue: 120,
          average_order_value: 60,
          viewed: { product_ids: ['one'], category_ids: ['two'], search_ids: ['three'] },
          purchased: { product_ids: ['four'], category_ids: ['five'], search_ids: ['six'] }
        )

        existing.merge!(metrics)
        existing.reload
        assert_equal(3.weeks.ago, existing.first_order_at)
        assert_equal(1.day.ago, existing.last_order_at)
        assert_equal(4, existing.orders)
        assert_equal(220, existing.revenue)
        assert_equal(-10, existing.discounts)
        assert_equal(55, existing.average_order_value)
        assert_equal(1, existing.cancellations)
        assert_equal(-20, existing.refund)
        assert_equal(%w(one foo), existing.viewed.product_ids)
        assert_equal(%w(two bar), existing.viewed.category_ids)
        assert_equal(%w(three baz), existing.viewed.search_ids)
        assert_equal(%w(four qoo), existing.purchased.product_ids)
        assert_equal(%w(five quo), existing.purchased.category_ids)
        assert_equal(%w(six qux), existing.purchased.search_ids)
      end
    end
  end
end
