module Workarea
  module AddressesHelper
    def country_options
      Workarea.config.countries.map do |country|
        [country.name, country.alpha2]
      end
    end

    def region_options
      @region_options ||= Workarea.config.countries.reduce([]) do |memo, country|
        regions = country.subdivisions
                    .map { |id, region| [region.translations[I18n.locale.to_s] || region.name, id] }
                    .sort_by { |name, id| name || id }

        memo << [country.name, regions]
        memo
      end
    end

    def formatted_address(address)
      pieces = {
        recipient: "#{address.first_name} #{address.last_name}\n#{address.company}".strip,
        street: "#{address.street} #{address.street_2}".strip,
        city: address.city,
        region: address.region_name,
        region_short: address.region,
        postalcode: address.postal_code,
        country: address.country.alpha2
      }

      address_format = address.country.address_format || Country['US'].address_format
      result = pieces.reduce(address_format) do |memo, (name, value)|
        memo.gsub(/{{#{name}}}/, html_escape(value.to_s))
      end

      if address.phone_number.present?
        formatted_phone = number_to_phone(
          address.phone_number,
          extension: address.phone_extension
        )

        result << "\n#{formatted_phone}"
      end

      result.gsub(/\n/, tag(:br)).html_safe
    end
  end
end
