module Workarea
  module Catalog
    class Variant
      include ApplicationDocument
      include Releasable
      include Ordering
      include Details

      field :name, type: String, localize: true
      field :sku, type: String

      embedded_in :product,
        class_name: 'Workarea::Catalog::Product',
        inverse_of: :variants,
        touch: true

      validates :sku, presence: true, parameter: true
      validates :name, presence: true

      def valid?(*)
        self.name = sku if name.blank?
        super
      end
    end
  end
end
