module Workarea
  module Admin
    class OrderViewModel < ApplicationViewModel
      include CommentableViewModel

      delegate :cancellations, :pending_items, to: :fulfillment

      def user
        return nil unless model.user_id.present?
        @user ||= User.where(id: model.user_id).first
      end

      def full_name
        if billing_address.present?
          "#{billing_address.first_name} #{billing_address.last_name}"
        elsif shipping_address.present?
          "#{shipping_address.first_name} #{shipping_address.last_name}"
        end
      end

      def items
        @items ||= model.items.by_newest.map { |item| OrderItemViewModel.new(item) }
      end

      def can_cancel?
        model.placed? && !canceled?
      end

      def checkout_by
        return nil unless model.checkout_by_id.present?
        @checkout_by ||= User.where(id: model.checkout_by_id).first
      end

      def timeline
        @timeline ||= OrderTimelineViewModel.wrap(self, options)
      end

      def updated_at
        options['source'].try(:[], 'updated_at').try(:to_datetime) ||
          model.updated_at
      end

      def segments
        @segments ||= Segment.in(id: model.segment_ids).to_a
      end

      #
      # Shipping
      #
      #

      def shipping_address
        shipping.try(:address)
      end

      def shipping_service
        shipping.try(:shipping_service)
      end

      def shipping
        @shipping ||=
          shippings.detect { |s| s.id.to_s == options[:shipping_id].to_s } ||
          shippings.first
      end

      def shippings
        @shippings ||= Shipping.by_order(model.id).to_a
      end

      def shipping_subtotal
        shippings.sum { |s| s.price_adjustments.first.try(:amount) || 0.to_m }
      end

      #
      # Payment
      #
      #

      def billing_address
        payment.address
      end

      def payment
        @payment ||= PaymentViewModel.wrap(
          Payment.find_or_initialize_by(id: model.id)
        )
      end

      def total_adjustments
        @total_adjustments ||= price_adjustments.reduce_by_description('order')
      end

      def payment_status
        options['source'].try(:dig, 'facets', 'payment_status').try(:to_sym)
      end

      #
      # Fulfillment
      #
      #

      def fulfillment
        @fulfillment ||= FulfillmentViewModel.wrap(
          Fulfillment.find_or_initialize_by(id: model.id),
          order: self
        )
      end

      def fulfillment_status
        options['source'].try(:dig, 'facets', 'fulfillment_status').try(:to_sym)
      end

      def packages
        fulfillment.packages
      end
    end
  end
end
