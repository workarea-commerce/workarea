# TODO: Factor out remaining calls to this service and then remove
# Plugins call Order#cancel directly and no longer go through this service
module Workarea
  class CancelOrder
    attr_reader :order, :params

    def initialize(order, params = {})
      @order = order
      @params = params || {}
    end

    def restock?
      params[:restock].to_s =~ /true/i
    end

    def refund?
      params[:refund].to_s =~ /true/i
    end

    def update_fulfillment?
      params[:fulfillment].to_s =~ /true/i
    end

    def restock
      transaction = Inventory::Transaction.captured_for_order(order.id)
      transaction.rollback unless transaction.blank?
    end

    def refund
      result = Payment::Refund.new(payment: payment, amounts: refund_amounts)
      result.complete!
      result
    end

    def update_fulfillment
      cancellations = order.items.map do |item|
        { 'id' => item.id.to_s, 'quantity' => item.quantity }
      end

      fulfillment.cancel_items(cancellations)
    end

    def perform
      restock if restock?
      refund if refund?
      update_fulfillment if update_fulfillment?

      order.cancel
    end

    private

    def payment
      @payment ||= Payment.find_or_initialize_by(id: order.id)
    end

    def refund_amounts
      payment.tenders.reduce({}) do |memo, tender|
        memo[tender.id] = tender.captured_amount - tender.refunded_amount
        memo
      end
    end

    def fulfillment
      @fulfillment ||= Fulfillment.find_or_initialize_by(id: order.id)
    end
  end
end
