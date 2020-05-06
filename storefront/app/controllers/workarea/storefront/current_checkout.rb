module Workarea
  module Storefront
    module CurrentCheckout
      extend ActiveSupport::Concern

      included do
        helper_method :current_order
        after_action :set_order_id_cookie
      end

      # The current order for the current session.
      #
      # @return [Order]
      #
      def current_order
        @current_order ||= Order.find_current(
          # TODO session[:order_id] is deprecated in v3.5, remove in v3.6
          # TODO cookies.signed[:user_id] is deprecated in v3.5, remove in v3.6

          id: cookies.signed[:order_id].presence || session[:order_id],
          user_id: session[:user_id].presence || cookies.signed[:user_id]
        )
      end

      # Sets the current order on the session.
      #
      def current_order=(order)
        @current_order = order

        if order.blank? || order.persisted?
          cookies.permanent.signed[:order_id] = order&.id
        end
      end

      # Removes the current order from the session.
      #
      def clear_current_order
        # TODO session[:order_id] is deprecated in v3.5, remove in v3.6
        session.delete(:order_id)

        cookies.delete(:order_id)
        @current_order = nil
      end

      # Sets a temporary cookie of the order ID to represent an order that
      # was just completed in checkout. Used to show the order confirmation
      # page.
      #
      def completed_order=(order)
        session[:completed_order_id] = order&.id
        @completed_order = order
      end

      # Get the last completed order based on the cookie. Used to show the
      # order confirmation page.
      #
      # @return [Order]
      #
      def completed_order
        return @completed_order if defined?(@completed_order)
        @completed_order = Order.find(session[:completed_order_id]) rescue nil
      end

      # Get the current checkout for the session.
      #
      # @return [Checkout]
      #
      def current_checkout
        @current_checkout ||= Workarea::Checkout.new(current_order, current_user)
      end

      # Get the current shipping for the session.
      #
      # @return [Shipping]
      #
      def current_shipping
        current_checkout.shipping
      end

      # Get all shippings for the session.
      #
      # @return [Array<Shipping>]
      #
      def current_shippings
        current_checkout.shippings
      end

      def logout
        super
        clear_current_order
      end

      private

      def set_order_id_cookie
        if @current_order.present? && @current_order.persisted?
          cookies.permanent.signed[:order_id] = @current_order.id
        end
      end

      def validate_checkout
        if !current_order || current_order.no_items?
          flash[:error] = t('workarea.storefront.flash_messages.items_required')
          redirect_to cart_path
          return false
        end
      end

      def check_inventory
        return true unless current_order

        reservation = InventoryAdjustment.new(current_order).tap(&:perform)

        if reservation.errors.present?
          flash[:error] = reservation.errors.to_sentence
          redirect_to cart_path and return false
        else
          return true
        end
      end
    end
  end
end
