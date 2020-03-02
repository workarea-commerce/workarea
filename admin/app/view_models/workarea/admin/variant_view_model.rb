module Workarea
  class Admin::VariantViewModel < ApplicationViewModel
    delegate :msrp, :on_sale, :on_sale?, :discountable,
      :discountable?, :tax_code, :sell_price, to: :pricing

    def pricing
      @pricing ||= Pricing::Sku.find_or_create_by(id: sku)
    end

    def inventory
      @inventory ||= Inventory::Sku.find_or_create_by(id: sku)
    end

    def available_inventory
      inventory.available_to_sell
    end

    def fulfillment
      @fulfillment ||= Fulfillment::Sku.find_or_create_by(id: sku)
    end

    def fulfillment_policy
      fulfillment.policy.titleize
    end

    def detail_1_name
      details_array.first.try(:first)
    end

    def detail_1_value
      details_array.first.try(:second)
    end

    def detail_2_name
      details_array.second.try(:first)
    end

    def detail_2_value
      details_array.second.try(:second)
    end

    def detail_3_name
      details_array.third.try(:first)
    end

    def detail_3_value
      details_array.third.try(:second)
    end

    private

    def details_array
      details.to_a
    end
  end
end
