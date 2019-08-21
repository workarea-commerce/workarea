require 'test_helper'

module Workarea
  class Payment
    module Authorize
      class CreditCardTest < Workarea::TestCase
        def test_complete_does_nothing_if_gateway_storage_fails
          operation = Payment::Authorize::CreditCard.new(tender, transaction)

          StoreCreditCard.any_instance.stubs(:save!).returns(false)

          Workarea.config.gateways.credit_card.expects(:authorize).never

          operation.complete!
        end

        def test_complete_sets_the_response_on_the_transaction
          operation = Payment::Authorize::CreditCard.new(tender, transaction)
          operation.complete!

          assert_instance_of(
            ActiveMerchant::Billing::Response,
            transaction.response
          )
        end

        def test_complete_sets_the_transaction_attributes_on_a_failure_response
          tender.token = 2
          operation = Payment::Authorize::CreditCard.new(tender, transaction)
          operation.complete!

          refute(transaction.success?, "expected transaction.success? to be false")
          assert_instance_of(
            ActiveMerchant::Billing::Response,
            transaction.response
          )
        end

        def test_complete_sets_transaction_attributes_on_an_error_response
          tender.token = 3
          operation = Payment::Authorize::CreditCard.new(tender, transaction)
          operation.complete!

          refute(transaction.success?, "expected transaction success? to be false")
          assert_instance_of(
            ActiveMerchant::Billing::Response,
            transaction.response
          )
        end

        def test_cancel_does_nothing_if_the_transaction_was_a_failure
          tender.number = 3
          operation = Payment::Authorize::CreditCard.new(tender, transaction)

          operation.gateway.expects(:void).never
          operation.cancel!
        end

        def test_cancel_sets_cancellation_params_on_the_transaction
          transaction.response = ActiveMerchant::Billing::Response.new(
            true,
            'Message',
            {},
            { authorization: authorization }
          )

          operation = Payment::Authorize::CreditCard.new(tender, transaction)
          operation.cancel!

          assert_instance_of(
            ActiveMerchant::Billing::Response,
            transaction.cancellation
          )
        end

        private

        def payment
          @payment ||= create_payment
        end

        def authorization
          @authorization ||= ActiveMerchant::Billing::BogusGateway::AUTHORIZATION
        end

        def tender
          @tender ||=
            begin
              payment.set_address(first_name: 'Ben', last_name: 'Crouse')

              payment.build_credit_card(
                number: 1,
                month: 1,
                year: Time.current.year + 1,
                cvv: 999
              )

              payment.credit_card
            end
        end

        def transaction
          @transaction ||= tender.build_transaction(action: 'authorize', amount: 5.to_m)
        end
      end
    end
  end
end
