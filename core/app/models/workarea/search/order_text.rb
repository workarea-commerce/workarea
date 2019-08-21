module Workarea
  module Search
    class OrderText
      def initialize(order)
        @order = order
      end

      def addresses_text
        addresses.map do |address|
          [
            address.first_name,
            address.last_name,
            address.company,
            address.street,
            address.street_2,
            address.city,
            address.region,
            address.region_name,
            address.postal_code,
            address.country.name,
            address.country.alpha2,
            address.phone_number
          ]
        end.flatten.join(' ')
      end

      def payment_text
        payment.try(:credit_card).try(:issuer)
      end

      # Space-separated IDs for item-level and shipping-level discounts.
      #
      # @return [String]
      def discount_text
        (order_discounts + shipping_discounts).join(' ')
      end

      def shipping_text
        shippings
          .map(&:shipping_service)
          .map { |sm| sm.try(:name) }
          .reject(&:blank?)
      end

      def text
        [
          'order',
          @order.id,
          @order.email,
          @order.promo_codes,
          @order.token,
          @order.items.map { |i| "#{i.product_id} #{i.sku}" },
          addresses_text,
          payment_text,
          shipping_text,
          discount_text
        ].flatten.join(' ')
      end

      def payment
        @payment ||= Workarea::Payment.find_or_initialize_by(id: @order.id)
      end

      def shippings
        @shippings ||= Workarea::Shipping.where(order_id: @order.id)
      end

      def addresses
        (shippings.map(&:address) + [payment.try(:address)]).reject(&:blank?)
      end

      private

      def order_discounts
        @order
          .price_adjustments
          .map { |pa| pa.data['discount_id'] }
          .compact
          .uniq
      end

      def shipping_discounts
        shippings
         .map(&:price_adjustments)
         .flatten
         .map { |pa| pa.data['discount_id'] }
         .compact
         .uniq
      end
    end
  end
end
