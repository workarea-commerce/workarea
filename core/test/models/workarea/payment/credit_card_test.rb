require 'test_helper'

module Workarea
  class Payment
    class CreditCardTest < TestCase
      class CreditCardModel
        include Mongoid::Document
        include CreditCard

        field :first_name, type: String
        field :last_name, type: String
      end

      def credit_card
        @credit_card ||= CreditCardModel.new
      end

      def test_valid?
        credit_card.valid?
        assert(credit_card.errors[:number].present?)
        assert(credit_card.errors[:cvv].present?)

        credit_card.number = '111AFA11$F11AF'
        credit_card.valid?
        refute(credit_card.errors[:number].blank?)

        credit_card.number = nil
        credit_card.token = '1234'
        credit_card.valid?
        assert(credit_card.errors[:number].blank?)

        credit_card.month = 1
        credit_card.year = 1990
        credit_card.valid?
        refute(credit_card.errors[:expiration_date].blank?)

        credit_card.month = 1
        credit_card.year = Time.current.year + 5
        credit_card.valid?
        assert(credit_card.errors[:expiration_date].blank?)

        credit_card.month = Time.current.month
        credit_card.year = Time.current.year
        credit_card.valid?
        assert(credit_card.errors[:expiration_date].blank?)

        credit_card.valid?
        assert(credit_card.errors[:first_name].present?)
        assert(credit_card.errors[:last_name].present?)

        credit_card.number = 1
        credit_card.valid?
        assert(credit_card.display_number.present?)
        assert(credit_card.issuer.present?)

        Workarea.config.credit_card_issuers.delete('american_express')
        credit_card.number = 378282246310005 # amex test number
        refute(credit_card.valid?, 'valid')
        assert(credit_card.errors[:base].present?, 'no errors')
      end

      def test_number=
        credit_card.number = '1234 1234 1234 1234'
        assert_equal('1234123412341234', credit_card.number)

        credit_card.number = '1234-1234-1234-1234'
        assert_equal('1234123412341234', credit_card.number)
      end

      def test_number_changed?
        credit_card.display_number = 'XXXX-XXXX-XXXX-1234'
        credit_card.number = '1234-1234-1234-1234'
        refute(credit_card.number_changed?)

        credit_card.number = '4321-4321-4321-4321'
        assert(credit_card.number_changed?)
      end

      def test_card_change?
        refute(credit_card.card_change?)

        credit_card.stubs(persisted?: true)

        credit_card.number = '1'
        assert(credit_card.card_change?)

        credit_card.number = nil
        credit_card.month = 1.year.from_now.year
        assert(credit_card.card_change?)

        credit_card.number = nil
        credit_card.month = nil
        credit_card.year = 1
        assert(credit_card.card_change?)

        credit_card.stubs(persisted?: false)
        refute(credit_card.card_change?)
      end

      def test_to_active_merchant
        credit_card.number = '1'
        credit_card.token = '1234'
        credit_card.display_number = 'XXX-2'

        assert_equal('1234', credit_card.to_active_merchant.number)

        credit_card.token = nil
        assert_equal('1', credit_card.to_active_merchant.number)

        credit_card.number = nil
        # ActiveMerchant strips non-numerics
        assert_equal('2', credit_card.to_active_merchant.number)
      end
    end
  end
end
