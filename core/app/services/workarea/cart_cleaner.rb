module Workarea
  class CartCleaner
    attr_reader :cart

    def initialize(cart)
      @cart = cart
    end

    def messages
      @messages ||= []
    end

    def message?
      messages.present?
    end

    def clean
      items_to_remove = []

      cart.items.each do |item|
        product = products.detect { |p| p.id == item.product_id }
        variant = product && product.variants.detect { |v| v.sku == item.sku }
        price = pricing.for_sku(item.sku, quantity: item.quantity)

        if product.blank?
          items_to_remove << item.id
          self.messages << I18n.t('workarea.carts.product_unavailable', product_id: item.product_id)
          next
        end

        unless product.purchasable? && variant.try(:active?)
          items_to_remove << item.id
          self.messages << I18n.t('workarea.carts.product_unavailable', product_id: item.product_id)
          next
        end

        unless price.persisted?
          items_to_remove << item.id
          self.messages << I18n.t('workarea.carts.product_unavailable', product_id: item.product_id)
          next
        end
      end

      items_to_remove.each do |item_id|
        cart.remove_item(item_id)
      end
    end

    private

    def products
      @products ||= Catalog::Product.any_in(id: cart.items.map(&:product_id)).to_a
    end

    def pricing
      @pricing ||= Pricing::Collection.new(cart.items.map(&:sku))
    end
  end
end
