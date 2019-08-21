module Workarea
  class Lint
    class InconsistentDetails < Lint
      def run
        Catalog::Product.all.each_by(100) do |product|
          all_options = product
                          .variants
                          .map { |v| v.details.keys }
                          .flatten
                          .uniq
                          .sort

          product.variants.each do |variant|
            check_details(all_options, variant)
          end
        end
      end

      def check_details(all_options, variant)
        if variant.details.blank?
          warn("#{variant.product.id},#{variant.sku},missing details")
        else
          all_options.each do |option|
            if variant.details[option].blank?
              warn("#{variant.product.id},#{variant.sku},missing detail `#{option}`")
            end
          end
        end
      end
    end
  end
end
