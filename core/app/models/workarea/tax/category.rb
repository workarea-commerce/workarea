module Workarea
  module Tax
    class Category
      include ApplicationDocument

      field :name, type: String
      field :code, type: String

      index({ code: 1 }, { unique: true })

      has_many :rates, class_name: 'Workarea::Tax::Rate'

      validates :name, presence: true
      validates :code, presence: true, uniqueness: true

      after_save :expire_code_cache

      def self.find_by_code(code)
        Rails.cache.fetch("tax_rate_#{code}", expires_in: Workarea.config.cache_expirations.tax_rate_by_code) do
          find_by(code: code) rescue nil
        end
      end

      def find_rate(price, country, region, postal_code)
        RateLookup.find_best_rate(
          price: price,
          country: country,
          region: region,
          postal_code: postal_code,
          category: self
        )
      end

      def tiered?
        @tiered ||= rates.any_of(
          { :'tier_min.cents'.exists => true },
          { :'tier_max.cents'.exists => true }
        ).exists?
      end

      private

      def expire_code_cache
        Rails.cache.delete("tax_rate_#{code}")
      end
    end
  end
end
