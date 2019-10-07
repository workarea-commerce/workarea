module Workarea
  module Pricing
    class Price
      include ApplicationDocument
      include Releasable
      include UnsupportedSegmentation

      field :min_quantity, type: Integer, default: 1
      field :regular, type: Money, default: 0
      field :sale, type: Money
      field :on_sale, type: Boolean, default: false

      embedded_in :sku, class_name: 'Workarea::Pricing::Sku', touch: true
      delegate :tax_code, :discountable?, to: :sku, allow_nil: true

      validates :min_quantity, numericality: { greater_than: 0 }
      before_validation :guard_regular_price

      def name
        ''
      end

      def sell
        if on_sale? && sale.present?
          sale
        else
          regular
        end
      end

      def generic?
        min_quantity == 1
      end

      # Whether this price is on sale. Defaults to the +#on_sale+ value of the
      # +Pricing::Sku+ it's embedded within.
      #
      # @return [Boolean]
      #
      def on_sale?
        super || sku&.on_sale?
      end

      private

      def guard_regular_price
        unless regular.present?
          self.regular = 0.to_m
        end
      end
    end
  end
end
