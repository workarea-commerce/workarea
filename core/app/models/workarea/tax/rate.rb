module Workarea
  module Tax
    class Rate
      include ApplicationDocument

      field :percentage, type: Float, default: 0
      field :country, type: Country
      field :region, type: String
      field :postal_code, type: String
      field :charge_on_shipping, type: Boolean, default: true
      field :tier_min, type: Money
      field :tier_max, type: Money

      index({ category_id: 1, country: 1, region: 1, postal_code: 1 })

      belongs_to :category,
        class_name: 'Workarea::Tax::Category',
        inverse_of: :rates,
        index: true

      def valid?(*)
        super.tap do
          self.region = nil if region.blank?
          self.postal_code = nil if postal_code.blank?
          self.percentage ||= 0
        end
      end
    end
  end
end
