module Workarea
  module Storefront
    class OrderViewModel < ApplicationViewModel
      include OrderPricing

      class PendingItem < Struct.new(:product_attributes, :sku, :quantity); end
      class CancelledItem < Struct.new(:product_attributes, :sku, :quantity); end

      alias_method :order, :model

      delegate :tenders, :credit_card, :credit_card?,
        :store_credit?, :store_credit,
        to: :payment

      delegate :issuer, :display_number, :month, :year, :amount,
        to: :credit_card, prefix: true, allow_nil: true

      delegate :saved_card_id, to: :credit_card, allow_nil: true

      def render_signup_form?
        User.find_by_email(model.email).blank?
      end

      def user
        @user ||= User.find(model.user_id) if model.user_id.present?
      end

      def billing_address
        payment.address
      end

      def shipping_address
        shipping.try(:address)
      end

      def shipping_service
        shipping.try(:shipping_service).try(:name)
      end

      def full_name
        if billing_address.present?
          "#{billing_address.last_name}, #{billing_address.first_name}"
        elsif shipping_address.present?
          "#{shipping_address.last_name}, #{shipping_address.first_name}"
        end
      end

      def items
        @items ||= model.items.by_newest.map do |item|
          Storefront::OrderItemViewModel.new(item)
        end
      end

      def shippings
        @shippings ||= Storefront::ShippingViewModel.wrap(
          Shipping.by_order(model.id).to_a,
          options.merge(order: model)
        )
      end

      def store_credit_amount
        if store_credit.present?
          store_credit.amount
        else
          0.to_m
        end
      end

      def paid_amount
        total_price - store_credit_amount
      end

      def refunds
        @refunds ||= RefundViewModel.wrap(payment.refunds, options)
      end

      def status
        if fulfillment_status_slug.in?(%w(open not_available))
          model.status.to_s.titleize
        else
          fulfillment_status
        end
      end

      def fulfillment_status
        return if fulfillment_status_slug == 'not_available'
        fulfillment_status_slug.titleize
      end

      def packages
        @packages ||= fulfillment.packages.map do |package|
          Storefront::PackageViewModel.wrap(package, order: self)
        end
      end

      def pending_items
        @pending_items ||= fulfillment.pending_items.map do |fulfillment_item|
          next unless order_item = items
            .detect { |i| i.id.to_s == fulfillment_item.order_item_id }

          FulfillmentItemViewModel.new(order_item, quantity: fulfillment_item.quantity_pending)
        end.compact
      end

      def canceled_items
        @canceled_items ||= fulfillment.canceled_items.map do |fulfillment_item|
          next unless order_item = items
            .detect { |i| i.id.to_s == fulfillment_item.order_item_id }

          FulfillmentItemViewModel.new(order_item, quantity: fulfillment_item.quantity_canceled)
        end.compact
      end

      # Returns recommendations for the order. The view model it returns behave
      # like {Enumerable}.
      #
      # @return [Workarea::Storefront::CartRecommendationsViewModel]
      #
      def recommendations
        @recommendations ||= CartRecommendationsViewModel.new(model)
      end

      private

      def payment
        @payment ||= Payment.find_or_initialize_by(id: model.id)
      end

      def shipping
        @shipping ||= Shipping.find_by_order(model.id)
      end

      def fulfillment
        @fulfillment ||= Fulfillment.find_or_initialize_by(id: model.id)
      end

      def fulfillment_status_slug
        @fulfillment_status ||= (
          options[:fulfillment_status].presence || fulfillment.status
        ).to_s
      end
    end
  end
end
