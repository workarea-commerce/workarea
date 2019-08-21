require 'test_helper'

module Workarea
  class OrderCancellationMetricsTest < IntegrationTest
    setup :set_models

    def set_models
      create_life_cycle_segments
      @product_one = create_product(
        name: 'Foo 1',
        variants: [{ sku: 'SKU1', regular: 5.to_m, tax_code: '001' }]
      )

      @product_two = create_product(
        name: 'Foo 2',
        variants: [{ sku: 'SKU2', regular: 6.to_m, tax_code: '001' }]
      )

      shipping_service = create_shipping_service(rates: [{ price: 5.to_m }])

      @category = create_category(product_ids: [@product_one.id])
      @search = Navigation::SearchResults.new(q: 'foo')
      @taxon = create_taxon(navigable: @category)
      @menu = create_menu(taxon: @taxon)

      @order = Order.new(
        email: 'bcrouse@workarea.com',
        promo_codes: ['foo'],
        segment_ids: [Segment::FirstTimeVisitor.instance.id],
        items: [
          { product_id: @product_one.id, sku: 'SKU1', quantity: 2, via: @category.to_gid_param },
          { product_id: @product_two.id, sku: 'SKU2', quantity: 1, via: @search.to_gid_param }
        ]
      )

      create_payment_profile(store_credit: 6.to_m, reference: @order.id)

      Metrics::User.save_order(email: 'bcrouse@workarea.com', revenue: 10.to_m)

      create_tax_category(code: '001', rates: [{ percentage: 0.06, country: 'US' }])
      complete_checkout(@order, shipping_service: shipping_service.name)
    end

    def test_sales_data
      metrics = OrderCancellationMetrics.new(@order)

      assert_equal(1, metrics.sales_data[:cancellations])
      assert_equal(3, metrics.sales_data[:units_canceled])
      assert_equal(-21.96.to_m, metrics.sales_data[:refund])
      assert_equal(-21.96.to_m, metrics.sales_data[:revenue])

      metrics = OrderCancellationMetrics.new(
        @order,
        item_values: { @order.items.first.id.to_s => { quantity: 1, amount: 4.0 } },
        shipping_value: 2.0
      )

      assert_equal(1, metrics.sales_data[:cancellations])
      assert_equal(1, metrics.sales_data[:units_canceled])
      assert_equal(-6, metrics.sales_data[:refund])
      assert_equal(-6, metrics.sales_data[:revenue])
    end

    def test_products
      metrics = OrderCancellationMetrics.new(@order)

      assert_equal(2, metrics.products.size)

      assert_equal(2, metrics.products[@product_one.id][:units_canceled])
      assert_equal(-10.6.to_m, metrics.products[@product_one.id][:refund])
      assert_equal(-10.6.to_m, metrics.products[@product_one.id][:revenue])

      assert_equal(1, metrics.products[@product_two.id][:units_canceled])
      assert_equal(-6.36.to_m, metrics.products[@product_two.id][:refund])
      assert_equal(-6.36.to_m, metrics.products[@product_two.id][:revenue])

      metrics = OrderCancellationMetrics.new(
        @order,
        item_values: { @order.items.first.id.to_s => { quantity: 1, amount: 4.0 } },
      )

      assert_equal(1, metrics.products.size)

      assert_equal(1, metrics.products[@product_one.id][:units_canceled])
      assert_equal(-4, metrics.products[@product_one.id][:refund])
      assert_equal(-4, metrics.products[@product_one.id][:revenue])
    end

    def test_categories
      metrics = OrderCancellationMetrics.new(@order)

      assert_equal(1, metrics.categories.size)
      assert_equal(2, metrics.categories[@category.id.to_s][:units_canceled])
      assert_equal(-10.6.to_m, metrics.categories[@category.id.to_s][:refund])
      assert_equal(-10.6.to_m, metrics.categories[@category.id.to_s][:revenue])

      metrics = OrderCancellationMetrics.new(
        @order,
        item_values: { @order.items.first.id.to_s => { quantity: 1, amount: 4.0 } },
      )

      assert_equal(1, metrics.categories.size)
      assert_equal(1, metrics.categories[@category.id.to_s][:units_canceled])
      assert_equal(-4, metrics.categories[@category.id.to_s][:refund])
      assert_equal(-4, metrics.categories[@category.id.to_s][:revenue])
    end

    def test_searches
      metrics = OrderCancellationMetrics.new(@order)

      assert_equal(1, metrics.searches.size)
      query_id = @search.query_string.id

      assert_equal(1, metrics.searches[query_id][:units_canceled])
      assert_equal(-6.36.to_m, metrics.searches[query_id][:refund])
      assert_equal(-6.36.to_m, metrics.searches[query_id][:revenue])

      metrics = OrderCancellationMetrics.new(
        @order,
        item_values: { @order.items.first.id.to_s => { quantity: 1, amount: 4.0 } },
      )
      assert_equal(0, metrics.searches.size)

      metrics = OrderCancellationMetrics.new(
        @order,
        item_values: { @order.items.second.id.to_s => { quantity: 1, amount: 4.0 } },
      )

      assert_equal(1, metrics.searches.size)
      query_id = @search.query_string.id

      assert_equal(1, metrics.searches[query_id][:units_canceled])
      assert_equal(-4, metrics.searches[query_id][:refund])
      assert_equal(-4, metrics.searches[query_id][:revenue])
    end

    def test_skus
      metrics = OrderCancellationMetrics.new(@order)

      assert_equal(2, metrics.skus.size)

      assert_equal(2, metrics.skus['SKU1'][:units_canceled])
      assert_equal(-10.6.to_m,  metrics.skus['SKU1'][:refund])
      assert_equal(-10.6.to_m,  metrics.skus['SKU1'][:revenue])

      assert_equal(1, metrics.skus['SKU2'][:units_canceled])
      assert_equal(-6.36.to_m, metrics.skus['SKU2'][:refund])
      assert_equal(-6.36.to_m, metrics.skus['SKU2'][:revenue])

      metrics = OrderCancellationMetrics.new(
        @order,
        item_values: { @order.items.first.id.to_s => { quantity: 1, amount: 4.0 } },
      )

      assert_equal(1, metrics.skus.size)

      assert_equal(1, metrics.skus['SKU1'][:units_canceled])
      assert_equal(-4,  metrics.skus['SKU1'][:refund])
      assert_equal(-4,  metrics.skus['SKU1'][:revenue])
    end

    def test_menus
      metrics = OrderCancellationMetrics.new(@order)
      assert_equal(1, metrics.menus.size)

      assert_equal(2, metrics.menus[@menu.id.to_s][:units_canceled])
      assert_equal(-10.6.to_m, metrics.menus[@menu.id.to_s][:refund])
      assert_equal(-10.6.to_m, metrics.menus[@menu.id.to_s][:revenue])

      metrics = OrderCancellationMetrics.new(
        @order,
        item_values: { @order.items.first.id.to_s => { quantity: 1, amount: 4.0 } },
      )

      assert_equal(1, metrics.menus.size)

      assert_equal(1, metrics.menus[@menu.id.to_s][:units_canceled])
      assert_equal(-4, metrics.menus[@menu.id.to_s][:refund])
      assert_equal(-4, metrics.menus[@menu.id.to_s][:revenue])
    end

    def test_segments_data
      metrics = OrderCancellationMetrics.new(@order)
      segment = Segment::FirstTimeVisitor.instance

      assert_equal(1, metrics.segments[segment.id][:cancellations])
      assert_equal(3, metrics.segments[segment.id][:units_canceled])
      assert_equal(-21.96.to_m, metrics.segments[segment.id][:refund])
      assert_equal(-21.96.to_m, metrics.segments[segment.id][:revenue])

      metrics = OrderCancellationMetrics.new(
        @order,
        item_values: { @order.items.first.id.to_s => { quantity: 1, amount: 4.0 } },
        shipping_value: 2.0
      )

      assert_equal(1, metrics.segments[segment.id][:cancellations])
      assert_equal(1, metrics.segments[segment.id][:units_canceled])
      assert_equal(-6, metrics.segments[segment.id][:refund])
      assert_equal(-6, metrics.segments[segment.id][:revenue])
    end
  end
end
