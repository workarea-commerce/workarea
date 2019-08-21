module Workarea
  module Factories
    module Pricing
      Factories.add(self)

      def create_buy_some_get_some_discount(overrides = {})
        attributes = factory_defaults(:buy_some_get_some_discount).merge(overrides)
        Workarea::Pricing::Discount::BuySomeGetSome.create!(attributes)
      end

      def create_category_discount(overrides = {})
        attributes = factory_defaults(:category_discount).merge(overrides)
        Workarea::Pricing::Discount::Category.create!(attributes)
      end

      def create_code_list(overrides = {})
        attributes = factory_defaults(:code_list).merge(overrides)
        Workarea::Pricing::Discount::CodeList.new(attributes).tap do |code_list|
          code_list.save!
        end
      end

      def create_free_gift_discount(overrides = {})
        attributes = factory_defaults(:free_gift_discount).merge(overrides)
        Workarea::Pricing::Discount::FreeGift.create!(attributes)
      end

      def create_order_total_discount(overrides = {})
        attributes = factory_defaults(:order_total_discount).merge(overrides)
        Workarea::Pricing::Discount::OrderTotal.create!(attributes)
      end

      def create_pricing_sku(overrides = {})
        attributes = factory_defaults(:pricing_sku).merge(overrides)
        Workarea::Pricing::Sku.new(attributes).tap(&:save!)
      end

      def create_product_attribute_discount(overrides = {})
        attributes = factory_defaults(:product_attribute_discount).merge(overrides)
        Workarea::Pricing::Discount::ProductAttribute.create!(attributes)
      end

      def create_product_discount(overrides = {})
        attributes = factory_defaults(:product_discount).merge(overrides)
        Workarea::Pricing::Discount::Product.create!(attributes)
      end

      def create_quantity_fixed_price_discount(overrides = {})
        attributes = factory_defaults(:quantity_fixed_price_discount).merge(overrides)
        Workarea::Pricing::Discount::QuantityFixedPrice.create!(attributes)
      end

      def create_shipping_discount(overrides = {})
        attributes = factory_defaults(:shipping_discount).merge(overrides)
        Workarea::Pricing::Discount::Shipping.create!(attributes)
      end
    end
  end
end
