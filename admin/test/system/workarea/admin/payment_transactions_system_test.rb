require 'test_helper'

module Workarea
  module Admin
    class PaymentTransactionsSystemTest < SystemTest
      include Admin::IntegrationTest

      def test_viewing_transactions
        Workarea.config.checkout_payment_action = {
          shipping: 'authorize!',
          partial_shipping: 'authorize!',
          no_shipping: 'authorize!'
        }

        order = create_placed_order(id: 'FOO')
        payment = Payment.find(order.id)
        auth = payment.credit_card.transactions.first
        capture = payment.credit_card.build_transaction(
          action: 'capture',
          amount: auth.amount,
          reference: auth
        )
        capture.complete!

        visit admin.payment_transactions_path

        click_button 'Transaction'
        assert(page.has_content?('Authorize (1)'))
        assert(page.has_content?('Capture (1)'))
        click_button 'Transaction' # closes filter dropdown

        click_button 'Auth Status'
        assert(page.has_content?('Captured (1)'))

        visit admin.payment_transactions_path
        click_link 'Authorize', match: :first

        assert(page.has_content?('Transaction'))
        assert(page.has_content?('Credit Card'))
        assert(page.has_content?("#{Money.default_currency.symbol}11.00"))
        assert(page.has_content?('Bogus Gateway: Forced success'))
        assert(page.has_content?('Capture'))
      end
    end
  end
end
