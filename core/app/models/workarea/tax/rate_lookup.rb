module Workarea
  module Tax
    class RateLookup
      attr_reader :category, :price, :postal_code, :country, :region

      delegate :tiered?, :rates, to: :category

      def initialize(category: , price: , postal_code: nil, country: nil, region: nil)
        @category = category
        @price = price
        @postal_code = postal_code
        @country = country
        @region = region
      end

      # Find the best available rate for the given parameters.
      def self.find_best_rate(**options)
        new(**options).best_available_rate
      end

      def best_available_rate
        return if country.blank? && region.blank? && postal_code.blank?
        return tiered_rate if tiered?
        local_rate
      end

      def localized_rates
        if country.present? && region.blank? && postal_code.blank?
          country_rates
        elsif country.present? && region.present? && postal_code.blank?
          region_rates
        elsif country == Country['US'] && no_local_postal_code_rates?
          regional_postal_code_rates
        else
          postal_code_rates
        end
      end

      def local_rate
        localized_rates.first
      end

      def tiered_rate
        localized_rates.detect do |rate|
          (rate.tier_min.nil? || rate.tier_min <= price) &&
            (rate.tier_max.nil? || rate.tier_max >= price)
        end
      end

      def rates_in_country
        rates.where(country: country)
      end

      def country_rates
        rates_in_country
          .where(region_clause)
          .where(postal_code_clause)
      end

      def region_rates
        rates_in_country
          .where(region_clause)
          .where(postal_code_clause)
          .sort(region: -1)
      end

      def postal_code_rates
        rates_in_country
          .where(region_clause)
          .where(postal_code_clause)
          .sort(region: -1)
          .sort(postal_code: -1)
      end

      def no_local_postal_code_rates?
        rates_in_country
          .where(region_clause)
          .where(postal_code: postal_code)
          .none?
      end

      def regional_postal_code_rates
        rates_in_country
          .where(region_clause)
          .where(regional_postal_code_clause)
          .sort(region: -1)
          .sort(postal_code: -1)
      end

      def postal_code_clause
        { :postal_code.in => [nil, '', postal_code].uniq }
      end

      def regional_postal_code_clause
        { :postal_code.in => [nil, '', regional_postal_code].uniq }
      end

      def regional_postal_code
        postal_code.first(5)
      end

      def region_clause
        { :region.in => [nil, '', region].uniq }
      end
    end
  end
end
