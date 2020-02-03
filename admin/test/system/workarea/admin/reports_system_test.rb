require 'test_helper'

module Workarea
  module Admin
    class ReportsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_average_order_value
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 11, 14),
          orders: 1,
          revenue: 5
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 30),
          orders: 2,
          revenue: 6
        )

        travel_to Time.zone.local(2018, 11, 20)

        visit admin.average_order_value_report_path
        assert(page.has_content?('2018-11'))
        assert(page.has_content?('2018-10'))
        assert(page.has_content?('1'))
        assert(page.has_content?('5'))
        assert(page.has_content?('2'))
        assert(page.has_content?('3'))

        click_link t('workarea.admin.fields.orders')
        assert(page.has_ordered_text?('2018-10', '2018-11'))

        click_link "#{t('workarea.admin.fields.orders')} ↓"
        assert(page.has_content?("#{t('workarea.admin.fields.orders')} ↑"))
        assert(page.has_ordered_text?('2018-11', '2018-10'))

        select 'Day', from: 'group_by'
        assert(page.has_content?('2018-11-14'))
        assert(page.has_content?('2018-10-30'))
        assert(page.has_content?('1'))
        assert(page.has_content?('5'))
        assert(page.has_content?('2'))
        assert(page.has_content?('3'))
      end

      def test_first_time_vs_returning_sales_test
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 11, 14),
          orders: 5,
          returning_orders: 2
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 30),
          orders: 2,
          returning_orders: 1
        )

        travel_to Time.zone.local(2018, 11, 20)

        visit admin.first_time_vs_returning_sales_report_path
        assert(page.has_content?('2018-11'))
        assert(page.has_content?('2018-10'))
        assert(page.has_content?('40%'))
        assert(page.has_content?('5'))
        assert(page.has_content?('50%'))
        assert(page.has_content?('1'))

        click_link t('workarea.admin.fields.percent_returning')
        assert(page.has_ordered_text?('2018-10', '2018-11'))

        click_link "#{t('workarea.admin.fields.percent_returning')} ↓"
        assert(page.has_content?("#{t('workarea.admin.fields.percent_returning')} ↑"))
        assert(page.has_ordered_text?('2018-11', '2018-10'))

        select 'Day', from: 'group_by'
        assert(page.has_content?('2018-11-14'))
        assert(page.has_content?('2018-10-30'))
        assert(page.has_content?('40%'))
        assert(page.has_content?('5'))
        assert(page.has_content?('50%'))
        assert(page.has_content?('1'))
      end

      def test_insights
        hot = create_hot_products
        cold = create_cold_products

        visit admin.insights_report_path
        assert(page.has_content?(hot.results.first['product_id']))

        [hot, cold].each do |insight|
          insight.results.each { |r| create_product(id: r['product_id']) }
        end

        visit admin.insights_report_path
        assert(page.has_content?('Test Product'))

        select t('workarea.admin.insights.hot_products.title'), from: 'type'
        assert(page.has_content?(t('workarea.admin.insights.hot_products.info')))
        assert(page.has_no_content?(t('workarea.admin.insights.cold_products.info')))
      end

      def test_customers
        Metrics::User.save_order(email: 'once@workarea.com', revenue: 10.to_m)
        Metrics::User.save_order(email: 'once@workarea.com', revenue: 20.to_m)
        Metrics::User.save_order(email: 'twice@workarea.com', revenue: 10.to_m)
        Metrics::User.save_order(email: 'twice@workarea.com', revenue: 20.to_m)
        Metrics::User.save_order(email: 'twice@workarea.com', revenue: 30.to_m)
        create_user(email: 'once@workarea.com', first_name: 'Ben', last_name: 'Crouse')

        visit admin.customers_report_path
        assert(page.has_content?('Ben Crouse'))
        assert(page.has_content?('twice@workarea.com'))
        assert(page.has_content?('15'))
        assert(page.has_content?('20'))

        click_link t('workarea.admin.fields.orders')
        assert(page.has_content?("#{t('workarea.admin.fields.orders')} ↓"))
        assert(page.has_ordered_text?('twice@workarea.com', 'Ben Crouse'))

        click_link "#{t('workarea.admin.fields.orders')} ↓"
        assert(page.has_content?("#{t('workarea.admin.fields.orders')} ↑"))
        assert(page.has_ordered_text?('Ben Crouse', 'twice@workarea.com'))
      end

      def test_sales_by_category
        category = create_category(name: 'Foo')

        Metrics::CategoryByDay.inc(key: { category_id: category.id }, orders: 1, units_sold: 5)
        Metrics::CategoryByDay.inc(key: { category_id: 'bar' }, orders: 2, units_sold: 3)

        visit admin.sales_by_category_report_path
        assert(page.has_content?('Foo'))
        assert(page.has_content?(t('workarea.admin.reports.unknown')))
        assert(page.has_content?('1'))
        assert(page.has_content?('5'))
        assert(page.has_content?('2'))
        assert(page.has_content?('3'))

        click_link t('workarea.admin.fields.orders')
        assert(page.has_content?("#{t('workarea.admin.fields.orders')} ↓"))
        assert(page.has_ordered_text?(t('workarea.admin.reports.unknown'), 'Foo'))

        click_link t('workarea.admin.fields.units_sold')
        assert(page.has_content?("#{t('workarea.admin.fields.units_sold')} ↓"))
        assert(page.has_ordered_text?('Foo', t('workarea.admin.reports.unknown')))

        click_link t('workarea.admin.fields.units_sold')
        assert(page.has_content?("#{t('workarea.admin.fields.units_sold')} ↑"))
        assert(page.has_ordered_text?(t('workarea.admin.reports.unknown'), 'Foo'))
      end

      def test_sales_by_country
        Metrics::CountryByDay.inc(key: { country: 'US' }, orders: 1, units_sold: 5)
        Metrics::CountryByDay.inc(key: { country: 'bar' }, orders: 2, units_sold: 3)

        visit admin.sales_by_country_report_path
        assert(page.has_content?(Country['US'].name))
        assert(page.has_content?('bar'))
        assert(page.has_content?('1'))
        assert(page.has_content?('5'))
        assert(page.has_content?('2'))
        assert(page.has_content?('3'))

        click_link t('workarea.admin.fields.units_sold')
        assert(page.has_content?("#{t('workarea.admin.fields.units_sold')} ↓"))
        assert(page.has_ordered_text?(Country['US'].name, 'bar'))

        click_link t('workarea.admin.fields.orders')
        assert(page.has_content?("#{t('workarea.admin.fields.orders')} ↓"))
        assert(page.has_ordered_text?('bar', Country['US'].name))

        click_link t('workarea.admin.fields.orders')
        assert(page.has_content?("#{t('workarea.admin.fields.orders')} ↑"))
        assert(page.has_ordered_text?(Country['US'].name, 'bar'))
      end

      def test_sales_by_discount
        discount = create_order_total_discount(name: 'Foo')

        Metrics::DiscountByDay.inc(key: { discount_id: discount.id }, orders: 1)
        Metrics::DiscountByDay.inc(key: { discount_id: 'bar' }, orders: 2)

        visit admin.sales_by_discount_report_path
        assert(page.has_content?('Foo'))
        assert(page.has_content?(t('workarea.admin.reports.unknown')))
        assert(page.has_content?('1'))
        assert(page.has_content?('2'))

        click_link t('workarea.admin.fields.orders')
        assert(page.has_content?("#{t('workarea.admin.fields.orders')} ↓"))
        assert(page.has_ordered_text?(t('workarea.admin.reports.unknown'), 'Foo'))
      end

      def test_sales_by_product
        create_product(id: 'foo', name: 'Foo')

        Metrics::ProductByDay.inc(key: { product_id: 'foo' }, orders: 1, units_sold: 5)
        Metrics::ProductByDay.inc(key: { product_id: 'bar' }, orders: 2, units_sold: 3)

        visit admin.sales_by_product_report_path
        assert(page.has_content?('Foo'))
        assert(page.has_content?('bar'))
        assert(page.has_content?('1'))
        assert(page.has_content?('5'))
        assert(page.has_content?('2'))
        assert(page.has_content?('3'))

        click_link t('workarea.admin.fields.orders')
        assert(page.has_content?("#{t('workarea.admin.fields.orders')} ↓"))
        assert(page.has_ordered_text?('bar', 'Foo'))

        click_link t('workarea.admin.fields.units_sold')
        assert(page.has_content?("#{t('workarea.admin.fields.units_sold')} ↓"))
        assert(page.has_ordered_text?('Foo', 'bar'))

        click_link t('workarea.admin.fields.units_sold')
        assert(page.has_content?("#{t('workarea.admin.fields.units_sold')} ↑"))
        assert(page.has_ordered_text?('bar', 'Foo'))
      end

      def test_sales_by_sku
        create_product(name: 'Foo', variants: [{ sku: 'foo' }])

        Metrics::SkuByDay.inc(key: { sku: 'foo' }, orders: 1, units_sold: 5)
        Metrics::SkuByDay.inc(key: { sku: 'bar' }, orders: 2, units_sold: 3)

        visit admin.sales_by_sku_report_path
        assert(page.has_content?('foo'))
        assert(page.has_content?('bar'))
        assert(page.has_content?('1'))
        assert(page.has_content?('5'))
        assert(page.has_content?('2'))
        assert(page.has_content?('3'))

        click_link t('workarea.admin.fields.orders')
        assert(page.has_content?("#{t('workarea.admin.fields.orders')} ↓"))
        assert(page.has_ordered_text?('bar', 'foo'))

        click_link t('workarea.admin.fields.units_sold')
        assert(page.has_content?("#{t('workarea.admin.fields.units_sold')} ↓"))
        assert(page.has_ordered_text?('foo', 'bar'))

        click_link t('workarea.admin.fields.units_sold')
        assert(page.has_content?("#{t('workarea.admin.fields.units_sold')} ↑"))
        assert(page.has_ordered_text?('bar', 'foo'))
      end

      def test_sales_by_traffic_referrer
        Metrics::TrafficReferrerByDay.inc(
          key: { medium: 'search', source: 'Google' },
          orders: 1,
          units_sold: 2
        )

        Metrics::TrafficReferrerByDay.inc(
          key: { medium: 'social', source: 'Facebook' },
          orders: 3,
          units_sold: 4
        )

        Metrics::TrafficReferrerByDay.inc(
          key: { medium: 'social', source: 'Twitter' },
          orders: 5,
          units_sold: 6
        )

        visit admin.sales_by_traffic_referrer_report_path
        assert(page.has_content?('Google'))
        assert(page.has_content?('Facebook'))
        assert(page.has_content?('Twitter'))
        assert(page.has_content?('Social'))
        assert(page.has_content?('Search'))
        assert(page.has_content?('1'))
        assert(page.has_content?('2'))
        assert(page.has_content?('3'))
        assert(page.has_content?('4'))
        assert(page.has_content?('5'))
        assert(page.has_content?('6'))

        click_link t('workarea.admin.fields.orders')
        assert(page.has_content?("#{t('workarea.admin.fields.orders')} ↓"))
        assert(page.has_ordered_text?('Twitter', 'Facebook', 'Google'))
        assert(page.has_ordered_text?('5', '3', '1'))
        assert(page.has_ordered_text?('6', '4', '2'))

        click_link t('workarea.admin.fields.source')
        assert(page.has_content?("#{t('workarea.admin.fields.source')} ↓"))
        assert(page.has_ordered_text?('Twitter', 'Google', 'Facebook'))

        click_link t('workarea.admin.fields.medium')
        assert(page.has_content?("#{t('workarea.admin.fields.medium')} ↓"))
        assert(page.has_ordered_text?('Social', 'Search'))
      end

      def test_sales_by_tender
        Metrics::TenderByDay.inc(key: { tender: 'credit_card' }, orders: 1, revenue: 100)
        Metrics::TenderByDay.inc(key: { tender: 'store_credit' }, orders: 2, revenue: 24)

        visit admin.sales_by_tender_report_path
        assert(page.has_content?('Credit Card'))
        assert(page.has_content?('Store Credit'))
        assert(page.has_content?('1'))
        assert(page.has_content?('100.00'))
        assert(page.has_content?('2'))
        assert(page.has_content?('24.00'))

        click_link t('workarea.admin.fields.revenue')
        assert(page.has_content?("#{t('workarea.admin.fields.revenue')} ↓"))
        assert(page.has_ordered_text?('Credit Card', 'Store Credit'))

        click_link t('workarea.admin.fields.revenue')
        assert(page.has_content?("#{t('workarea.admin.fields.revenue')} ↑"))
        assert(page.has_ordered_text?('Store Credit', 'Credit Card'))
      end

      def test_sales_over_time
        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 11, 14),
          orders: 1,
          units_sold: 5,
          revenue: 25
        )

        Metrics::SalesByDay.inc(
          at: Time.zone.local(2018, 10, 30),
          orders: 2,
          units_sold: 3,
          revenue: 30
        )

        travel_to Time.zone.local(2018, 11, 20)

        visit admin.sales_over_time_report_path
        assert(page.has_content?('2018-11'))
        assert(page.has_content?('2018-10'))
        assert(page.has_content?('1'))
        assert(page.has_content?('5'))
        assert(page.has_content?('2'))
        assert(page.has_content?('3'))

        click_link t('workarea.admin.fields.orders')
        assert(page.has_content?("#{t('workarea.admin.fields.orders')} ↓"))
        assert(page.has_ordered_text?('2018-10', '2018-11'))

        click_link t('workarea.admin.fields.units_sold')
        assert(page.has_content?("#{t('workarea.admin.fields.units_sold')} ↓"))
        assert(page.has_ordered_text?('2018-11', '2018-10'))

        click_link t('workarea.admin.fields.units_sold')
        assert(page.has_content?("#{t('workarea.admin.fields.units_sold')} ↑"))
        assert(page.has_ordered_text?('2018-10', '2018-11'))

        select 'Day', from: 'group_by'
        assert(page.has_content?('2018-11-14'))
        assert(page.has_content?('2018-10-30'))
        assert(page.has_content?('1'))
        assert(page.has_content?('5'))
        assert(page.has_content?('2'))
        assert(page.has_content?('3'))
      end

      def test_searches
        2.times { Metrics::SearchByDay.save_search('foo', 3) }
        Metrics::SearchByDay.save_search('bar', 4)

        Metrics::SearchByDay.inc(
          key: { query_id: 'foo' },
          orders: 1,
          units_sold: 5,
          revenue: 25
        )

        Metrics::SearchByDay.inc(
          key: { query_id: 'bar' },
          orders: 2,
          units_sold: 3,
          revenue: 30
        )

        3.times { Metrics::SearchByDay.save_search('baz', 0) }
        4.times { Metrics::SearchByDay.save_search('qux', 0) }

        visit admin.searches_report_path
        assert(page.has_content?('foo'))
        assert(page.has_content?('bar'))
        assert(page.has_content?('baz'))
        assert(page.has_content?('qux'))

        select t('workarea.admin.reports.searches.filters.with_results'),
               from: :results_filter

        assert(page.has_content?('foo'))
        assert(page.has_content?('bar'))
        assert(page.has_no_content?('baz'))
        assert(page.has_no_content?('qux'))
        assert(page.has_content?('1'))
        assert(page.has_content?('2'))
        assert(page.has_content?('3'))
        assert(page.has_content?('4'))
        assert(page.has_content?('25'))
        assert(page.has_content?('30'))

        select t('workarea.admin.reports.searches.filters.without_results'),
               from: :results_filter

        assert(page.has_no_content?('foo'))
        assert(page.has_no_content?('bar'))
        assert(page.has_content?('baz'))
        assert(page.has_content?('qux'))
        assert(page.has_content?('3'))
        assert(page.has_content?('4'))

        select t('workarea.admin.reports.searches.filters.all'),
               from: :results_filter

        assert(page.has_content?('foo'))
        assert(page.has_content?('bar'))
        assert(page.has_content?('baz'))
        assert(page.has_content?('qux'))

        click_link "#{t('workarea.admin.fields.searches')} ↓"
        assert(page.has_content?("#{t('workarea.admin.fields.searches')} ↑"))
        assert(page.has_ordered_text?('bar', 'foo', 'baz', 'qux'))
        assert(page.has_ordered_text?('30', '25'))
      end

      def test_low_inventory
        skus = [
          create_inventory(id: 'ignore_sku', policy: 'ignore'),
          create_inventory(
            id: 'standard_low',
            policy: 'standard',
            available: Workarea.config.low_inventory_threshold - 1,
          ),
          create_inventory(
            id: 'backordered_low',
            policy: 'allow_backorder',
            available: Workarea.config.low_inventory_threshold - 2,
            backordered: 1,
          ),
          create_inventory(
            id: 'standard_ok',
            policy: 'standard',
            available: Workarea.config.low_inventory_threshold + 1,
          )
        ]

        visit admin.low_inventory_report_path

        assert(page.has_content?('standard_low'))
        assert(page.has_content?('backordered_low'))
        assert(page.has_no_content?('ignored_sku'))
        assert(page.has_no_content?('standard_ok'))

        product =
          create_product(variants: [{ sku: 'standard_ok', regular: 5.to_m }])

        complete_checkout(
          Order.new(
            email: 'test@workarea.com',
            items: [{ product_id: product.id, sku: 'standard_ok', quantity: 2 }]
          )
        )

        visit admin.low_inventory_report_path

        assert(page.has_content?('standard_ok'))
        assert(page.has_content?('standard_low'))
        assert(page.has_content?('backordered_low'))
      end

      def test_reports_chart
        yesterday = 1.day.ago
        last_week = 1.week.ago

        create_release(name: 'Foo Release', published_at: yesterday)

        visit admin.timeline_report_path

        # Since we don't explicitly depend on Chart.js, but rather depend on
        # ChartKick which depends on Chart.js, we want to make sure the library
        # still works as we upgrade ChartKick.
        assert_match(/class=('|")chartjs-render-monitor/, page.body)

        within '.timeline-report__sidebar' do
          assert_text 'Foo Release'
          click_link 'Foo Release'
        end

        within '.tooltipster-box' do
          assert_text 'Foo Release'
        end

        find('body').click # close tooltip

        click_link t('workarea.admin.reports.timeline.add_custom')

        within '.tooltipster-box' do
          fill_in 'custom_event[name]', with: 'Foo Event'
          fill_in 'custom_event_occurred_at_date', with: yesterday.strftime('%Y-%m-%d')
          click_button t('workarea.admin.reports.timeline.add_custom_event')
        end

        within '.timeline-report' do
          assert_text 'Foo Release'
          assert_text 'Foo Event'
          click_link 'Foo Event'
        end

        within '.tooltipster-box' do
          fill_in 'custom_event[name]', with: 'Bar Event'
          fill_in t('workarea.admin.js.datetime_picker.date'), with: last_week.strftime('%Y-%m-%d')
          click_button t('workarea.admin.reports.timeline.update_event')
        end

        within '.timeline-report__event-group:first-of-type' do
          refute_text 'Foo Release'
          refute_text 'Foo Event'
          assert_text 'Bar Event'
        end

        within '.timeline-report__event-group:last-of-type' do
          assert_text 'Foo Release'
          refute_text 'Foo Event'
          refute_text 'Bar Event'
        end
      end
    end
  end
end
