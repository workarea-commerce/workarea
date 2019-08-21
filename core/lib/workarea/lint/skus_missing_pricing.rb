module Workarea
  class Lint
    class SkusMissingPricing < Lint
      def run
        catalog_skus.each do |sku|
          unless pricing_skus.include?(sku)
            error("#{sku},Has Catalog::Variant but no matching Pricing::Sku")
          end
        end

        inventory_skus.each do |sku|
          if !catalog_skus.include?(sku) && !pricing_skus.include?(sku)
            error("#{sku},Has Inventory::Sku but no matching Pricing::Sku")
          end
        end
      end
    end
  end
end
