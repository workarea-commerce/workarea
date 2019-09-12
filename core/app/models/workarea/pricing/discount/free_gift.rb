module Workarea
  module Pricing
    class Discount
      # This discount allows free gifts, which are automatically
      # added to the {Workarea::Order} when it qualifies.
      #
      class FreeGift < Discount
        include Conditions::OrderTotal
        include Conditions::PromoCodes
        include Conditions::UserTags

        # @!attribute sku
        #   @return [String] the SKU of the free gift
        #
        field :sku, type: String

        # @!attribute product_ids
        #   @return [String] get the free gift when purchasing
        #     one of {Catalog::Product}
        #
        field :product_ids, type: Array, default: []
        list_field :product_ids

        # @!attribute category_ids
        #   @return [String] get the free gifts when purchasing from
        #     one of these {Catalog::Category}
        #
        field :category_ids, type: Array, default: []
        list_field :category_ids

        validates :sku, presence: true

        before_save :clean_catalog_ids

        # @private
        def self.model_name
          Discount.model_name
        end

        # Price changes apply at the item level
        #
        # @return [String]
        #
        self.price_level = 'item'
        add_qualifier :order_not_empty?
        add_qualifier :catalog_qualifies?

        # Qualifier method for whether the order is empty. You can't
        # receive a free gift on an empty order.
        #
        # @param [Workarea::Order] order
        # @return [Boolean]
        #
        def order_not_empty?(order)
          order.items.reject(&:free_gift?).any?
        end

        # Qualifier method for whether either products or categories
        # match so this order receives the discount.
        #
        # @param [Workarea::Order] order
        # @return [Boolean]
        #
        def catalog_qualifies?(order)
          return true if product_ids.blank? && category_ids.blank?
          products_qualify?(order) || categories_qualify?(order)
        end

        # Apply the discount, which adds the free gift item to the
        # order, along with a dummy price adjustment.
        #
        # @param [Workarea::Order] order
        #
        def apply(order)
          free_item = Workarea::Order::Item.new(
            {
              sku: sku,
              free_gift: true,
              quantity: 1
            }.merge(free_product_attributes(sku))
          )

          sell_price = Sku.find_or_create_by(id: sku).sell_price

          free_item.adjust_pricing(adjustment_data(sell_price, 1))
          order.add_item(free_item)
        end

        # Remove any free items this discount may have added to the order.
        #
        # @param [Workarea::Order] order
        # @param [Workarea::Shipping] shipping
        # @return [Workarea::Order]
        #
        def remove_from(order, shipping = nil)
          order.items.each do |item|
            matches = !!item.price_adjustments.detect do |adjustment|
              adjustment.data['discount_id'] == id.to_s
            end

            order.remove_item(item) if matches
          end

          order
        end

        private

        def clean_catalog_ids
          self.product_ids = product_ids.reject(&:blank?)
          self.category_ids = category_ids.reject(&:blank?)
        end

        def adjustment_data(value, quantity)
          super.merge(amount: 0.to_m)
        end

        def products_qualify?(order)
          order.items.any? { |i| i.matches_products?(product_ids) }
        end

        def categories_qualify?(order)
          order.items.any? { |i| i.matches_categories?(category_ids) }
        end

        def free_product_attributes(sku)
          ttl = Workarea.config.cache_expirations.free_gift_attributes
          key = ['workarea/free_gift', sku, Release.current&.id].compact.join('/')

          Rails.cache.fetch(key, expires_in: ttl) do
            Workarea::OrderItemDetails.find(sku).try(:to_h) || {}
          end
        end
      end
    end
  end
end
