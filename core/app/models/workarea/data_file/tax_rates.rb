module Workarea
  module DataFile
    class TaxRates < Format
      def import!
        index = 1

        CSV.foreach(file.path, csv_options) do |row|
          instance = find_updated_model_for(rate_attributes(row.to_hash))
          instance.save

          log(index, instance)
          index += 1
        end
      end

      private

      def csv_options
        {
          headers: true,
          return_headers: false,
          header_converters: -> (h) { h.underscore.optionize.to_sym }
        }
      end

      def rate_attributes(row)
        tier_range(row)
          .merge(
            category_id: tax_category_id,
            region: row[:state],
            country: row[:country] || 'US',
            postal_code: row[:zip_code],
            percentage: row[:estimated_combined_rate],
            country_percentage: row[:federal_rate],
            region_percentage: row[:state_rate],
            postal_code_percentage: row[:county_rate],
            charge_on_shipping: row[:charge_on_shipping] !~ /false/i
          )
      end

      def tier_range(row)
        tier = {}
        tier[:tier_min] = row[:tier_min] if row[:tier_min].present?
        tier[:tier_max] = row[:tier_max] if row[:tier_max].present?
        tier
      end

      def find_updated_model_for(attrs)
        id = attrs['_id'].presence || attrs['id']

        if id.present?
          result = Tax::Rate.find_or_initialize_by(id: id)
          result.attributes = attrs
          result
        else
          Tax::Rate.new(attrs)
        end
      end
    end
  end
end
