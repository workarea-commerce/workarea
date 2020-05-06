require 'test_helper'

module Workarea
  class PricingTest < TestCase
    def test_properly_rounds_percent_based_discount
      product = create_product
      category = create_category(product_ids: [product.id])

      sku = product.skus.first

      pricing_sku = Workarea::Pricing::Sku.find(sku)
      pricing_sku.prices.first.regular = 1.55.to_m
      pricing_sku.save!

      create_category_discount(
        category_ids: [category.id],
        amount_type: 'percent',
        amount: 15,
        order_total: 250.to_m
      )

      order = Workarea::Order.new
      order.add_item(product_id: product.id, sku: sku, quantity: 500)
      item = order.items.first
      item.category_ids = [category.id]
      order.save!

      Workarea::Pricing.perform(order)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal(-116.25.to_m, order.items.first.price_adjustments.last.amount)
    end

    def test_calculates_item_pricing
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 2)

      Pricing.perform(order)

      assert_equal(1, order.items.first.price_adjustments.length)
      assert_equal(10.to_m, order.items.first.total_value)
      assert_equal(10.to_m, order.items.first.total_price)
      assert_equal(10.to_m, order.subtotal_price)
      assert_equal(10.to_m, order.total_value)
      assert_equal(10.to_m, order.total_price)
    end

    def test_adds_product_discounts
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      create_product_discount(
        amount_type: 'flat',
        amount: 1,
        product_ids: ['PRODUCT']
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      Pricing.perform(order)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal(4.to_m, order.items.first.total_value)
      assert_equal(4.to_m, order.items.first.total_price)
      assert_equal(4.to_m, order.subtotal_price)
      assert_equal(4.to_m, order.total_value)
      assert_equal(-1.to_m, order.discount_total)
      assert_equal(4.to_m, order.total_price)
    end

    def test_adds_free_items_from_discounts
      create_product(
        name: "Test Product",
        id: "TESTPRODUCT",
        variants: [
          { sku: "FREESKU" }
        ]
      )

      create_pricing_sku(id: 'SKU1', prices: [{ regular: 5.to_m }])

      create_free_gift_discount(
        name: 'Test Discount',
        sku: 'FREESKU'
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU1')

      Pricing.perform(order)

      assert_equal(1, order.items.first.price_adjustments.length)
      assert_equal(5.to_m, order.items.first.total_value)
      assert_equal(5.to_m, order.items.first.total_price)
      assert_equal('TESTPRODUCT', order.items.second.product_id)
      assert_equal('FREESKU', order.items.second.sku)
      assert_equal({ 'en' => 'Test Product' }, order.items.second.product_attributes['name'])
      assert_equal(1, order.items.second.price_adjustments.length)
      assert_equal(0.to_m, order.items.second.total_price)
      assert_equal(5.to_m, order.subtotal_price)
      assert_equal(5.to_m, order.total_value)
      assert_equal(5.to_m, order.total_price)
    end

    def test_removes_free_gifts_if_no_other_items_are_present
      create_product(id: 'PRODUCT', variants: [{ sku: 'SKU2', regular: 3.to_m }])
      create_pricing_sku(id: 'SKU1', prices: [{ regular: 5.to_m }])

      create_free_gift_discount(
        sku: 'SKU2',
        promo_codes: ['FOO']
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU1')
      order.add_promo_code('foo')

      Pricing.perform(order)

      order.remove_item(order.items.first.id)

      Pricing.perform(order)

      assert(order.items.empty?)
    end

    def test_fresh_requests_dont_remove_free_gifts
      create_product(
        name: "Test Product",
        id: "TESTPRODUCT",
        variants: [
          { sku: "FREESKU" }
        ]
      )

      create_pricing_sku(id: 'SKU1', prices: [{ regular: 5.to_m }])

      create_free_gift_discount(
        name: 'Test Discount',
        sku: 'FREESKU'
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU1')

      Pricing.perform(order)
      Pricing.perform(order)

      assert_equal(1, order.items.first.price_adjustments.length)
      assert_equal(5.to_m, order.items.first.total_value)
      assert_equal(5.to_m, order.items.first.total_price)
      assert_equal('TESTPRODUCT', order.items.second.product_id)
      assert_equal('FREESKU', order.items.second.sku)
      assert_equal({ 'en' => 'Test Product' }, order.items.second.product_attributes['name'])
      assert_equal(1, order.items.second.price_adjustments.length)
      assert_equal(0.to_m, order.items.second.total_price)
      assert_equal(5.to_m, order.subtotal_price)
      assert_equal(5.to_m, order.total_value)
      assert_equal(5.to_m, order.total_price)
    end

    def test_adds_customizations_cost
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])
      create_pricing_sku(id: 'CUST', prices: [{ regular: 1.to_m }])

      order = Order.new
      order.add_item(
        product_id: 'PRODUCT',
        sku: 'SKU',
        quantity: 2,
        customizations: { 'pricing_sku' => 'CUST' }
      )

      Pricing.perform(order)

      assert_equal(12.to_m, order.items.first.total_value)
      assert_equal(12.to_m, order.items.first.total_price)
      assert_equal(12.to_m, order.subtotal_price)
      assert_equal(12.to_m, order.total_value)
      assert_equal(12.to_m, order.total_price)
    end

    def test_adds_item_tax
      create_pricing_sku(id: 'SKU', tax_code: '001', prices: [{ regular: 5.to_m }])
      create_tax_category(
        code:  '001',
        rates: [{ percentage: 0.06, region: 'PA', country: 'US' }]
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      shipping = Shipping.new
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      Pricing.perform(order, shipping)

      assert_equal(5.to_m, order.items.first.total_value)
      assert_equal(5.to_m, order.items.first.total_price)
      assert_equal(5.to_m, order.subtotal_price)
      assert_equal(0.30.to_m, order.tax_total)
      assert_equal(5.to_m, order.total_value)
      assert_equal(5.30.to_m, order.total_price)
    end

    def test_adds_shipping_cost
      order = Order.new

      shipping = Shipping.new
      shipping.set_shipping_service(
        id: 'GROUND',
        name: 'Ground',
        tax_code: '001',
        base_price: 3.to_m
      )
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      Pricing.perform(order, shipping)

      assert_equal(3.to_m, order.shipping_total)
      assert_equal(0.to_m, order.total_value)
      assert_equal(3.to_m, order.total_price)
    end

    def test_adds_shipping_tax
      create_pricing_sku(
        id: 'SKU',
        tax_code: '001',
        prices: [{ regular: 5.to_m }]
      )

      create_tax_category(
        code: '001',
        rates: [{
          percentage: 0.06,
          region: 'PA',
          country: 'US',
          charge_on_shipping: true
        }]
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      shipping = Shipping.new
      shipping.set_shipping_service(
        id: 'GROUND',
        name: 'Ground',
        tax_code: '001',
        base_price: 3.to_m
      )
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      Pricing.perform(order, shipping)

      assert_equal(5.to_m, order.items.first.total_value)
      assert_equal(5.to_m, order.items.first.total_price)
      assert_equal(5.to_m, order.subtotal_price)
      assert_equal(0.48.to_m, order.tax_total)
      assert_equal(5.to_m, order.total_value)
      assert_equal(8.48.to_m, order.total_price)
    end

    def test_adds_shipping_discounts
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      create_shipping_discount(
        name: 'Second Discount',
        amount: 0,
        shipping_service: 'Ground'
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      shipping = Shipping.new
      shipping.set_shipping_service(
        name: 'Ground',
        tax_code: '001',
        base_price: 3.to_m
      )
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      Pricing.perform(order, shipping)

      assert_equal(0.to_m, order.shipping_total)
      assert_equal(-3.to_m, order.discount_total)
      assert_equal(5.to_m, order.total_value)
      assert_equal(5.to_m, order.total_price)
    end

    def test_handles_multiple_shippings
      order = Order.new

      shipping_one = Shipping.new
      shipping_one.set_shipping_service(
        id: 'GROUND',
        name: 'Ground',
        tax_code: '001',
        base_price: 3.to_m
      )
      shipping_one.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      shipping_two = Shipping.new
      shipping_two.set_shipping_service(
        id: '2DAY',
        name: 'Second Day',
        tax_code: '001',
        base_price: 10.to_m
      )
      shipping_one.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )


      Pricing.perform(order, [shipping_one, shipping_two])

      assert_equal(13.to_m, order.shipping_total)
      assert_equal(13.to_m, order.total_price)
    end

    def test_adds_order_total_discounts
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      create_order_total_discount(
        name: 'Discount',
        amount_type: 'flat',
        amount: 2
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      Pricing.perform(order)

      assert_equal(3.to_m, order.items.first.total_value)
      assert_equal(5.to_m, order.subtotal_price)
      assert_equal(-2.to_m, order.discount_total)
      assert_equal(3.to_m, order.total_value)
      assert_equal(3.to_m, order.total_price)
    end

    def test_adds_bogo_discounts
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      create_buy_some_get_some_discount(
        name: 'Test Discount',
        purchase_quantity: 1,
        apply_quantity: 1,
        percent_off: 100,
        product_ids: ['PRODUCT']
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 2)

      Pricing.perform(order)

      assert_equal(5.to_m, order.items.first.total_value)
      assert_equal(5.to_m, order.subtotal_price)
      assert_equal(-5.to_m, order.discount_total)
      assert_equal(5.to_m, order.total_value)
      assert_equal(5.to_m, order.total_price)
    end

    def test_finds_complete_pricing_for_an_order
      create_pricing_sku(id: 'SKU1', tax_code: '001', prices: [{ regular: 5.to_m }])
      create_pricing_sku(id: 'SKU2', tax_code: '001', prices: [{ regular: 7.to_m }])

      create_order_total_discount(
        name: 'Test Discount',
        amount_type: 'flat',
        amount: 1
      )

      create_tax_category(
        code:  '001',
        rates: [{ percentage: 0.06, region: 'PA', country: 'US' }]
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT1', sku: 'SKU1')
      order.add_item(product_id: 'PRODUCT2', sku: 'SKU2')

      shipping = Shipping.new

      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      shipping.set_shipping_service(
        id: 'GROUND',
        name: 'Ground',
        base_price: 3.to_m,
        tax_code: '001'
      )

      Pricing.perform(order, shipping)

      assert_equal(12.to_m, order.subtotal_price)
      assert_equal(3.to_m, order.shipping_total)
      assert_equal(0.84.to_m, order.tax_total)
      assert_equal(-1.to_m, order.discount_total)
      assert_equal(11.to_m, order.total_value)
      assert_equal(14.84.to_m, order.total_price)
    end

    def test_does_not_allow_negative_priced_orders_from_too_many_discounts
      create_pricing_sku(id: 'SKU1', tax_code: '001', prices: [{ regular: 5.to_m }])
      create_pricing_sku(id: 'SKU2', tax_code: '001', prices: [{ regular: 7.to_m }])

      fixed_price_discount = create_quantity_fixed_price_discount(
        name: 'Test 1 Discount',
        quantity: 2,
        price: 1,
        product_ids: %w(PRODUCT1 PRODUCT2)
      )

      create_order_total_discount(
        name: 'Test 2 Discount',
        amount_type: 'flat',
        amount: 10,
        compatible_discount_ids: [fixed_price_discount.id.to_s]
      )

      create_tax_category(
        code:  '001',
        rates: [{ percentage: 0.06, region: 'PA', country: 'US' }]
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT1', sku: 'SKU1')
      order.add_item(product_id: 'PRODUCT2', sku: 'SKU2')

      shipping = Shipping.new

      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      shipping.set_shipping_service(
        id: 'GROUND',
        name: 'Ground',
        base_price: 3.to_m,
        tax_code: '001'
      )

      Pricing.perform(order, shipping)

      assert_equal(12.to_m, order.subtotal_price)
      assert_equal(3.to_m, order.shipping_total)
      assert_equal(0.18.to_m, order.tax_total)
      assert_equal(-12.to_m, order.discount_total)
      assert_equal(3.18.to_m, order.total_price)
    end

    def test_combines_a_category_and_buy_some_get_some_discount_that_are_compatible
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      buy_some_get_some = create_buy_some_get_some_discount(
        purchase_quantity: 2,
        apply_quantity: 1,
        percent_off: 100,
        product_ids: ['PRODUCT']
      )

      create_product_discount(
        amount_type: 'percent',
        amount: 10,
        product_ids: ['PRODUCT'],
        compatible_discount_ids: [buy_some_get_some.id]
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 3)

      Pricing.perform(order)

      assert_equal(9.to_m, order.items.first.total_value)
      assert_equal(-1.5.to_m, order.items.first.price_adjustments.second.amount)
      assert_equal(-4.5.to_m, order.items.first.price_adjustments.third.amount)

      assert_equal(9.to_m, order.subtotal_price)
      assert_equal(-6.to_m, order.discount_total)
      assert_equal(9.to_m, order.total_price)
    end

    def test_combines_a_category_and_buy_some_get_some_discount_that_are_incompatible
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      create_buy_some_get_some_discount(
        purchase_quantity: 2,
        apply_quantity: 1,
        percent_off: 100,
        product_ids: ['PRODUCT']
      )

      create_product_discount(
        amount_type: 'percent',
        amount: 10,
        product_ids: ['PRODUCT']
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 3)

      Pricing.perform(order)

      assert_equal(10.to_m, order.items.first.total_value)
      assert_equal(-5.to_m, order.items.first.price_adjustments.second.amount)

      assert_equal(10.to_m, order.subtotal_price)
      assert_equal(-5.to_m, order.discount_total)
      assert_equal(10.to_m, order.total_price)
    end

    def test_combines_a_quantity_fixed_price_and_order_total_discount
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      quantity_fixed_price = create_quantity_fixed_price_discount(
        quantity: 3,
        price: 12,
        product_ids: ['PRODUCT']
      )

      create_order_total_discount(
        amount_type: 'percent',
        amount: 10,
        compatible_discount_ids: [quantity_fixed_price.id]
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU', quantity: 3)

      Pricing.perform(order)

      assert_equal(15.to_m, order.items.first.total_price)
      assert_equal(-3.to_m, order.items.first.price_adjustments.second.amount)
      assert_equal(-1.2.to_m, order.items.first.price_adjustments.third.amount)

      assert_equal(15.to_m, order.subtotal_price)
      assert_equal(-4.2.to_m, order.discount_total)
      assert_equal(10.8.to_m, order.total_price)
    end

    def test_combines_a_shipping_discount_and_an_order_total_discount
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      shipping_discount = create_shipping_discount(
        name: 'Second Discount',
        amount: 0,
        shipping_service: 'Ground'
      )

      create_order_total_discount(
        amount_type: 'percent',
        amount: 10,
        compatible_discount_ids: [shipping_discount.id]
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      shipping = Shipping.new
      shipping.set_shipping_service(
        name: 'Ground',
        tax_code: '001',
        base_price: 3.to_m
      )
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      Pricing.perform(order, shipping)

      assert_equal(0.to_m, order.shipping_total)
      assert_equal(-3.5.to_m, order.discount_total)
      assert_equal(4.5.to_m, order.total_price)
    end

    def test_ignores_disqualified_item_discount
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      first = create_product_discount(
        name: 'Test Discount',
        amount_type: 'flat',
        amount: 2,
        product_ids: ['PRODUCT']
      )

      create_product_discount(
        name: 'Test Discount',
        amount_type: 'flat',
        amount: 1,
        product_ids: ['PRODUCT']
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      Pricing.perform(order)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal(-2.to_m, order.items.first.price_adjustments.last.amount)
      assert_equal(first.id.to_s, order.items.first.price_adjustments.last.data['discount_id'])
    end

    def test_respecting_compatible_item_discounts
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      first = create_product_discount(
        name: 'Test Discount',
        amount_type: 'flat',
        amount: 2,
        product_ids: ['PRODUCT']
      )

      second = create_product_discount(
        name: 'Test Discount',
        amount_type: 'flat',
        amount: 1,
        product_ids: ['PRODUCT'],
        compatible_discount_ids: [first.id.to_s]
      )

      first.compatible_discount_ids = [second.id.to_s]
      first.save!

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      Pricing.perform(order)

      assert_equal(3, order.items.first.price_adjustments.length)

      discount_1_adjustment = order
        .items
        .first
        .price_adjustments
        .detect { |a| a.data['discount_id'] == first.id.to_s }

      discount_2_adjustment = order
        .items
        .first
        .price_adjustments
        .detect { |a| a.data['discount_id'] == second.id.to_s }

      assert_equal(-2.to_m, discount_1_adjustment.amount)
      assert_equal(-1.to_m, discount_2_adjustment.amount)
    end

    def test_respects_compatible_item_discount
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      first = create_product_discount(
        name: 'Test Discount',
        amount_type: 'flat',
        amount: 2,
        product_ids: ['PRODUCT']
      )

      second = create_product_discount(
        name: 'Test Discount',
        amount_type: 'flat',
        amount: 1,
        product_ids: ['PRODUCT'],
        compatible_discount_ids: [first.id.to_s]
      )

      first.compatible_discount_ids = [second.id.to_s]
      first.save!

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      Pricing.perform(order)

      assert_equal(3, order.items.first.price_adjustments.length)
      assert_equal(-2.to_m, order.items.first.price_adjustments.second.amount)
      assert_equal(first.id.to_s, order.items.first.price_adjustments.second.data['discount_id'])
      assert_equal(-1.to_m, order.items.first.price_adjustments.third.amount)
      assert_equal(second.id.to_s, order.items.first.price_adjustments.third.data['discount_id'])
    end

    def test_uses_shipping_discounts_when_higher_value
      create_pricing_sku(id: 'SKU', prices: [{ regular: 10.to_m }])

      create_product_discount(
        name: 'First Discount',
        amount_type: 'flat',
        amount: 1,
        product_ids: ['PRODUCT']
      )

      shipping_discount = create_shipping_discount(
        name: 'Second Discount',
        amount: 0,
        shipping_service: 'Ground'
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      shipping = Shipping.new
      shipping.set_shipping_service(
        id: 'GROUND',
        name: 'Ground',
        base_price: 3.to_m
      )
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      Pricing.perform(order, shipping)

      assert_equal(1, order.items.first.price_adjustments.length)
      assert_equal('item', order.items.first.price_adjustments.first.price)
      assert_equal(10.to_m, order.items.first.price_adjustments.first.amount)

      assert_equal(2, shipping.price_adjustments.length)
      assert_equal('shipping', shipping.price_adjustments.first.price)
      assert_equal(3.to_m, shipping.price_adjustments.first.amount)
      assert_equal('shipping', shipping.price_adjustments.second.price)
      assert_equal(-3.to_m, shipping.price_adjustments.second.amount)
      assert_equal(shipping_discount.id.to_s, shipping.price_adjustments.second.data['discount_id'])
    end

    def test_uses_a_product_discount_when_higher_value
      create_pricing_sku(id: 'SKU', prices: [{ regular: 10.to_m }])

      product_discount = create_product_discount(
        name: 'First Discount',
        amount_type: 'flat',
        amount: 7,
        product_ids: ['PRODUCT']
      )

      create_shipping_discount(
        name: 'Second Discount',
        amount: 0,
        shipping_service: 'Ground'
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      shipping = Shipping.new
      shipping.set_shipping_service(
        id: 'GROUND',
        name: 'Ground',
        base_price: 3.to_m
      )
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      Pricing.perform(order, shipping)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal('item', order.items.first.price_adjustments.first.price)
      assert_equal(10.to_m, order.items.first.price_adjustments.first.amount)
      assert_equal('item', order.items.first.price_adjustments.second.price)
      assert_equal(-7.to_m, order.items.first.price_adjustments.second.amount)
      assert_equal(product_discount.id.to_s, order.items.first.price_adjustments.second.data['discount_id'])

      assert_equal(1, shipping.price_adjustments.length)
      assert_equal('shipping', shipping.price_adjustments.first.price)
      assert_equal(3.to_m, shipping.price_adjustments.first.amount)
    end

    def test_uses_a_product_discount_and_shipping_discount_together
      create_pricing_sku(id: 'SKU', prices: [{ regular: 10.to_m }])

      product_discount = create_product_discount(
        name: 'First Discount',
        amount_type: 'flat',
        amount: 1,
        product_ids: ['PRODUCT']
      )

      shipping_discount = create_shipping_discount(
        name: 'Second Discount',
        amount: 0,
        shipping_service: 'Ground'
      )

      product_discount.compatible_discount_ids = [shipping_discount.id.to_s]
      product_discount.save!

      shipping_discount.compatible_discount_ids = [product_discount.id.to_s]
      shipping_discount.save!

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      shipping = Shipping.new
      shipping.set_shipping_service(
        name: 'Ground',
        base_price: 3.to_m
      )
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      Pricing.perform(order, shipping)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal('item', order.items.first.price_adjustments.first.price)
      assert_equal(10.to_m, order.items.first.price_adjustments.first.amount)
      assert_equal('item', order.items.first.price_adjustments.second.price)
      assert_equal(-1.to_m, order.items.first.price_adjustments.second.amount)
      assert_equal(product_discount.id.to_s, order.items.first.price_adjustments.second.data['discount_id'])

      assert_equal(2, shipping.price_adjustments.length)
      assert_equal('shipping', shipping.price_adjustments.first.price)
      assert_equal(3.to_m, shipping.price_adjustments.first.amount)
      assert_equal('shipping', shipping.price_adjustments.second.price)
      assert_equal(-3.to_m, shipping.price_adjustments.second.amount)
      assert_equal(shipping_discount.id.to_s, shipping.price_adjustments.second.data['discount_id'])
    end

    def test_uses_a_product_discount_and_shipping_discount_together_and_ignores_a_lower_value_product_discount
      create_pricing_sku(id: 'SKU', prices: [{ regular: 10.to_m }])

      create_product_discount(
        name: 'Ignored Discount',
        amount_type: 'flat',
        amount: 0.99,
        product_ids: ['PRODUCT']
      )

      product_discount = create_product_discount(
        name: 'First Discount',
        amount_type: 'flat',
        amount: 1,
        product_ids: ['PRODUCT']
      )

      shipping_discount = create_shipping_discount(
        name: 'Second Discount',
        amount: 0,
        shipping_service: 'Ground'
      )

      product_discount.compatible_discount_ids = [shipping_discount.id.to_s]
      product_discount.save!

      shipping_discount.compatible_discount_ids = [product_discount.id.to_s]
      shipping_discount.save!

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      shipping = Shipping.new
      shipping.set_shipping_service(
        name: 'Ground',
        base_price: 3.to_m
      )
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      Pricing.perform(order, shipping)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal('item', order.items.first.price_adjustments.first.price)
      assert_equal(10.to_m, order.items.first.price_adjustments.first.amount)
      assert_equal('item', order.items.first.price_adjustments.second.price)
      assert_equal(-1.to_m, order.items.first.price_adjustments.second.amount)
      assert_equal(product_discount.id.to_s, order.items.first.price_adjustments.second.data['discount_id'])

      assert_equal(2, shipping.price_adjustments.length)
      assert_equal('shipping', shipping.price_adjustments.first.price)
      assert_equal(3.to_m, shipping.price_adjustments.first.amount)
      assert_equal('shipping', shipping.price_adjustments.second.price)
      assert_equal(-3.to_m, shipping.price_adjustments.second.amount)
      assert_equal(shipping_discount.id.to_s, shipping.price_adjustments.second.data['discount_id'])
    end

    def test_resolves_order_vs_shipping_discounts_by_value
      create_pricing_sku(id: 'SKU', tax_code: '001', prices: [{ regular: 5.to_m }])

      create_shipping_discount(
        name: 'Second Discount',
        amount: 1,
        shipping_service: 'Ground'
      )

      order_discount = create_order_total_discount(
        name: 'First Discount',
        amount_type: 'flat',
        amount: 3
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      shipping = Shipping.new
      shipping.set_shipping_service(
        name: 'Ground',
        base_price: 3.to_m
      )
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      Pricing.perform(order, shipping)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal('item', order.items.first.price_adjustments.first.price)
      assert_equal(5.to_m, order.items.first.price_adjustments.first.amount)
      assert_equal('order', order.items.first.price_adjustments.second.price)
      assert_equal(-3.to_m, order.items.first.price_adjustments.second.amount)
      assert_equal(order_discount.id.to_s, order.items.first.price_adjustments.second.data['discount_id'])

      assert_equal(1, shipping.price_adjustments.length)
      assert_equal('shipping', shipping.price_adjustments.first.price)
      assert_equal(3.to_m, shipping.price_adjustments.first.amount)
    end

    def test_allows_order_and_shipping_discounts_when_compatible
      create_pricing_sku(id: 'SKU', tax_code: '001', prices: [{ regular: 5.to_m }])

      shipping_discount = create_shipping_discount(
        name: 'Second Discount',
        amount: 1,
        shipping_service: 'Ground'
      )

      order_discount = create_order_total_discount(
        name: 'First Discount',
        amount_type: 'flat',
        amount: 3
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      shipping = Shipping.new
      shipping.set_shipping_service(
        name: 'Ground',
        base_price: 3.to_m
      )
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      order_discount.compatible_discount_ids = [shipping_discount.id.to_s]
      order_discount.save!

      shipping_discount.compatible_discount_ids = [order_discount.id.to_s]
      shipping_discount.save!

      Pricing.perform(order, shipping)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal('item', order.items.first.price_adjustments.first.price)
      assert_equal(5.to_m, order.items.first.price_adjustments.first.amount)
      assert_equal('order', order.items.first.price_adjustments.second.price)
      assert_equal(-3.to_m, order.items.first.price_adjustments.second.amount)
      assert_equal(order_discount.id.to_s, order.items.first.price_adjustments.second.data['discount_id'])

      assert_equal(2, shipping.price_adjustments.length)
      assert_equal('shipping', shipping.price_adjustments.first.price)
      assert_equal(3.to_m, shipping.price_adjustments.first.amount)
      assert_equal('Second Discount', shipping.price_adjustments.second.description)
      assert_equal(-2.to_m, shipping.price_adjustments.second.amount)
    end

    def test_selects_the_higher_value_discount_when_one_is_a_free_item
      create_pricing_sku(id: 'SKU1', prices: [{ regular: 5.to_m }])
      create_pricing_sku(id: 'SKU2', prices: [{ regular: 3.to_m }])

      order_discount = create_order_total_discount(
        name: 'First Discount',
        amount_type: 'flat',
        amount: 5
      )

      create_free_gift_discount(
        name: 'Second Discount',
        sku: 'SKU2'
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU1')

      Pricing.perform(order)

      assert(order.items.select(&:free_gift?).empty?)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal('order', order.items.first.price_adjustments.last.price)
      assert_equal(-5.to_m, order.items.first.price_adjustments.last.amount)
      assert_equal(order_discount.id.to_s, order.items.first.price_adjustments.last.data['discount_id'])
    end

    def test_keeps_the_higher_value_item_when_both_are_free_items
      create_product(
        id: 'PRODUCT',
        variants: [
          { sku: 'SKU2', regular: 20.to_m },
          { sku: 'SKU3', regular: 30.to_m }
        ]
      )
      create_pricing_sku(id: 'SKU1', prices: [{ regular: 180.to_m }])

      create_free_gift_discount(
        name: 'First Discount',
        sku: 'SKU2',
        order_total_operator: 'greater_than',
        order_total: 150.to_m
      )

      free_gift = create_free_gift_discount(
        name: 'Second Discount',
        sku: 'SKU3',
        order_total_operator: 'greater_than',
        order_total: 100.to_m
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU1')

      Pricing.perform(order)
      order.reload

      assert_equal(1, order.items.select(&:free_gift?).count)
      assert_equal(0.to_m, order.items.last.price_adjustments.last.amount)
      assert_equal(30, order.items.last.price_adjustments.last.data['discount_value'])
      assert_equal(free_gift.id.to_s, order.items.last.price_adjustments.last.data['discount_id'])
    end

    def test_prevents_empty_orders_from_receiving_free_item_with_no_conditions
      create_free_gift_discount(sku: 'SKU2')

      order = Order.new
      Pricing.perform(order)
      assert(order.no_items?)
    end

    def test_prevents_non_discountable_items_form_contributing_to_free_item_subtotal_conditions
      create_pricing_sku(id: 'SKU1', discountable: false, prices: [{ regular: 5.to_m }])
      create_pricing_sku(id: 'SKU2', discountable: false, prices: [{ regular: 5.to_m }])
      create_pricing_sku(id: 'SKU3', discountable: false, prices: [{ regular: 5.to_m }])

      create_free_gift_discount(
        sku: 'SKU3',
        order_total_operator: :greater_than,
        order_total: 5.to_m
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU1', discountable: false)
      order.add_item(product_id: 'PRODUCT', sku: 'SKU2', discountable: false)

      Pricing.perform(order)

      assert_equal(2, order.items.length)
      refute(order.items.first.free_gift)
      refute(order.items.second.free_gift)
    end

    def test_prevents_non_discountable_items_from_contributing_to_buy_some_get_some_subtotal_conditions
      create_pricing_sku(id: 'SKU1', discountable: false, prices: [{ regular: 5.to_m }])
      create_pricing_sku(id: 'SKU2', prices: [{ regular: 4.to_m }])

      create_buy_some_get_some_discount(
        purchase_quantity: 1,
        apply_quantity: 1,
        percent_off: 100,
        order_total_operator: :greater_than,
        order_total: 5.to_m
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU1')
      order.add_item(product_id: 'PRODUCT', sku: 'SKU2')

      Pricing.perform(order)

      assert_equal(2, order.items.length)
      assert_equal(1, order.items.first.price_adjustments.length)
      assert_equal(1, order.items.second.price_adjustments.length)
    end

    def test_never_over_discounts_on_a_product_discount
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      discount = create_product_discount(
        amount_type: 'flat',
        amount: 10,
        product_ids: ['PRODUCT']
      )

      order = Order.new
      order.items.build(product_id: 'PRODUCT', sku: 'SKU', quantity: 1)

      Pricing.perform(order)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal(-5.to_m, order.items.first.price_adjustments.last.amount)
      assert_equal(discount.id.to_s, order.items.first.price_adjustments.last.data['discount_id'])
    end

    def test_prevents_non_discountable_items_from_contributing_to_product_subtotal_conditions
      create_pricing_sku(id: 'SKU1', prices: [{ regular: 5.to_m }])
      create_pricing_sku(id: 'SKU2', prices: [{ regular: 4.to_m }])

      create_product_discount(
        amount_type: 'flat',
        amount: 2,
        product_ids: ['PRODUCT2'],
        order_total_operator: :greater_than,
        order_total: 5.to_m
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT1', sku: 'SKU1', discountable: false)
      order.add_item(product_id: 'PRODUCT2', sku: 'SKU2')

      Pricing.perform(order)

      assert_equal(2, order.items.length)
      assert_equal(1, order.items.first.price_adjustments.length)
      assert_equal(1, order.items.second.price_adjustments.length)
    end

    def test_prevents_a_negative_price_from_over_discounting_on_order_total_discount
      create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

      order = Order.new
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      discount = create_order_total_discount(
        amount_type: 'flat',
        amount: 10
      )

      Pricing.perform(order)

      assert_equal(2, order.items.first.price_adjustments.length)
      assert_equal('order', order.items.first.price_adjustments.last.price)
      assert_equal(-5.to_m, order.items.first.price_adjustments.last.amount)
      assert_equal(discount.id.to_s, order.items.first.price_adjustments.last.data['discount_id'])
    end

    def test_only_applies_discounts_with_matching_shipping_services
      create_shipping_discount(
        shipping_service: 'Next Day',
        amount: 10.to_m
      )

      order = Order.new

      shipping = Shipping.new
      shipping.set_shipping_service(
        name: 'Ground',
        tax_code: '001',
        base_price: 3.to_m
      )
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      Pricing.perform(order, shipping)

      assert_equal(1, shipping.price_adjustments.length)
      assert_equal(3.to_m, shipping.price_adjustments.last.amount)
    end

    def test_valid_promo_code_is_only_true_when_there_is_a_discount_with_this_promo_code
      refute(Pricing.valid_promo_code?('FOoBaR'))

      create_product_discount(promo_codes: ['FOOBAR'])
      assert(Pricing.valid_promo_code?('FOoBaR'))
    end

    def test_valid_promo_code_is_false_if_the_discount_is_not_active
      create_product_discount(active: false, promo_codes: ['FOOBAR'])
      refute(Pricing.valid_promo_code?('FOoBaR'))
    end

    def test_valid_promo_code_is_false_if_the_user_already_used_the_single_use_promo_code
      discount = create_product_discount(
        single_use: true,
        promo_codes: ['FOOBAR']
      )

      discount.redemptions.create!(email:  'bcrouse@workarea.com')

      refute(Pricing.valid_promo_code?('FOOBAR', 'bcrouse@workarea.com'))
    end

    def test_valid_promo_code_is_true_if_there_is_a_generated_promo_code_with_this_promo_code
      refute(Pricing.valid_promo_code?('FOoBaR'))

      code_list = create_code_list(count: 5)
      code_list.promo_codes.create!(code: 'FOoBaR', expires_at: Time.current + 1.day)
      create_product_discount(generated_codes_id: code_list.id)

      assert(Pricing.valid_promo_code?('FOoBaR'))
    end

    def test_exluding_items_that_are_excluded_from_the_discount
      create_pricing_sku(id: 'SKU1', tax_code: '001', prices: [{ regular: 5.to_m }])
      create_pricing_sku(id: 'SKU2', tax_code: '001', prices: [{ regular: 7.to_m }])
      create_pricing_sku(id: 'SKU3', tax_code: '001', prices: [{ regular: 9.to_m }])

      discount = create_order_total_discount(
        name: 'Test Discount',
        amount_type: 'percent',
        amount: 10,
        excluded_product_ids: %w(PRODUCT1),
        excluded_category_ids: %w(CATEGORY1)
      )

      create_tax_category(
        code:  '001',
        rates: [{ percentage: 0.06, region: 'PA', country: 'US' }]
      )

      order = Order.new
      order.add_item(product_id: 'PRODUCT1', sku: 'SKU1')
      order.add_item(product_id: 'PRODUCT2', sku: 'SKU2')
      order.add_item(product_id: 'PRODUCT2', sku: 'SKU3', category_ids: %w(CATEGORY1))

      shipping = Shipping.new

      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      shipping.set_shipping_service(
        id: 'GROUND',
        name: 'Ground',
        base_price: 3.to_m,
        tax_code: '001'
      )

      Pricing.perform(order, shipping)

      assert_equal(21.to_m, order.subtotal_price)
      assert_equal(3.to_m, order.shipping_total)
      assert_equal(1.40.to_m, order.tax_total)
      assert_equal(-0.7.to_m, order.discount_total)
      assert_equal(20.30.to_m, order.total_value)
      assert_equal(24.70.to_m, order.total_price)

      discount.update(order_total: 10.to_m)

      Pricing.perform(order, shipping)

      assert_equal(21.to_m, order.subtotal_price)
      assert_equal(3.to_m, order.shipping_total)
      assert_equal(1.44.to_m, order.tax_total)
      assert_equal(0.to_m, order.discount_total)
      assert_equal(21.to_m, order.total_value)
      assert_equal(25.44.to_m, order.total_price)
    end
  end
end
