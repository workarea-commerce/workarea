require 'test_helper'

module Workarea
  class MarkDiscountsAsRedeemedTest < Workarea::TestCase
    setup do
      @product_discount = create_product_discount
      @shipping_discount = create_shipping_discount

      @order = Order.new
      @order.items.build(
        price_adjustments: [
          { data: { 'discount_id' => @product_discount.id } }
        ]
      )

      @shipping = Shipping.new
      @shipping.price_adjustments.build(
        { data: { 'discount_id' => @shipping_discount.id } }
      )
    end

    def test_marking_redemptions_for_orders_and_shippings
      MarkDiscountsAsRedeemed.new.mark_redeemed(@order, [@shipping])

      assert_equal(@product_discount.redemptions.count, 1)
      assert_equal(@shipping_discount.redemptions.count, 1)
    end

    def test_touching_the_discount
      current_value = @product_discount.updated_at
      travel_to(Time.current + 1.second)
      MarkDiscountsAsRedeemed.new.mark_redeemed(@order, [@shipping])
      @product_discount.reload

      assert_not_equal(current_value, @product_discount.updated_at)
    end

    def test_apply_first_promo_code_matching_discount
      code_list = create_code_list(count: 5).tap(&:generate_promo_codes!)
      first_promo_code = code_list.promo_codes.first
      second_promo_code = code_list.promo_codes.second
      @order.promo_codes = [first_promo_code, second_promo_code].map(&:code)

      @product_discount.update!(generated_codes_id: code_list.id)
      MarkDiscountsAsRedeemed.new.mark_redeemed(@order, [@shipping])

      assert(first_promo_code.reload.used_at.present?)
      refute(second_promo_code.reload.used_at.present?)
    end
  end
end
