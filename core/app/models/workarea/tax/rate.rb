module Workarea
  module Tax
    class Rate
      include ApplicationDocument


      field :country_percentage, type: Float, default: 0
      field :region_percentage, type: Float, default: 0
      field :postal_code_percentage, type: Float, default: 0
      field :country, type: Country
      field :region, type: String
      field :postal_code, type: String
      field :charge_on_shipping, type: Boolean, default: true
      field :tier_min, type: Money
      field :tier_max, type: Money

      # This field is deprecated in favor of the more specific percentage fields
      # TODO: Remove in v3.6,
      field :percentage, type: Float, default: 0
      alias_method :percentage=, :postal_code_percentage=

      index({ category_id: 1, country: 1, region: 1, postal_code: 1 })
      index({ country: 1 })
      index({ region: 1 })
      index({ postal_code: 1 })
      index({ 'tier_min.cents': 1 })
      index({ 'tier_max.cents': 1 })

      belongs_to :category,
        class_name: 'Workarea::Tax::Category',
        inverse_of: :rates,
        index: true

      def self.search(query)
        return all unless query.present?

        regex = /^#{::Regexp.quote(query)}/i
        country = Country[query]

        clauses = [{ region: regex }, { postal_code: regex }]
        clauses << { country: country } if country.present?

        any_of(clauses)
      end

      def self.sorts
        [Sort.country, Sort.region, Sort.postal_code, Sort.newest, Sort.modified]
      end

      def valid?(*)
        super.tap do
          self.region = nil if region.blank?
          self.postal_code = nil if postal_code.blank?
          self.percentage ||= 0
        end
      end

      def percentage
        percentage_field = super
        return percentage_field unless percentage_field.zero?

        [country_percentage, region_percentage, postal_code_percentage]
          .compact
          .sum
      end
    end
  end
end
