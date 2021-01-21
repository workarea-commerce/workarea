module Workarea
  module DiscountConditionTests
    module OrderTotal
      def test_use_order_total?
        refute(order_total_discount.use_order_total?)

        order_total_discount.order_total = 0
        refute(order_total_discount.use_order_total?)

        order_total_discount.order_total = 1.to_m
        assert(order_total_discount.use_order_total?)
      end

      def test_order_total_qualifies?
        discounted_order.subtotal_price = 5.to_m

        assert(order_total_discount.order_total_qualifies?(discounted_order))

        order_total_discount.order_total_operator = :less_than

        order_total_discount.order_total = 4
        refute(order_total_discount.order_total_qualifies?(discounted_order))

        order_total_discount.order_total = 5
        refute(order_total_discount.order_total_qualifies?(discounted_order))

        order_total_discount.order_total = 6
        assert(order_total_discount.order_total_qualifies?(discounted_order))

        order_total_discount.order_total_operator = :greater_than

        order_total_discount.order_total = 4
        assert(order_total_discount.order_total_qualifies?(discounted_order))

        order_total_discount.order_total = 5
        refute(order_total_discount.order_total_qualifies?(discounted_order))

        order_total_discount.order_total = 6
        refute(order_total_discount.order_total_qualifies?(discounted_order))
      end
    end

    module PromoCodes
      def test_promo_codes_qualify?
        assert(promo_codes_discount.promo_codes_qualify?(discounted_order))

        promo_codes_discount.promo_codes = %w(oNe TwO)

        discounted_order.promo_codes = ['three']
        refute(promo_codes_discount.promo_codes_qualify?(discounted_order))

        discounted_order.promo_codes = ['one']
        assert(promo_codes_discount.promo_codes_qualify?(discounted_order))

        code_list = create_code_list
        code_list.generate_promo_codes!

        code = code_list.promo_codes.first.code

        assert(promo_codes_discount.promo_codes_qualify?(discounted_order))

        promo_codes_discount.generated_codes_id = code_list.id
        discounted_order.promo_codes = [code.upcase]

        assert(promo_codes_discount.promo_codes_qualify?(discounted_order))

        promo_codes_discount.generated_codes_id = code_list.id
        discounted_order.promo_codes = ['lkajwf']

        refute(promo_codes_discount.promo_codes_qualify?(discounted_order))
      end
    end

    module ItemQuantity
      def test_item_quantity?
        item_quantity_discount.item_quantity = nil
        refute(item_quantity_discount.item_quantity?)

        item_quantity_discount.item_quantity = 0
        refute(item_quantity_discount.item_quantity?)

        item_quantity_discount.item_quantity = 1
        assert(item_quantity_discount.item_quantity?)
      end

      def test_items_qualify?
        discounted_order.items.first.quantity = 2

        # When there is no item_quantity, quantity is ignored
        assert(item_quantity_discount.items_qualify?(discounted_order))

        item_quantity_discount.item_quantity = 2
        assert(item_quantity_discount.items_qualify?(discounted_order))

        item_quantity_discount.item_quantity = 3
        refute(item_quantity_discount.items_qualify?(discounted_order))
      end
    end
  end
end
