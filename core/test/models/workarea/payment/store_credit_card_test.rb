require 'test_helper'

module Workarea
  class Payment
    class StoreCreditCardTest < Workarea::TestCase
      setup :credit_card

      def test_perform_does_nothing_if_credit_card_already_has_a_token
        credit_card_gateway.expects(:store).never

        StoreCreditCard.new(credit_card).perform!
      end

      def test_perform_sets_the_token_on_the_credit_card
        credit_card.token = nil
        StoreCreditCard.new(credit_card).perform!
        assert(credit_card.token.present?, 'expected credit card token to be present')
      end

      private

      def invalid_credit_card
        @invalid_credit_card ||= create_saved_credit_card.tap do |credit_card|
          credit_card.number = '4111111111111112'
          credit_card.token = nil
        end
      end

      def stored_failure_message
        "Bogus Gateway: Forced failure"
      end

      def credit_card
        @credit_card ||= create_saved_credit_card
      end

      def credit_card_gateway
        Workarea.config.gateways.credit_card
      end
    end
  end
end
