module Workarea
  class Lint
    class SkusMissingInventory < Lint
      def run
        catalog_skus.each do |sku|
          unless inventory_skus.include?(sku)
            error("#{sku}, Has Catalog::Variant but no matching Inventory::Sku")
          end
        end

        pricing_skus.each do |sku|
          if !catalog_skus.include?(sku) && !inventory_skus.include?(sku)
            error("#{sku},Has Pricing::Sku but no matching Inventory::Sku")
          end
        end
      end
    end
  end
end
