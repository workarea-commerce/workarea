module Workarea
  class SendRefundEmail
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options(
      enqueue_on: { Payment::Refund => :complete },
      ignore_if: -> { !Workarea.config.send_transactional_emails }
    )

    def perform(id)
      refund = Payment::Refund.find(id)
      return if refund.total.zero?
      Storefront::PaymentMailer.refunded(id.to_s).deliver_now
    end
  end
end
