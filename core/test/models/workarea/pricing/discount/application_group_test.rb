require 'test_helper'

module Workarea
  module Pricing
    class Discount
      class ApplicationGroupTest < TestCase
        setup :create_models

        def create_models
          @order = create_order
          @shippings = [create_shipping(order_id: @order.id)]
          @discounts = Discount::Collection.new
        end

        def assert_compatible_sets(compatible_sets, results)
          compatible_sets.each do |compatible_set|
            match = results.detect do |result|
              result.discounts.length == compatible_set.length &&
                compatible_set.all? { |d| d.in?(result.discounts) }
            end

            assert(match.present?)
          end
        end

        def test_calculate_creates_a_group_for_each_unique_set_of_compatible_discounts
          discount_1 = create_product_discount
          discount_2 = create_product_discount(compatible_discount_ids: [discount_1.id])

          discount_3 = create_product_discount
          discount_4 = create_product_discount(compatible_discount_ids: [discount_3.id])
          discount_5 = create_product_discount(compatible_discount_ids: [discount_3.id])

          discount_6 = create_product_discount

          results = ApplicationGroup.calculate(@discounts, @order, @shippings)
          assert_equal(4, results.length)

          compatible_sets = [
            [discount_1, discount_2],
            [discount_3, discount_5],
            [discount_3, discount_4],
            [discount_6]
          ]

          assert_compatible_sets(compatible_sets, results)
        end

        def test_calculate_does_not_allow_hidden_incompatibilities
          discount_1 = create_product_discount
          discount_2 = create_product_discount(
            compatible_discount_ids: [discount_1.id]
          )
          discount_3 = create_product_discount(
            compatible_discount_ids: [discount_1.id]
          )
          discount_4 = create_product_discount(
            compatible_discount_ids: [
              discount_1.id,
              discount_2.id,
              discount_3.id
            ]
          )

          results = ApplicationGroup.calculate(@discounts, @order, @shippings)
          assert_equal(2, results.length)

          compatible_sets = [
            [discount_1, discount_2, discount_4],
            [discount_1, discount_3, discount_4]
          ]

          assert_compatible_sets(compatible_sets, results)
        end

        def test_calculate_returns_all_discounts_when_the_graph_is_complete
          compatible_sets = Array.new(5).map { create_product_discount }
          ids = compatible_sets.map(&:id).map(&:to_s)

          compatible_sets.each do |discount|
            discount.update_attributes(compatible_discount_ids: ids)
          end

          results = ApplicationGroup.calculate(@discounts, @order, @shippings)
          assert_equal(1, results.length)

          # need to sort discounts to resolve undefined behavior
          match = results.detect { |r| r.discounts.sort == compatible_sets.sort }
          assert(match.present?)
        end

        def test_calculate_returns_groups_when_the_graph_is_a_set_of_disjoint_complete_graphs
          @discounts = Array.new(20).map { create_product_discount }
          @discounts.each_slice(5) do |discount_subset|
            ids = discount_subset.map(&:id).map(&:to_s)
            discount_subset
              .each { |d| d.update_attributes(compatible_discount_ids: ids) }
          end

          results = ApplicationGroup.calculate(@discounts, @order, @shippings)
          assert_equal(4, results.length)

          @discounts.each_slice(5) do |discount_subset|
            # need to sort discounts to resolve undefined behavior
            match = results.detect { |r| r.discounts.sort == discount_subset.sort }
            assert(match.present?)
          end
        end

        def test_value_calculates_the_total_value_of_the_discounts
          create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

          create_order_total_discount(
            name: 'Discount',
            amount_type: 'flat',
            amount: 2
          )

          @order.add_item(product_id: 'PRODUCT', sku: 'SKU')
          Calculators::ItemCalculator.test_adjust(@order)

          group = ApplicationGroup.new(@discounts, @order, @shippings)
          assert_equal(2.to_m, group.value)
        end

        def test_value_always_returns_a_money_value
          create_shipping_discount
          create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

          @order.add_item(product_id: 'PRODUCT', sku: 'SKU')

          value = ApplicationGroup.new(@discounts, @order, @shippings).value
          assert_instance_of(Money, value)
        end

        def test_value_has_no_side_effects
          create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])

          create_order_total_discount(
            name: 'Discount',
            amount_type: 'flat',
            amount: 2
          )

          @order.add_item(product_id: 'PRODUCT', sku: 'SKU')
          Calculators::ItemCalculator.test_adjust(@order)

          ApplicationGroup.new(@discounts, @order, @shippings).value

          assert_equal(1, @order.items.first.price_adjustments.length)
        end

        def test_value_calculates_the_total_value_of_the_free_gift_discounts
          free_product = create_product(
            name: 'Free Product',
            variants: [{ sku: 'FREESKU', regular: 5.to_m }]
          )

          create_free_gift_discount(
            name: 'Free Item Discount',
            sku: free_product.skus.first
          )

          create_pricing_sku(id: 'SKU', prices: [{ regular: 5.to_m }])
          @order.add_item(product_id: 'PRODUCT', sku: 'SKU')
          Calculators::ItemCalculator.test_adjust(@order)

          group = ApplicationGroup.new(@discounts, @order, @shippings)
          assert_equal(5.to_m, group.value)
        end
      end
    end
  end
end
