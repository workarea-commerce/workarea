module Workarea
  module Pricing
    # Build price adjustments and set order total prices.
    # Does nothing if the order isn't valid.
    #
    # @param [Workarea::Order] order
    # @return [self]
    #
    def self.perform(order, shippings = nil)
      shippings = Array(shippings)
      return self unless order.save && shippings.all?(&:save)

      request = Request.new(order, shippings)
      request.run
      request.save!

      self
    end

    # Find the price adjustments for shipping discounts that
    # would apply to a given order.
    #
    # Used in {Checkout::ShippingOptions} to determine
    # the prices post-discounting for available shipping
    # methods.
    #
    # @param [Workarea::Order]
    # @return [Array<PriceAdjustment>]
    #
    def self.find_shipping_discounts(order, shipping)
      request = Request.new(order, shipping)
      request.run
      request.shippings.first.price_adjustments.adjusting('shipping').discounts
    end

    # Find whether a promo code is valid to apply
    #
    # @param [String] promo code
    # @return [Boolean] whether it is valid
    #
    def self.valid_promo_code?(promo_code, email = nil)
      discounts = Discount
                    .where(:promo_codes.in => [promo_code.downcase])
                    .to_a

      return true if discounts.any? do |discount|
        discount.active? &&
          (email.blank? ||
           !discount.single_use? ||
           !discount.has_been_redeemed?(email))
      end

      Discount::GeneratedPromoCode.valid_code?(promo_code)
    end
  end
end
