module Workarea
  module Storefront
    module AnalyticsHelper
      def category_view_analytics_data(category)
        {
          event: 'categoryView',
          payload: {
            id: category.id.to_s,
            name: category.name,
            sort: category.sort,
            page: category.page,
            filters: category.filters
          }
        }
      end

      def search_results_view_analytics_data(search)
        {
          event: 'searchResultsView',
          payload: {
            terms: search.query_string,
            sort: search.sort.slug,
            page: search.page,
            filters: search.respond_to?(:filters) ? search.filters : {},
            totalResults: search.total
          }
        }
      end

      def product_view_analytics_data(product)
        {
          event: 'productView',
          payload: product_analytics_data(product)
        }
      end

      def product_list_analytics_data(name = nil)
        page = params[:page].presence || 1

        {
          event: 'productList',
          name: name,
          page: page.to_i,
          per_page: Workarea.config.per_page
        }
      end

      def product_click_analytics_data(product)
        {
          event: 'productClick',
          domEvent: 'click',
          payload: product_analytics_data(product)
        }
      end

      def add_to_cart_analytics_data(product)
        {
          event: 'addToCart',
          domEvent: 'submit',
          payload: product_analytics_data(product)
        }
      end

      def update_cart_item_analytics_data(item)
        {
          event: 'updateCartItem',
          domEvent: 'submit',
          payload: order_item_analytics_data(item)
        }
      end

      def remove_from_cart_analytics_data(item)
        {
          event: 'removeFromCart',
          domEvent: 'submit',
          payload: order_item_analytics_data(item)
        }
      end

      def add_to_cart_confirmation_analytics_data(item)
        {
          event: 'addToCartConfirmation',
          payload: order_item_analytics_data(item)
        }
      end

      def cart_view_analytics_data(order)
        { event: 'cartView', payload: order_analytics_data(order) }
      end

      def checkout_addresses_view_analytics_data(order)
        {
          event: 'checkoutAddressesView',
          payload: order_analytics_data(order)
        }
      end

      def checkout_shipping_view_analytics_data(order)
        {
          event: 'checkoutShippingView',
          payload: order_analytics_data(order)
        }
      end

      def checkout_shipping_service_selected_analytics_data(option)
        {
          event: 'checkoutShippingServiceSelected',
          domEvent: 'change',
          payload: {
            name: option.name,
            price: option.price.to_f,
            currency: option.price.currency.id.upcase
          }
        }
      end

      def checkout_payment_view_analytics_data(order)
        {
          event: 'checkoutPaymentView',
          payload: order_analytics_data(order)
        }
      end

      def checkout_payment_selected_analytics_data(option)
        {
          event: 'checkoutPaymentSelected',
          domEvent: 'click',
          payload: { type: option }
        }
      end

      def checkout_order_placed_analytics_data(order)
        {
          event: 'checkoutOrderPlaced',
          payload: order_analytics_data(order)
        }
      end

      def email_signup_analytics_data
        { event: 'emailSignup', domEvent: 'submit' }
      end

      def checkout_login_analytics_data
        { event: 'checkoutLogin', domEvent: 'click' }
      end

      def checkout_signup_analytics_data
        { event: 'checkoutSignup', domEvent: 'submit' }
      end

      def checkout_edit_analytics_data(type)
        { event: 'checkoutEdit', domEvent: 'click', payload: { type: type } }
      end

      def validation_error_analytics_data(model)
        { event: 'validationError', payload: { model: model } }
      end

      def login_analytics_data
        { event: 'login', domEvent: 'submit' }
      end

      def forgot_password_analytics_data
        { event: 'forgotPassword', domEvent: 'submit' }
      end

      def signup_analytics_data
        { event: 'signup', domEvent: 'submit' }
      end

      def order_analytics_data(order)
        {
          site_name: Workarea.config.site_name,
          id: order.id,
          promo_codes: order.promo_codes.sort,
          shipping_service: order.shipping_service,
          shipping_total: order.shipping_total.to_f,
          tax_total: order.tax_total.to_f,
          discount_total: order.discount_total.to_f,
          total_price: order.total_price.to_f,
          currency: order.total_price.currency.id.upcase,
          tenders: order.respond_to?(:tenders) ? order.tenders.map(&:slug) : [],
          items: order.items.map { |i| order_item_analytics_data(i) }
        }
      end

      def order_item_analytics_data(item)
        {
          id: item.id.to_s,
          product_id: item.product_id,
          product_name: item.product_name,
          sku: item.sku,
          options: item.details,
          price: item.current_unit_price.to_f,
          currency: item.current_unit_price.currency.id.upcase,
          quantity: item.quantity,
          category: item.default_category_name
        }
      end

      def product_analytics_data(product)
        {
          id: product.id,
          name: product.name,
          sku: product.current_sku,
          sale: product.on_sale?,
          price: product.sell_min_price&.to_f,
          currency: product.sell_min_price&.currency&.id&.upcase,
          category: product.default_category.try(:name)
        }
      end
      alias_method :product_impression_data, :product_analytics_data

      def primary_navigation_analytics_data(taxon)
        {
          event: 'primaryNavigationClick',
          domEvent: 'click',
          payload: {
            name: taxon.name,
            url: storefront_path_for(taxon)
          }
        }
      end

      def content_block_analytics_data(block)
        {
          event: 'contentBlockDisplay',
          payload: {
            id: block.id.to_s,
            type: block.type_id,
            position: block.position,
            data: block.data
          }
        }
      end
    end
  end
end
