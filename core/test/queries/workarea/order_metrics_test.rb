require 'test_helper'

module Workarea
  class OrderMetricsTest < IntegrationTest
    setup :set_models

    def set_models
      @product_one = create_product(
        name: 'Foo 1',
        variants: [{ sku: 'SKU1', regular: 5.to_m, tax_code: '001' }]
      )

      @product_two = create_product(
        name: 'Foo 2',
        variants: [{ sku: 'SKU2', regular: 6.to_m, tax_code: '001' }]
      )

      shipping_service = create_shipping_service(rates: [{ price: 5.to_m }])

      @shipping_discount = create_shipping_discount(
        shipping_service: shipping_service.name,
        amount: 1.to_m,
        promo_codes: ['foo']
      )
      @order_discount = create_order_total_discount(
        amount_type: 'percent',
        amount: 10,
        promo_codes: ['foo'],
        compatible_discount_ids: [@shipping_discount.id]
      )

      @category = create_category(product_ids: [@product_one.id])
      @search = Navigation::SearchResults.new(q: 'foo')
      @taxon = create_taxon(navigable: @category)
      @menu = create_menu(taxon: @taxon)

      @order = Order.new(
        email: 'bcrouse@workarea.com',
        promo_codes: ['foo'],
        items: [
          { product_id: @product_one.id, sku: 'SKU1', quantity: 2, via: @category.to_gid_param },
          { product_id: @product_two.id, sku: 'SKU2', quantity: 1, via: @search.to_gid_param }
        ]
      )

      create_payment_profile(store_credit: 6.to_m, reference: @order.id)

      Metrics::User.save_order(email: 'bcrouse@workarea.com', revenue: 10.to_m)

      create_tax_category(code: '001', rates: [{ percentage: 0.06, country: 'US' }])
      complete_checkout(@order, shipping_service: shipping_service.name)

      @metrics = OrderMetrics.new(@order)
    end

    def test_sales_data
      assert_equal(1, @metrics.sales_data[:orders])
      assert_equal(1, @metrics.sales_data[:returning_orders])
      assert_equal(0, @metrics.sales_data[:customers])
      assert_equal(3, @metrics.sales_data[:units_sold])
      assert_equal(3, @metrics.sales_data[:discounted_units_sold])
      assert_equal(16.to_m, @metrics.sales_data[:merchandise])
      assert_equal(-5.6.to_m, @metrics.sales_data[:discounts])
      assert_equal(5.to_m, @metrics.sales_data[:shipping])
      assert_equal(0.86.to_m, @metrics.sales_data[:tax])
      assert_equal(16.26.to_m, @metrics.sales_data[:revenue])
    end

    def test_products
      assert_equal(2, @metrics.products.size)

      assert_equal(1, @metrics.products[@product_one.id][:orders])
      assert_equal(2, @metrics.products[@product_one.id][:units_sold])
      assert_equal(2, @metrics.products[@product_one.id][:discounted_units_sold])
      assert_equal(10.to_m, @metrics.products[@product_one.id][:merchandise])
      assert_equal(-1.to_m, @metrics.products[@product_one.id][:discounts])
      assert_equal(0.54.to_m, @metrics.products[@product_one.id][:tax])
      assert_equal(9.54.to_m, @metrics.products[@product_one.id][:revenue])

      assert_equal(1, @metrics.products[@product_two.id][:orders])
      assert_equal(1, @metrics.products[@product_two.id][:units_sold])
      assert_equal(1, @metrics.products[@product_two.id][:discounted_units_sold])
      assert_equal(6.to_m, @metrics.products[@product_two.id][:merchandise])
      assert_equal(-0.6.to_m, @metrics.products[@product_two.id][:discounts])
      assert_equal(0.32.to_m, @metrics.products[@product_two.id][:tax])
      assert_equal(5.72.to_m, @metrics.products[@product_two.id][:revenue])
    end

    def test_categories
      assert_equal(1, @metrics.categories.size)

      assert_equal(1, @metrics.categories[@category.id.to_s][:orders])
      assert_equal(2, @metrics.categories[@category.id.to_s][:units_sold])
      assert_equal(2, @metrics.categories[@category.id.to_s][:discounted_units_sold])
      assert_equal(10.to_m, @metrics.categories[@category.id.to_s][:merchandise])
      assert_equal(-1.to_m, @metrics.categories[@category.id.to_s][:discounts])
      assert_equal(0.54.to_m, @metrics.categories[@category.id.to_s][:tax])
      assert_equal(9.54.to_m, @metrics.categories[@category.id.to_s][:revenue])
    end

    def test_searches
      assert_equal(1, @metrics.searches.size)
      query_id = @search.query_string.id

      assert_equal(1, @metrics.searches[query_id][:orders])
      assert_equal(1, @metrics.searches[query_id][:units_sold])
      assert_equal(1, @metrics.searches[query_id][:discounted_units_sold])
      assert_equal(6.to_m, @metrics.searches[query_id][:merchandise])
      assert_equal(-0.6.to_m, @metrics.searches[query_id][:discounts])
      assert_equal(0.32.to_m, @metrics.searches[query_id][:tax])
      assert_equal(5.72.to_m, @metrics.searches[query_id][:revenue])
    end

    def test_skus
      assert_equal(2, @metrics.skus.size)

      assert_equal(1, @metrics.skus['SKU1'][:orders])
      assert_equal(2, @metrics.skus['SKU1'][:units_sold])
      assert_equal(2, @metrics.skus['SKU1'][:discounted_units_sold])
      assert_equal(10.to_m, @metrics.skus['SKU1'][:merchandise])
      assert_equal(-1.to_m, @metrics.skus['SKU1'][:discounts])
      assert_equal(0.54.to_m, @metrics.skus['SKU1'][:tax])
      assert_equal(9.54.to_m,  @metrics.skus['SKU1'][:revenue])

      assert_equal(1, @metrics.skus['SKU2'][:orders])
      assert_equal(1, @metrics.skus['SKU2'][:units_sold])
      assert_equal(1, @metrics.skus['SKU2'][:discounted_units_sold])
      assert_equal(6.to_m, @metrics.skus['SKU2'][:merchandise])
      assert_equal(-0.6.to_m, @metrics.skus['SKU2'][:discounts])
      assert_equal(0.32.to_m, @metrics.skus['SKU2'][:tax])
      assert_equal(5.72.to_m, @metrics.skus['SKU2'][:revenue])
    end

    def test_menus
      assert_equal(1, @metrics.menus.size)

      assert_equal(1, @metrics.menus[@menu.id.to_s][:orders])
      assert_equal(2, @metrics.menus[@menu.id.to_s][:units_sold])
      assert_equal(2, @metrics.menus[@menu.id.to_s][:discounted_units_sold])
      assert_equal(10.to_m, @metrics.menus[@menu.id.to_s][:merchandise])
      assert_equal(-1.to_m, @metrics.menus[@menu.id.to_s][:discounts])
      assert_equal(0.54.to_m, @metrics.menus[@menu.id.to_s][:tax])
      assert_equal(9.54.to_m, @metrics.menus[@menu.id.to_s][:revenue])
    end

    def test_discounts
      assert_equal(2, @metrics.discounts.size)

      assert_equal(1, @metrics.discounts[@order_discount.id.to_s][:orders])
      assert_equal(16.to_m, @metrics.discounts[@order_discount.id.to_s][:merchandise])
      assert_equal(-1.6.to_m, @metrics.discounts[@order_discount.id.to_s][:discounts])
      assert_equal(16.26.to_m, @metrics.discounts[@order_discount.id.to_s][:revenue])

      assert_equal(1, @metrics.discounts[@shipping_discount.id.to_s][:orders])
      assert_equal(16.to_m, @metrics.discounts[@shipping_discount.id.to_s][:merchandise])
      assert_equal(-4.to_m, @metrics.discounts[@shipping_discount.id.to_s][:discounts])
      assert_equal(16.26.to_m, @metrics.discounts[@shipping_discount.id.to_s][:revenue])
    end

    def test_new_customer
      metrics = OrderMetrics.new(@order)
      refute(metrics.first_time_customer?)
      assert(metrics.repeat_today?)

      Metrics::User.delete_all

      metrics = OrderMetrics.new(@order)
      assert(metrics.first_time_customer?)
      refute(metrics.repeat_today?)

      Metrics::User.save_order(
        email: 'bcrouse@workarea.com',
        revenue: 10.to_m,
        at: 1.week.ago
      )

      metrics = OrderMetrics.new(@order)
      refute(metrics.first_time_customer?)
      refute(metrics.repeat_today?)
    end

    def test_tenders
      assert_equal(2, @metrics.tenders.size)

      assert_equal(1, @metrics.tenders[:credit_card][:orders])
      assert_equal(10.26.to_m, @metrics.tenders[:credit_card][:revenue])

      assert_equal(1, @metrics.tenders[:store_credit][:orders])
      assert_equal(6.to_m, @metrics.tenders[:store_credit][:revenue])
    end
  end
end
