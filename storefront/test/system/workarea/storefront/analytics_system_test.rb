require 'test_helper'

module Workarea
  module Storefront
    class AnalyticsSystemTest < Workarea::SystemTest
      include Storefront::SystemTest

      setup :set_products
      setup :set_category
      setup :set_search_settings

      def set_products
        @products = [
          create_product(
            id: 'PROD1',
            name: 'Test Product 1',
            variants: [{ sku: 'SKU1', regular: 10.to_m }],
            filters: { 'Size' => 'Medium', 'Color' => 'Blue' }
          ),
          create_product(
            id: 'PROD2',
            name: 'Test Product 2',
            variants: [{ sku: 'SKU2', regular: 12.to_m }],
            filters: {
              'Size' => ['Medium', 'Small'],
              'Color' => ['Blue', 'Green']
            }
          )
        ]
      end

      def set_category
        @category = create_category(
          name: 'Test Category',
          product_ids: [@products.second.id, @products.first.id]
        )
      end

      def set_search_settings
        update_search_settings
      end

      def test_announcing_category_view_event
        visit storefront.category_path(@category)

        click_link 'Green (1)'
        click_link 'Medium (1)'

        events = find_analytics_events(for_event: 'categoryView')

        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal('Test Category', payload['name'])
        assert_equal('featured', payload['sort'])
        assert_equal(1, payload['page'])
        assert_equal(['Green'], payload['filters']['color'])
        assert_equal(['Medium'], payload['filters']['size'])
        assert_page_view

        wait_for_xhr
        insights = Metrics::CategoryByDay.first
        assert_equal(@category.id.to_s, insights.category_id)
        assert_equal(1, insights.views)
      end

      def test_announcing_search_results_view_event
        visit storefront.search_path(q: 'test')

        events = find_analytics_events(for_event: 'searchResultsView')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal('test', payload['terms'])
        assert_equal('relevance', payload['sort'])
        assert_equal(1, payload['page'])
        assert_equal({}, payload['filters'])
        assert_equal(2, payload['totalResults'])
        assert_page_view

        click_link 'Green (1)'

        events = find_analytics_events(for_event: 'searchResultsView')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal(['Green'], payload['filters']['color'])
        assert_equal(1, payload['totalResults'])
        assert_page_view
      end

      def test_announcing_product_view_event
        visit storefront.product_path(@products.first)

        events = find_analytics_events(for_event: 'productView')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal('PROD1', payload['id'])
        assert_equal('Test Product 1', payload['name'])
        assert_equal(false, payload['sale'])
        assert_equal(10, payload['price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal('Test Category', payload['category'])
        assert_page_view

        wait_for_xhr
        insights = Metrics::ProductByDay.first
        assert_equal('PROD1', insights.product_id)
        assert_equal(1, insights.views)
      end

      def test_announcing_product_list_event
        visit storefront.category_path(@category)

        events = find_analytics_events(for_event: 'productList')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal('productList', payload['event'])
        assert_equal('Test Category', payload['name'])
        assert_equal(1, payload['page'])
        assert_equal(20, payload['per_page'])
        assert_equal(2, payload['impressions'].count)

        first_impression = payload['impressions'].first
        assert_equal('PROD2', first_impression['id'])
        assert_equal('Test Product 2', first_impression['name'])
        assert_equal(false, first_impression['sale'])
        assert_equal(12, first_impression['price'])
        assert_equal(current_currency, first_impression['currency'])
        assert_equal('Test Category', first_impression['category'])
        assert_equal(0, first_impression['position'])

        second_impression = payload['impressions'].second
        assert_equal('PROD1', second_impression['id'])
        assert_equal('Test Product 1', second_impression['name'])
        assert_equal(false, second_impression['sale'])
        assert_equal(10, second_impression['price'])
        assert_equal(current_currency, second_impression['currency'])
        assert_equal('Test Category', second_impression['category'])
        assert_equal(1, second_impression['position'])

        assert_page_view
      end

      def test_announcing_product_click_event
        visit storefront.category_path(@category)

        disable_analytics_dom_events
        within '.product-summary__name', match: :first do
          click_link 'Test Product 2'
        end

        events = find_analytics_events(for_event: 'productClick')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal('PROD2', payload['id'])
        assert_equal('Test Product 2', payload['name'])
        assert_equal(false, payload['sale'])
        assert_equal(12, payload['price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal('Test Category', payload['category'])
        assert_equal('Test Category', payload['list'])
        assert_equal(0, payload['position'])
        assert_page_view
      end

      def test_announcing_add_to_cart_event
        visit storefront.product_path(@products.second)

        fill_in 'quantity', with: '3'
        click_button t('workarea.storefront.products.add_to_cart')

        events = find_analytics_events(for_event: 'addToCart')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal('PROD2', payload['id'])
        assert_equal('Test Product 2', payload['name'])
        assert_equal(false, payload['sale'])
        assert_equal(12, payload['price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal('Test Category', payload['category'])
        assert_equal('3', payload['quantity'])
        assert_page_view
      end

      def test_announcing_update_cart_item_event
        visit storefront.product_path(@products.first)

        fill_in 'quantity', with: '3'
        click_button t('workarea.storefront.products.add_to_cart')
        assert(page.has_content?('Success'))

        visit storefront.cart_path

        disable_analytics_dom_events
        fill_in 'quantity', with: '1'

        events = find_analytics_events(for_event: 'updateCartItem')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert(payload['id'].present?)
        assert_equal('PROD1', payload['product_id'])
        assert_equal('Test Product 1', payload['product_name'])
        assert_equal('SKU1', payload['sku'])
        assert_equal({}, payload['options'])
        assert_equal(10, payload['price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal(3, payload['quantity'])
        assert_equal('Test Category', payload['category'])
        assert_equal(3, payload['from'])
        assert_equal('1', payload['to'])
        assert_page_view
      end

      def test_announcing_remove_from_cart_event
        visit storefront.product_path(@products.second)

        click_button t('workarea.storefront.products.add_to_cart')
        click_link t('workarea.storefront.carts.view_cart')

        disable_analytics_dom_events
        click_button t('workarea.storefront.carts.remove')

        events = find_analytics_events(for_event: 'removeFromCart')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert(payload['id'].present?)
        assert_equal('PROD2', payload['product_id'])
        assert_equal('Test Product 2', payload['product_name'])
        assert_equal('SKU2', payload['sku'])
        assert_equal({}, payload['options'])
        assert_equal(12, payload['price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal(1, payload['quantity'])
        assert_equal('Test Category', payload['category'])
        assert_page_view
      end

      def test_announcing_add_to_cart_confirmation_event
        visit storefront.product_path(@products.first)
        click_button t('workarea.storefront.products.add_to_cart')

        events = find_analytics_events(for_event: 'addToCartConfirmation')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert(payload['id'].present?)
        assert_equal('PROD1', payload['product_id'])
        assert_equal('Test Product 1', payload['product_name'])
        assert_equal('SKU1', payload['sku'])
        assert_equal({}, payload['options'])
        assert_equal(10, payload['price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal(1, payload['quantity'])
        assert_equal('Test Category', payload['category'])
        assert_page_view
      end

      def test_announcing_cart_view_event
        visit storefront.product_path(@products.first)
        fill_in 'quantity', with: '2'
        click_button t('workarea.storefront.products.add_to_cart')

        visit storefront.product_path(@products.second)
        fill_in 'quantity', with: '3'
        click_button t('workarea.storefront.products.add_to_cart')

        visit storefront.cart_path

        events = find_analytics_events(for_event: 'cartView')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal(Workarea.config.site_name, payload['site_name'])
        assert(payload['id'].present?)
        assert_equal([], payload['promo_codes'])
        assert_nil(payload['shipping_service'])
        assert_equal(0, payload['shipping_total'])
        assert_equal(0, payload['tax_total'])
        assert_equal(56, payload['total_price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal([], payload['tenders'])
        assert_equal(2, payload['items'].count)

        first_item = payload['items'].first
        assert(first_item['id'].present?)
        assert_equal('PROD2', first_item['product_id'])
        assert_equal('Test Product 2', first_item['product_name'])
        assert_equal('SKU2', first_item['sku'])
        assert_equal({}, first_item['options'])
        assert_equal(12, first_item['price'])
        assert_equal(current_currency, first_item['currency'])
        assert_equal(3, first_item['quantity'])
        assert_equal('Test Category', first_item['category'])

        second_item = payload['items'].second
        assert(second_item['id'].present?)
        assert_equal('PROD1', second_item['product_id'])
        assert_equal('Test Product 1', second_item['product_name'])
        assert_equal('SKU1', second_item['sku'])
        assert_equal({}, second_item['options'])
        assert_equal(10, second_item['price'])
        assert_equal(current_currency, second_item['currency'])
        assert_equal(2, second_item['quantity'])
        assert_equal('Test Category', second_item['category'])

        assert_page_view
      end

      def test_announcing_checkout_addresses_view_event
        setup_checkout_specs
        add_user_data
        start_user_checkout

        visit storefront.checkout_addresses_path

        events = find_analytics_events(for_event: 'checkoutAddressesView')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal(Workarea.config.site_name, payload['site_name'])
        assert(payload['id'].present?)
        assert_equal([], payload['promo_codes'])
        assert_equal('Ground', payload['shipping_service'])
        assert_equal(7, payload['shipping_total'])
        assert_equal(0.84, payload['tax_total'])
        assert_equal(12.84, payload['total_price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal([], payload['tenders'])
        assert_equal(1, payload['items'].count)

        order_item = payload['items'].first
        assert(order_item['id'].present?)
        assert_equal('INT_PRODUCT', order_item['product_id'])
        assert_equal('Integration Product', order_item['product_name'])
        assert_equal('SKU', order_item['sku'])
        assert_equal({}, order_item['options'])
        assert_equal(5, order_item['price'])
        assert_equal(current_currency, order_item['currency'])
        assert_equal(1, order_item['quantity'])
        assert_nil(order_item['category'])

        assert_page_view
      end

      def test_announcing_checkout_shipping_view_event
        setup_checkout_specs
        add_user_data
        start_user_checkout

        visit storefront.checkout_shipping_path

        events = find_analytics_events(for_event: 'checkoutShippingView')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal(Workarea.config.site_name, payload['site_name'])
        assert(payload['id'].present?)
        assert_equal([], payload['promo_codes'])
        assert_equal('Ground', payload['shipping_service'])
        assert_equal(7, payload['shipping_total'])
        assert_equal(0.84, payload['tax_total'])
        assert_equal(12.84, payload['total_price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal([], payload['tenders'])
        assert_equal(1, payload['items'].count)

        order_item = payload['items'].first
        assert(order_item['id'].present?)
        assert_equal('INT_PRODUCT', order_item['product_id'])
        assert_equal('Integration Product', order_item['product_name'])
        assert_equal('SKU', order_item['sku'])
        assert_equal({}, order_item['options'])
        assert_equal(5, order_item['price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal(1, order_item['quantity'])
        assert_nil(order_item['category'])

        assert_page_view
      end

      def test_announcing_checkout_shipping_service_selected_event
        setup_checkout_specs
        add_user_data
        start_user_checkout

        create_shipping_service(
          name: 'Overnight',
          tax_code: '001',
          rates: [{ price: 20.to_m }]
        )

        visit storefront.checkout_shipping_path

        choose "shipping_service_Overnight"

        events = find_analytics_events(for_event: 'checkoutShippingServiceSelected')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal('Overnight', payload['name'])
        assert_equal(20, payload['price'])
        assert_equal(current_currency, payload['currency'])

        assert_page_view
      end

      def test_announcing_checkout_payment_view_event
        setup_checkout_specs
        add_user_data
        start_user_checkout

        visit storefront.checkout_payment_path

        events = find_analytics_events(for_event: 'checkoutPaymentView')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal(Workarea.config.site_name, payload['site_name'])
        assert(payload['id'].present?)
        assert_equal([], payload['promo_codes'])
        assert_equal('Ground', payload['shipping_service'])
        assert_equal(7, payload['shipping_total'])
        assert_equal(0.84, payload['tax_total'])
        assert_equal(12.84, payload['total_price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal([], payload['tenders'])
        assert_equal(1, payload['items'].count)

        order_item = payload['items'].first
        assert(order_item['id'].present?)
        assert_equal('INT_PRODUCT', order_item['product_id'])
        assert_equal('Integration Product', order_item['product_name'])
        assert_equal('SKU', order_item['sku'])
        assert_equal({}, order_item['options'])
        assert_equal(5, order_item['price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal(1, order_item['quantity'])
        assert_nil(order_item['category'])

        assert_page_view
      end

      def test_announcing_checkout_order_placed_event
        setup_checkout_specs
        add_user_data
        start_user_checkout

        click_button t('workarea.storefront.checkouts.place_order')

        events = find_analytics_events(for_event: 'checkoutOrderPlaced')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal(Workarea.config.site_name, payload['site_name'])
        assert(payload['id'].present?)
        assert_equal([], payload['promo_codes'])
        assert_equal('Ground', payload['shipping_service'])
        assert_equal(7, payload['shipping_total'])
        assert_equal(0.84, payload['tax_total'])
        assert_equal(12.84, payload['total_price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal(['credit_card'], payload['tenders'])
        assert_equal(1, payload['items'].count)

        order_item = payload['items'].first
        assert(order_item['id'].present?)
        assert_equal('INT_PRODUCT', order_item['product_id'])
        assert_equal('Integration Product', order_item['product_name'])
        assert_equal('SKU', order_item['sku'])
        assert_equal({}, order_item['options'])
        assert_equal(5, order_item['price'])
        assert_equal(current_currency, payload['currency'])
        assert_equal(1, order_item['quantity'])
        assert_nil(order_item['category'])

        assert_page_view
      end

      def test_announcing_email_signup_event
        visit storefront.root_path

        fill_in 'footer_email_signup_field', with: 'foo@bar.com'

        disable_analytics_dom_events
        click_button t('workarea.storefront.users.join')

        events = find_analytics_events(for_event: 'emailSignup')
        assert_equal(1, events.count)

        assert_page_view
      end

      def test_announcing_checkout_login_event
        setup_checkout_specs
        add_user_data

        visit storefront.checkout_path

        disable_analytics_dom_events
        click_link t('workarea.storefront.users.login')

        events = find_analytics_events(for_event: 'checkoutLogin')
        assert_equal(1, events.count)
        assert_page_view
      end

      def test_announcing_checkout_signup_event
        setup_checkout_specs
        add_user_data
        start_guest_checkout

        fill_in_email
        fill_in_shipping_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        click_button t('workarea.storefront.checkouts.continue_to_payment')

        fill_in_credit_card
        click_button t('workarea.storefront.checkouts.place_order')

        fill_in 'password', with: 'W3bl1nc!'

        disable_analytics_dom_events
        click_button t('workarea.storefront.users.create_account')

        events = find_analytics_events(for_event: 'checkoutSignup')
        assert_equal(1, events.count)

        assert_page_view
      end

      def test_announcing_login_event
        visit storefront.login_path

        assert_page_view
        within '#login_form' do
          fill_in 'email', with: 'bcrouse@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'

          disable_analytics_dom_events
          click_button t('workarea.storefront.users.login')
        end

        events = find_analytics_events(for_event: 'login')
        assert_equal(1, events.count)

        assert_page_view
      end

      def test_announcing_forgot_password_event
        visit storefront.forgot_password_path

        within '#forgot_password_form' do
          fill_in 'email', with: 'bcrouse@workarea.com'

          disable_analytics_dom_events
          click_button t('workarea.storefront.forms.send')
        end

        events = find_analytics_events(for_event: 'forgotPassword')
        assert_equal(1, events.count)

        assert_page_view
      end

      def test_announcing_signup_event
        visit storefront.login_path

        within '#signup_form' do
          fill_in 'email', with: 'bcrouse@workarea.com'
          fill_in 'password', with: 'W3bl1nc!'

          disable_analytics_dom_events
          click_button t('workarea.storefront.users.create_account')
        end

        events = find_analytics_events(for_event: 'signup')
        assert_equal(1, events.count)

        assert_page_view
      end

      def test_announcing_primary_navigation_click_event
        taxon = create_taxon(name: 'First Level', url: '/first/level')
        create_menu(taxon: taxon)

        visit storefront.root_path

        disable_analytics_dom_events
        click_link 'First Level'

        events = find_analytics_events(for_event: 'primaryNavigationClick')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal('First Level', payload['name'])
        assert_equal('/first/level', payload['url'])
      end

      def test_announcing_checkout_edit_event
        setup_checkout_specs
        add_user_data
        start_guest_checkout

        fill_in_email
        fill_in_shipping_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        disable_analytics_dom_events
        click_link t('workarea.storefront.forms.edit')

        events = find_analytics_events(for_event: 'checkoutEdit')
        assert_equal(1, events.count)
        payload = events.first['arguments'].first
        assert_equal('addresses', payload['type'])
      end

      def test_announcing_validation_errors
        setup_checkout_specs
        add_user_data
        start_guest_checkout

        fill_in_email
        fill_in_shipping_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        click_button t('workarea.storefront.checkouts.continue_to_payment')

        fill_in_credit_card
        fill_in 'credit_card[number]', with: '2'
        click_button t('workarea.storefront.checkouts.place_order')

        assert_current_path(storefront.checkout_place_order_path)
        validation_events = find_analytics_events(for_event: 'validationError')
        assert_equal(1, validation_events.count)
        payload = validation_events.first['arguments'].first
        assert_equal('payment', payload['model'])
      end

      def test_announcing_flash_messages
        setup_checkout_specs
        add_user_data
        start_guest_checkout

        fill_in_email
        fill_in_shipping_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')

        flash_events = find_analytics_events(for_event: 'flashMessage')
        assert_equal(1, flash_events.count)
        payload = flash_events.first['arguments'].first
        assert_equal('success', payload['type'])
      end

      def test_search_search_tracking
        visit storefront.search_path(q: 'test')
        insights = Metrics::SearchByDay.first

        assert_equal('test', insights.query_id)
        assert_equal(1, insights.searches)
        assert_equal(2, insights.total_results)
        click_link 'Test Product 1', match: :first

        visit storefront.search_path(q: 'test')
        assert_equal(2, insights.reload.searches)
        assert_equal(2, insights.total_results)
      end

      def test_filter_tracking
        # deprecated
      end

      def test_announcing_content_block_view
        create_content(
          name: 'home_page',
          blocks: [
            {
              type_id: 'html',
              data: { html: 'Home Page Content Block' }
            }
          ]
        )

        visit storefront.root_path
        assert(page.has_content?('Home Page Content Block'))

        events = find_analytics_events(for_event: 'contentBlockDisplay')

        assert_equal(1, events.count)
        payload = events.first['arguments'].first

        assert_equal('html', payload['type'])
        assert_equal(0, payload['position'])
        assert_equal('Home Page Content Block', payload['data']['html'])
      end

      def test_sessions
        create_life_cycle_segments

        visit storefront.root_path
        assert_equal(1, find_analytics_events(for_event: 'newSession').size)
        assert_equal(1, Metrics::SalesByDay.today.sessions)
        assert_equal(1, Metrics::SegmentByDay.find_by(segment_id: 'first_time_visitor').sessions)

        visit storefront.category_path(@category)
        assert_equal(0, find_analytics_events(for_event: 'newSession').size)
        assert_equal(1, Metrics::SalesByDay.today.sessions)
        assert_equal(1, Metrics::SegmentByDay.find_by(segment_id: 'first_time_visitor').sessions)

        expire_analytics_session
        visit storefront.root_path
        assert_equal(1, find_analytics_events(for_event: 'newSession').size)
        assert_equal(2, Metrics::SalesByDay.today.sessions)
        assert_equal(1, Metrics::SegmentByDay.find_by(segment_id: 'first_time_visitor').sessions)
        assert_equal(1, Metrics::SegmentByDay.find_by(segment_id: 'returning_visitor').sessions)

        setup_checkout_specs
        add_user_data
        start_guest_checkout

        fill_in_email
        fill_in_shipping_address
        click_button t('workarea.storefront.checkouts.continue_to_shipping')
        click_button t('workarea.storefront.checkouts.continue_to_payment')

        fill_in_credit_card
        click_button t('workarea.storefront.checkouts.place_order')
        assert_current_path(storefront.checkout_confirmation_path)

        expire_analytics_session
        visit storefront.root_path
        assert_equal(1, find_analytics_events(for_event: 'newSession').size)
        assert_equal(3, Metrics::SalesByDay.today.sessions)
        assert_equal(1, Metrics::SegmentByDay.find_by(segment_id: 'first_time_visitor').sessions)
        assert_equal(1, Metrics::SegmentByDay.find_by(segment_id: 'returning_visitor').sessions)
        assert_equal(1, Metrics::SegmentByDay.find_by(segment_id: 'first_time_customer').sessions)
      end

      private

      def assert_page_view
        page_view = find_analytics_events(for_event: 'pageView')
        assert_equal(1, page_view.count)
      end

      def expire_analytics_session
        # Simulate session expiration where this cookie would disappear
        page.execute_script("WORKAREA.cookie.destroy('analytics_session');")
      end

      def current_currency
        Money.default_currency.id.to_s.upcase
      end
    end
  end
end
