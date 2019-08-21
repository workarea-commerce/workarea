module Workarea
  module Storefront
    module CurrentCheckout
      extend ActiveSupport::Concern

      included do
        helper_method :current_order
        after_action :set_session_order_id
      end

      # The current order for the current session.
      #
      # @return [Order]
      #
      def current_order
        @current_order ||= Order.find_current(
          id: session[:order_id],
          user_id: cookies.signed[:user_id]
        )
      end

      # Sets the current order on the session.
      #
      def current_order=(order)
        @current_order = order
        session[:order_id] = order.try(:id)
      end

      # Removes the current order from the session.
      #
      def clear_current_order
        session.delete(:order_id)
        @current_order = nil
      end

      # Sets a temporary cookie of the order ID to represent an order that
      # was just completed in checkout. Used to show the order confirmation
      # page.
      #
      def completed_order=(order)
        cookies.signed[:completed_order] = {
          value: order.id,
          expires: Workarea.config.completed_order_timeout.from_now
        }

        @completed_order = order
      end

      # Get the last completed order based on the cookie. Used to show the
      # order confirmation page.
      #
      # @return [Order]
      #
      def completed_order
        if cookies.signed[:completed_order].present?
          @completed_order ||= Order.find(cookies.signed[:completed_order])
        end
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

      private

      def set_session_order_id
        if @current_order.present? && @current_order.persisted?
          session[:order_id] = @current_order.id
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
