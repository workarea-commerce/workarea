module Workarea
  class Shipping
    class Service
      include ApplicationDocument

      field :_id, type: String, default: -> { BSON::ObjectId.new }
      field :carrier, type: String
      field :name, type: String, localize: true
      field :service_code, type: String
      field :tax_code, type: String
      field :subtotal_min, type: Money
      field :subtotal_max, type: Money

      field :country, type: Country
      field :regions, type: Array, default: []
      list_field :regions

      index({ carrier: 1, name: 1 })

      embeds_many :rates, class_name: 'Workarea::Shipping::Rate'

      validates :name, presence: true
      validates :rates, presence: true
      validate  :rate_tiering

      after_save :expire_cache
      after_destroy :expire_cache

      def self.cache
        Rails.cache.fetch('shipping_services_cache', expires_in: Workarea.config.cache_expirations.shipping_services) do
          Shipping::Service.all.to_a
        end
      end

      def self.for_location(country, region)
        Shipping::LocationQuery.new(cache, country, region).location_services
      end

      def self.by_price(price)
        cache.select do |service|
          (service.subtotal_min.nil? || service.subtotal_min <= price) &&
            (service.subtotal_max.nil? || service.subtotal_max >= price)
        end
      end

      def self.find_tax_code(carrier, name)
        service = find_by(carrier: carrier, name: name) rescue nil
        service.present? ? service.tax_code : default_tax_code(carrier, name)
      end

      def self.default_tax_code(carrier, name)
        default = Workarea.config.default_shipping_service_tax_code
        return default unless default.respond_to?(:call)

        default.call(carrier, name)
      end

      def find_rate(price = 0.to_m)
        if tiered?
          rates.detect do |rate|
            (rate.tier_min.nil? || rate.tier_min <= price) &&
              (rate.tier_max.nil? || rate.tier_max >= price)
          end
        else
          rates.first
        end
      end

      def tiered?
        rates.any?(&:tiered?)
      end

      def to_option(subtotal)
        price = find_rate(subtotal).price
        ShippingOption.new(attributes.merge(name: name, price: price))
      end

      private

      def rate_tiering
        non_tiered_rates = rates.reject(&:tiered?)

        if non_tiered_rates.length > 1
          errors.add(
            :rates,
            I18n.t('workarea.errors.messages.exceeds_non_tiered_rate_limit')
          )
        end
      end

      def expire_cache
        Rails.cache.delete('shipping_services_cache')
      end
    end
  end
end
