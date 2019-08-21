module Workarea
  class CopyOrder
    attr_reader :order, :params

    def initialize(order, params = {})
      @order = order
      @params = params || {}
    end

    def payment
      @payment ||= Payment.find(order.id) rescue nil
    end

    def shippings
      @shippings ||= Shipping.where(order_id: order.id).to_a
    end

    def new_order
      @new_order ||= order.dup
    end

    def new_payment
      @new_payment ||= payment.try(:dup)
    end

    def new_shippings
      @new_shippings ||= shippings.map(&:dup)
    end

    def perform
      save_new_order
      save_new_payment if new_payment.present?
      save_new_shippings if new_shippings.present?
      cancel_original if cancel_original?
    end

    def anonymize!
      new_order.update!(user_id: nil, email: nil)
      new_payment.destroy!
      new_shippings.each(&:destroy!)
    end

    def save_new_order
      Workarea.config.copy_order_ignored_fields.each do |field|
        new_order.send("#{field}=", nil)
      end
      new_order.copied_from = order
      new_order.save!
    end

    def save_new_payment
      new_payment.id = new_order.id
      new_payment.save!
    end

    def save_new_shippings
      new_shippings
        .each { |s| s.order_id = new_order.id }
        .each(&:save!)
    end

    def cancel_original?
      params[:cancel_original].to_s =~ /true/
    end

    def cancel_original
      return if order.canceled? || !order.placed?

      cancel = CancelOrder.new(
        order,
        restock: true,
        refund: true,
        fulfillment: true
      )

      cancel.perform
    end
  end
end
