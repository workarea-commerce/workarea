module Workarea
  class Payment
    class Refund
      class StoreCredit
        include OperationImplementation

        def complete!
          profile.reload_store_credit(transaction.amount.cents)
          transaction.response = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t(
              'workarea.payment.store_credit_credit',
              amount: transaction.amount,
              email: profile.email
            )
          )
        end

        def cancel!
          return unless transaction.success?

          profile.purchase_on_store_credit(transaction.amount.cents)
          transaction.cancellation = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t(
              'workarea.payment.store_credit_debit',
              amount: transaction.amount,
              email: profile.email
            )
          )
        end
      end
    end
  end
end
