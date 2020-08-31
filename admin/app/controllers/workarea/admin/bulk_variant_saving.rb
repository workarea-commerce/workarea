module Workarea
  module Admin
    module BulkVariantSaving
      def save_variant_on_product(product, attributes: {}, variant: nil)
        variant ||= product.variants.build

        variant.sku = attributes[:sku]
        variant.update_details(
          attributes[:detail_1_name] => attributes[:detail_1_value],
          attributes[:detail_2_name] => attributes[:detail_2_value],
          attributes[:detail_3_name] => attributes[:detail_3_value]
        )
        variant.save!

        if attributes[:price].present? || attributes[:tax_code].present?
          pricing = Pricing::Sku.find_or_create_by(id: variant.sku)
          pricing.tax_code = attributes[:tax_code]
          price = pricing.prices.first || pricing.prices.build
          price.regular = attributes[:price]
          pricing.save!
        end

        if attributes[:inventory].present?
          inventory = Inventory::Sku.find_or_initialize_by(id: variant.sku)
          inventory.available = attributes[:inventory]
          inventory.policy = 'standard' if inventory.new_record?
          inventory.save!
        end
      end
    end
  end
end
