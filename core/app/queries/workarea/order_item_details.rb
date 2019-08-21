module Workarea
  class OrderItemDetails
    class InvalidPurchase < StandardError; end

    attr_reader :product, :sku

    def self.find!(sku, product_id: nil)
      product =
        if product_id.present?
          Catalog::Product.where(id: product_id).find_by_sku(sku)
        else
          Catalog::Product.find_by_sku(sku)
        end
      raise InvalidPurchase, sku unless product && product.purchasable?

      new(product, sku)
    end

    def self.find(sku, product_id: nil)
      product =
        if product_id.present?
          Catalog::Product.where(id: product_id).find_by_sku(sku)
        else
          Catalog::Product.find_by_sku(sku)
        end

      return nil if product.blank?
      new(product, sku)
    end

    def initialize(product, sku)
      @product = product
      @sku = sku
    end

    def category_ids
      Categorization.new(product).to_a
    end

    def pricing
      @pricing ||= Pricing::Sku.find(sku)
    end

    def fulfillment
      @fulfillment ||= Fulfillment::Sku.find_or_initialize_by(id: sku)
    end

    # This is a stop-gap for transitioning away from a digital flag for
    # determining checkout behavior for items not requiring
    # physical fulfillment.
    #
    # TODO: remove #digital? usage in v3.6
    #
    def requires_shipping?
      !product.digital? && fulfillment.requires_shipping?
    end

    def to_h
      {
        product_id: product.id,
        product_attributes: product.as_document,
        category_ids: category_ids,
        discountable: pricing.discountable?,
        requires_shipping: requires_shipping?
      }
    end
  end
end
