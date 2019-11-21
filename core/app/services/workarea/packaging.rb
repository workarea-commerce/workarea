# Out of the box, the system assumes one package per order. This is a very naive
# implementation, but the complexities required to handle all the possibilities
# is beyond the scope of this system.
#
# If using a shipping gateway that relies on packaging, it is recommended you
# decorate this class and implement the logic the retailer prefers to use.
#
module Workarea
  class Packaging
    class Package < Struct.new(:weight, :dimensions, :value); end

    # Passing in the {Shipping} is optional, done in {ShippingOptions} to allow
    # easier customization for order with multiple {Shipping}.
    #
    def initialize(order, shipping = nil)
      @order = order
      @shipping = shipping
    end

    # Returns an Array out-of-the-box to allow easier multi-package
    # customization. Out-of-the-box will only ever return one package.
    #
    # @return Array<ActiveShipping::Package>
    #
    def packages
      [
        ActiveShipping::Package.new(
          total_weight,
          total_dimensions,
          Workarea.config.shipping_options.merge(value: total_value)
        )
      ]
    end

    def total_weight
      individual_packages.sum(&:weight)
    end

    def total_dimensions
      if individual_dimensions?
        stacked_dimensions
      else
        Workarea.config.shipping_dimensions
      end
    end

    def total_value
      individual_packages.sum(&:value)
    end

    def individual_dimensions?
      individual_packages.all? { |p| p.dimensions.present? }
    end

    private

    def find_shipping_sku(sku)
      shipping_skus.detect { |s| s.id == sku } || Shipping::Sku.new(id: sku)
    end

    def find_item_quantity(item)
      return item.quantity unless @shipping.present? && @shipping.partial?

      @shipping.quantities.detect do |item_id, quantity|
        item_id.to_s == item.id.to_s
      end.try(:last) || 0
    end

    def shipping_skus
      @shipping_skus ||= Shipping::Sku
                          .any_in(id: shippable_items.map(&:sku))
                          .to_a
    end

    def individual_packages
      shippable_items.reduce([]) do |memo, item|
        quantity = find_item_quantity(item)
        next memo unless quantity.positive?

        sku = find_shipping_sku(item.sku)
        unit_value = item.total_value / item.quantity

        quantity.times do
          memo << Package.new(sku.weight, sku.dimensions, unit_value)
        end

        memo
      end
    end

    def shippable_items
      @order.items.select(&:shipping?)
    end

    def stacked_dimensions
      total_height = individual_packages.map { |p| p.dimensions.first }.sum
      largest_width = individual_packages.map { |p| p.dimensions.second }.max
      largest_length = individual_packages.map { |p| p.dimensions.third }.max

      [largest_length, largest_width, total_height]
    end
  end
end
