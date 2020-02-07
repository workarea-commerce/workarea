module Workarea
  module Storefront
    module SystemTest
      def setup_checkout_specs
        create_supporting_data
        add_product_to_cart
      end

      def create_supporting_data
        create_tax_category(
          name: 'Sales Tax',
          code: '001',
          rates: [{ percentage: 0.07, country: 'US', region: 'PA' }]
        )

        create_shipping_service(
          name: 'Ground',
          tax_code: '001',
          rates: [{ price: 7.to_m }]
        )

        create_inventory(id: 'SKU', policy: 'standard', available: 5)

        @product = create_product(
          id: 'INT_PRODUCT',
          name: 'Integration Product',
          variants: [{ sku: 'SKU',  tax_code: '001', regular: 5.to_m }]
        )

        create_user(email: 'bcrouse@workarea.com', password: 'W3bl1nc!')
      end

      def add_user_data
        user = User.find_by_email('bcrouse@workarea.com')

        user.auto_save_shipping_address(
          first_name: 'Ben',
          last_name: 'Crouse',
          street: '22 S. 3rd St.',
          city: 'Philadelphia',
          region: 'PA',
          postal_code: '19106',
          country: 'US',
          phone_number: '2159251800'
        )

        user.auto_save_billing_address(
          first_name: 'Ben',
          last_name: 'Crouse',
          street: '1019 S. 47th St.',
          city: 'Philadelphia',
          region: 'PA',
          postal_code: '19143',
          country: 'US',
          phone_number: '2159251800'
        )

        profile = Payment::Profile.lookup(PaymentReference.new(user))
        profile.credit_cards.create!(
          first_name: 'Ben',
          last_name: 'Crouse',
          number: '1',
          month: 1,
          year: Time.current.year + 1,
          cvv: '999'
        )
      end

      def add_product_to_cart
        product = Catalog::Product.find('INT_PRODUCT')
        visit storefront.product_path(product)
        click_button t('workarea.storefront.products.add_to_cart')
      end

      def start_guest_checkout
        visit storefront.checkout_path
      end

      def start_user_checkout
        visit storefront.checkout_path
        click_link t('workarea.storefront.checkouts.login_title')

        within '#login_form' do
          fill_in 'email', with: 'bcrouse@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'
          click_button t('workarea.storefront.users.login')
        end
      end

      def fill_in_email
        fill_in 'email', with: 'bcrouse-new-account@workarea.com'
      end

      def fill_in_shipping_address
        fill_in 'shipping_address[first_name]',   with: 'Ben'
        fill_in 'shipping_address[last_name]',    with: 'Crouse'
        fill_in 'shipping_address[street]',       with: '22 S. 3rd St.'
        fill_in 'shipping_address[city]',         with: 'Philadelphia'

        if page.has_field?('shipping_address[region]')
          fill_in 'shipping_address[region]', with: 'PA'
        else
          select 'Pennsylvania', from: 'shipping_address_region_select'
        end

        fill_in 'shipping_address[postal_code]',  with: '19106'
        fill_in 'shipping_address[phone_number]', with: '2159251800'
      end

      def fill_in_new_card_cvv
        fill_in 'cvv[new_card]', with: '999'
      end

      def fill_in_credit_card
        fill_in 'credit_card[number]', with: '1'
        next_year = (Time.current.year + 1).to_s
        select next_year, from: 'credit_card[year]'
        fill_in 'credit_card[cvv]', with: '999'
      end

      def fill_in_billing_address
        fill_in 'billing_address[first_name]',   with: 'Ben'
        fill_in 'billing_address[last_name]',    with: 'Crouse'
        fill_in 'billing_address[street]',       with: '1019 S. 47th St.'
        fill_in 'billing_address[city]',         with: 'Philadelphia'

        if page.has_field?('billing_address[region]')
          fill_in 'billing_address[region]', with: 'PA'
        else
          select 'Pennsylvania', from: 'billing_address_region_select'
        end

        fill_in 'billing_address[postal_code]',  with: '19143'
        fill_in 'billing_address[phone_number]', with: '2159251800'
      end

      def select_shipping_service
        choose 'Ground'
      end

      def disable_analytics_dom_events
        page.execute_script('WORKAREA.analytics.disableDomEvents();')
      end

      def find_analytics_events(for_event: nil)
        all_events = page.evaluate_script('WORKAREA.analytics.events')

        if for_event.blank?
          all_events
        else
          all_events.select { |e| e['name'] == for_event }
        end
      end
    end
  end
end
