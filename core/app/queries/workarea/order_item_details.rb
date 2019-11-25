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

    def to_h
      Rails.cache.fetch(cache_key, expires_in: cache_expiration) do
        {
          product_id: product.id,
          product_attributes: product.as_document,
          category_ids: category_ids,
          discountable: pricing.discountable?,
          fulfillment: fulfillment.policy
        }
      end
    end

    def cache_key
      "order_item_details/#{product.cache_key}/#{sku}"
    end

    def cache_expiration
      Workarea.config.cache_expirations.order_item_details
    end
  end
end
