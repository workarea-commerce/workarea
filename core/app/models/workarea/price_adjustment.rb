module Workarea
  class PriceAdjustment
    include ApplicationDocument

    # The type of price being adjusted.
    # One of - item, shipping, tax, order
    field :price, type: String

    # The quantity being adjusted. Used to calculate
    # unit.
    field :quantity, type: Integer, default: 1

    # Front-end display description of what caused
    # the price adjustment.
    field :description, type: String

    # The class that generated this price adjustment.
    field :calculator, type: String

    # Miscellaneous meta data around the price adjustment.
    # Used for discount qualification, tax_code, etc.
    field :data, type: Hash, default: {}

    # How much (positive or negative) this adjustment
    # changes the price.
    field :amount, type: Money

    # The cost per-unit of this price adjustment.
    #
    # @return [Money]
    #
    def unit
      amount / quantity
    end

    # Whether this adjustment was a discount.
    # A price adjustment is considered a discount if its amount is less than
    # zero and not a pricing override, or it has discount data.
    #
    # @return [Boolean]
    #
    def discount?
      (amount < 0 && data['override'].nil?) || data['discount_value'].present?
    end
  end
end
