require 'test_helper'

module Workarea
  module Metrics
    class ByDayTest < TestCase
      class TestDocument
        include Metrics::ByDay

        field :product_id, type: String
        field :sku, type: String
        field :units_sold, type: Integer, default: 0
        field :sales, type: Float, default: 0

        index(product_id: 1, sku: 1)
        create_indexes
      end

      def test_inc_uniques_by_day
        travel_to Time.zone.local(2018, 10, 25, 1)
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 1)

        travel_to Time.zone.local(2018, 10, 25, 2)
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 2)

        assert_equal(1, TestDocument.count)
        assert_equal(3, TestDocument.first.units_sold)

        travel_to Time.zone.local(2018, 10, 26, 3)
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 3)

        travel_to Time.zone.local(2018, 10, 26, 4)
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 4)

        assert_equal(2, TestDocument.count)
        assert_equal(7, TestDocument.desc(:reporting_on).first.units_sold)
      end

      def test_the_at_argument
        travel_to Time.zone.local(2018, 10, 25, 1)
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 1)

        travel_to Time.zone.local(2018, 10, 26)
        TestDocument.inc(
          key: { product_id: 'foo' },
          at: Time.zone.local(2018, 10, 25, 1),
          units_sold: 2
        )

        assert_equal(1, TestDocument.count)
        assert_equal(3, TestDocument.first.units_sold)
      end

      def test_inc_uniques_by_key
        TestDocument.inc(key: { product_id: 'foo', sku: 'bar' }, units_sold: 1)
        TestDocument.inc(key: { sku: 'baz', product_id: 'foo' }, units_sold: 2)

        assert_equal(2, TestDocument.count)
        assert_equal(1, TestDocument.find_by(product_id: 'foo', sku: 'bar').units_sold)
        assert_equal(2, TestDocument.find_by(product_id: 'foo', sku: 'baz').units_sold)
      end

      def test_inc_exchanges_money_to_default_currency
        @current_currency = Money.default_currency

        Money.add_rate('USD', 'CAD', 1.25)
        Money.default_currency = 'CAD'

        TestDocument.inc(key: { product_id: 'foo' }, sales: Money.new(100, 'USD'))
        TestDocument.inc(key: { product_id: 'foo' }, sales: Money.new(200, 'CAD'))

        assert_equal(1, TestDocument.count)
        assert_equal(3.25, TestDocument.find_by(product_id: 'foo').sales)

      ensure
        Money.default_currency = @current_currency
      end

      def test_stores_in_utc
        current_zone = Time.zone
        Time.zone = 'UTC'

        at = Time.zone.local(2018, 11, 15, 23)
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 1, at: at)

        assert_equal(1, TestDocument.count)
        document = TestDocument.first

        assert_equal('20181115-foo', document.id)
        assert_equal(Time.zone.local(2018, 11, 15).to_i, document.reporting_on.to_i)

        Time.zone = 'Eastern Time (US & Canada)'
        TestDocument.delete_all

        at = Time.zone.local(2018, 11, 15, 23)
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 1, at: at)

        assert_equal(1, TestDocument.count)
        document = TestDocument.first

        assert_equal('20181115-foo', document.id)
        assert_equal(Time.zone.local(2018, 11, 15).to_i, document.reporting_on.to_i)

      ensure
        Time.zone = current_zone
      end

      def test_no_key
        travel_to Time.zone.local(2018, 10, 25, 1)
        TestDocument.inc(units_sold: 1)

        travel_to Time.zone.local(2018, 10, 25, 2)
        TestDocument.inc(units_sold: 2)

        assert_equal(1, TestDocument.count)
        assert_equal(3, TestDocument.first.units_sold)
        assert_equal('20181025', TestDocument.first.id)

        travel_to Time.zone.local(2018, 10, 26, 3)
        TestDocument.inc(units_sold: 3)

        travel_to Time.zone.local(2018, 10, 26, 4)
        TestDocument.inc(units_sold: 4)

        assert_equal(2, TestDocument.count)
        assert_equal(7, TestDocument.desc(:reporting_on).first.units_sold)
        assert_equal('20181025', TestDocument.first.id)
      end

      def test_today
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 1, at: 5.days.ago)
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 1)
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 1, at: 5.days.from_now)
        assert_equal(TestDocument.today, TestDocument.desc(:reporting_on).second)
      end

      def test_yesterday
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 1, at: 5.days.ago)
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 1, at: 1.day.ago)
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 1)
        TestDocument.inc(key: { product_id: 'foo' }, units_sold: 1, at: 5.days.from_now)
        assert_equal(TestDocument.yesterday, TestDocument.desc(:reporting_on).third)
      end
    end
  end
end
