module Workarea
  class Lint
    class SkusMissingVariants < Lint
      def run
        all_skus.each do |sku|
          unless catalog_skus.include?(sku)
            error("#{sku},Missing Catalog::Variant")
          end
        end
      end

      def all_skus
        (pricing_skus + inventory_skus).uniq
      end
    end
  end
end
