module Workarea
  class Shipping
    include ApplicationDocument
    include DiscountIds

    field :order_id, type: String
    field :quantities, type: Hash, default: {}
    field :shipping_total, type: Money, default: 0
    field :tax_total, type: Money, default: 0
    field :instructions, type: String

    index({ order_id: 1, created_at: 1 })
    index({ created_at: 1 })

    embeds_one :address,
      class_name: 'Workarea::Shipping::Address',
      as: :addressable
    embeds_one :shipping_service,
      class_name: 'Workarea::Shipping::ServiceSelection'
    embeds_many :price_adjustments,
      class_name: 'Workarea::PriceAdjustment',
      extend: PriceAdjustmentExtension

    validates :instructions, length: { maximum: 500 }

    scope :by_order, ->(order_id) { where(order_id: order_id) }
    scope :since, ->(time) { where(:created_at.gte => time) }

    before_validation :typecast_quantities

    # Finds the first Shipping for the given order ID.
    #
    # @param [String]
    # @return [Shipping]
    #
    def self.find_by_order(order_id)
      where(order_id: order_id).desc(:created_at).first
    end

    # For compatibility with admin features, models must respond to this method
    #
    # @return [String]
    #
    def name
      order_id
    end

    # Whether this {Shipping} is shippable. It is shippable if it has a
    # valid shipping address and a valid shipping service.
    #
    # @return [Boolean]
    #
    def shippable?
      valid? && address.present? && shipping_service.present?
    end

    def partial?
      quantities.present?
    end

    # Lookup available options for this shipping based on the subtotal
    # passed in.
    #
    # @param [Array<ActiveShipping::Package>]
    # @return [Array<ShippingOption>]
    #
    def find_method_options(packages)
      return [] if address.blank? || packages.blank?

      origin = ActiveShipping::Location.new(Workarea.config.shipping_origin)
      response = Workarea.config.gateways.shipping.find_rates(
        origin,
        address.to_active_shipping,
        packages
      )

      response.rates.sort_by(&:price).map do |rate|
        ShippingOption.from_rate_estimate(rate)
      end
    end

    # Set shipping address on the order.
    #
    # @param [Hash] attrs
    #   the attributes of the shipping address
    #
    # @return [self]
    #
    def set_address(attrs = {})
      build_address if address.blank?
      address.attributes = attrs
      save
      self
    end

    # Set and persist shipping service attributes on the shipping.
    #
    # @return [Boolean]
    #
    def set_shipping_service(attrs = {})
      apply_shipping_service(attrs)
      save
    end

    # Set but do not persist shipping service attributes on the shipping.
    # Used when applying a shipping service to {Shipping} to see if it
    # qualifies for shipping discounts.
    #
    # @return [Boolean]
    #
    def apply_shipping_service(attrs = {})
      build_shipping_service unless shipping_service

      shipping_service.attributes = attrs
                                     .with_indifferent_access
                                     .slice(*ServiceSelection.fields.keys)

      if attrs[:base_price].present?
        reset_shipping_pricing
        adjust_pricing(
          price: 'shipping',
          amount: attrs[:base_price],
          description: shipping_service.name,
          calculator: self.class.name,
          data: { 'tax_code' => attrs[:tax_code] }
        )
      end
    end

    # Adds a price adjustment to the shipping service. Does not
    # persist.
    #
    # @return [self]
    #
    def adjust_pricing(options = {})
      price_adjustments.build(options)
    end

    # Remove any {PriceAdjustment}s on the shipping cost except the base
    # shipping cost adjustment which was set with other shipping service info.
    # This is used in the {Pricing::Request} when resetting shipping for
    # pricing.
    #
    # @return [Array<PriceAdjustment>]
    #
    def reset_adjusted_shipping_pricing
      keepers = price_adjustments.select do |adjustment|
        adjustment.calculator == self.class.name
      end

      self.price_adjustments = keepers
    end

    # Price of shipping service from carrier - without taxes or discounts.
    #
    # @return [Money, nil]
    #
    def base_price
      price_adjustments.detect do |price_adjustment|
        price_adjustment.price == 'shipping' &&
          price_adjustment.calculator == self.class.name
      end.try(:amount)
    end

    private

    def typecast_quantities
      self.quantities = quantities.map { |id, q| [id.to_s, q.to_i] }.to_h
    end

    def reset_shipping_pricing
      self.shipping_total = 0.to_m
      self.price_adjustments = []
    end
  end
end
