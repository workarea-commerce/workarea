module Workarea
  module Pricing
    module TaxApplication
      extend ActiveSupport::Concern
      include GuardNegativePrice

      def calculate_tax_amounts(taxable_amount, rate)
        {
          'country_amount' => calculate_tax_amount(taxable_amount, rate.country_percentage),
          'region_amount' => calculate_tax_amount(taxable_amount, rate.region_percentage),
          'postal_code_amount' => calculate_tax_amount(taxable_amount, rate.postal_code_percentage)
        }
      end

      def calculate_tax_amount(amount, percentage)
        return 0.to_m unless percentage.present?
        guard_negative_price { amount * percentage }
      end
    end
  end
end
