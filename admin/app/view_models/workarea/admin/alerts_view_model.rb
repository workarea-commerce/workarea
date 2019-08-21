module Workarea
  module Admin
    class AlertsViewModel < ApplicationViewModel
      def size
        predicate_alerts = [
          :show_products_missing_prices?,
          :show_empty_categories?,
          :show_products_missing_images?,
          :show_products_missing_descriptions?,
          :show_products_missing_variants?,
          :show_products_missing_categories?,
          :show_products_low_inventory?,
          :show_products_variants_missing_details?,
          :show_products_inconsistent_variant_details?
        ]

        result = 0
        predicate_alerts.each { |m| result += 1 if send(m) }
        result += empty_upcoming_releases.length
        result
      end

      def show_products_missing_prices?
        products_missing_prices > 0
      end

      def show_empty_categories?
        empty_categories > 0
      end

      def show_products_missing_images?
        products_missing_images > 0
      end

      def show_products_missing_descriptions?
        products_missing_descriptions > 0
      end

      def show_products_missing_variants?
        products_missing_variants > 0
      end

      def show_products_missing_categories?
        products_missing_categories > 0
      end

      def show_products_low_inventory?
        products_low_inventory > 0
      end

      def show_products_variants_missing_details?
        products_variants_missing_details > 0
      end

      def show_products_inconsistent_variant_details?
        products_inconsistent_variant_details > 0
      end
    end
  end
end
