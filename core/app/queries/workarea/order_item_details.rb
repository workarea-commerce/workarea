module Workarea
  class OrderItemDetails
    class InvalidPurchase < StandardError; end

    attr_reader :product, :sku

    delegate :digital?, to: :product

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

    def to_h
      {
        product_id: product.id,
        product_attributes: product.as_document,
        category_ids: category_ids,
        discountable: pricing.discountable?
      }
    end
  end
end
