module Workarea
  class Payment
    module Authorize
      class StoreCredit
        include OperationImplementation

        def complete!
          profile.purchase_on_store_credit(transaction.amount.cents)

          transaction.action = 'purchase'
          transaction.response = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t(
              'workarea.payment.store_credit_debit',
              amount: transaction.amount,
              email: profile.email
            )
          )

        rescue Workarea::Payment::InsufficientFunds
          transaction.response = ActiveMerchant::Billing::Response.new(
            false,
            I18n.t('workarea.payment.store_credit_insufficient_funds')
          )
        end

        def cancel!
          return unless transaction.success?

          profile.reload_store_credit(transaction.amount.cents)
          transaction.cancellation = ActiveMerchant::Billing::Response.new(
            true,
            I18n.t(
              'workarea.payment.store_credit_credit',
              amount: transaction.amount,
              email: profile.email
            )
          )
        end
      end
    end
  end
end
