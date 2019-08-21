module Workarea
  class Payment
    class Capture
      class StoreCredit
        include OperationImplementation

        def complete!
          # noop, authorization does the capture
          transaction.response = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t('workarea.payment.store_credit_capture')
          )
        end

        def cancel!
          # noop, nothing to cancel
          transaction.response = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t('workarea.payment.store_credit_capture')
          )
        end
      end
    end
  end
end
