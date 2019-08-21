module Workarea
  class SaveUserOrderDetails
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options enqueue_on: { Order => :place }, queue: 'high'

    def perform(order_id)
      order = Order.find(order_id)
      return if order.user_id.blank?
      user = User.find(order.user_id)
      return unless user.email == order.email

      save_payment_details(order, user)
      save_shipping_details(order, user)
    end

    def save_payment_details(order, user)
      payment = Payment.find_or_initialize_by(id: order.id)
      payment_profile = Payment::Profile.lookup(PaymentReference.new(user))
      billing_address = extract_address_attributes(payment.address)

      if billing_address.present?
        user.auto_save_billing_address(billing_address)

        if user.public_info.blank?
          user.update_attributes!(
            first_name: billing_address[:first_name],
            last_name: billing_address[:last_name]
          )
        end
      end

      if payment.credit_card? && !payment.credit_card.saved?
        payment_profile.credit_cards.create(
          first_name: payment.credit_card.first_name,
          last_name: payment.credit_card.last_name,
          display_number: payment.credit_card.display_number,
          issuer: payment.credit_card.issuer,
          month: payment.credit_card.month,
          year: payment.credit_card.year,
          token: payment.credit_card.token,
          default: payment_profile.credit_cards.none?
        )
      end
    end

    def save_shipping_details(order, user)
      return unless order.requires_shipping?

      shippings = Shipping.where(order_id: order.id).to_a
      addresses = shippings.map do |shipping|
        extract_address_attributes(shipping.address)
      end

      addresses.each do |shipping_address|
        user.auto_save_shipping_address(shipping_address)
      end
    end

    private

    def extract_address_attributes(address)
      return {} if address.blank?

      Workarea.config.address_attributes.inject({}) do |memo, attr|
        memo[attr] = address.send(attr)
        memo
      end
    end
  end
end
