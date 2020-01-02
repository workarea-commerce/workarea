module Workarea
  module Storefront
    module IntegrationTest
      def product
        @product ||= create_product(
          name: 'Integration Product',
          variants: [
            { sku: 'SKU1', tax_code: '001', regular: 5.to_m }
          ]
        )
      end

      def complete_checkout(email = nil, password = nil)
        if Shipping::Service.blank?
          create_shipping_service(
            name: 'Ground',
            tax_code: '001',
            rates: [{ price: 7.to_m }]
          )
        end

        post storefront.cart_items_path,
          headers: checkout_headers,
          params: {
            product_id: product.id,
            sku: product.skus.first,
            quantity: 2
          }

        if email.present? && password.present?
          post storefront.login_path,
            headers: checkout_headers,
            params: { email: email, password: password }
        end

        patch storefront.checkout_addresses_path,
          headers: checkout_headers,
          params: {
            email: 'bcrouse@workarea.com',
            billing_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '12 N. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            },
            shipping_address: {
              first_name:   'Ben',
              last_name:    'Crouse',
              street:       '22 S. 3rd St.',
              city:         'Philadelphia',
              region:       'PA',
              postal_code:  '19106',
              country:      'US',
              phone_number: '2159251800'
            }
          }

        patch storefront.checkout_place_order_path,
          headers: checkout_headers,
          params: {
            payment: 'new_card',
            credit_card: {
              number: '1',
              month:  1,
              year:   next_year,
              cvv:    '999'
            }
          }
      end

      private

      def checkout_headers
        { 'HTTP_USER_AGENT' => 'Mozilla' }
      end
    end
  end
end
