require 'test_helper'

module Workarea
  class Payment
    class Refund
      class CreditCardTest < Workarea::TestCase
        def test_complete_raises_if_the_reference_transaction_is_blank
          transaction.reference = nil
          operation = Payment::Refund::CreditCard.new(payment.credit_card, transaction)

          assert_raises(Payment::MissingReference) { operation.complete! }
        end

        def test_complete_sets_the_response_on_the_transaction
          operation = Payment::Refund::CreditCard.new(payment.credit_card, transaction)
          operation.complete!

          assert_instance_of(
            ActiveMerchant::Billing::Response,
            transaction.response
          )
        end

        private

        def authorization
          @authorization ||= ActiveMerchant::Billing::BogusGateway::AUTHORIZATION
        end

        def payment
          @payment ||=
            begin
              result = create_payment
              result.set_credit_card(
                number: 1,
                month: 1,
                year: Time.current.year + 1,
                cvv: 999
              )

              result
            end
        end

        def reference
          @reference ||= Transaction.new(
            amount: 5.to_m,
            response: ActiveMerchant::Billing::Response.new(
              true,
              'Message',
              {},
              { authorization: authorization }
            )
          )
        end

        def transaction
          @transaction ||= payment.credit_card.build_transaction(
            amount: 5.to_m,
            reference: reference
          )
        end
      end
    end
  end
end
