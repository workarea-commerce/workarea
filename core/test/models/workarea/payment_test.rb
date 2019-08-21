require 'test_helper'

module Workarea
  class PaymentTest < TestCase
    class FooTender
      attr_reader :amount

      def initialize(max = nil)
        @max = max
      end

      def amount=(val)
        @amount = if @max.present?
                    val > @max ? @max : val
                  else
                    val
                  end
      end
    end

    def test_set_credit_card
      payment = Payment.new
      payment.set_credit_card(
        number: '4111111111111111',
        month: 1,
        year: Time.current.year + 1,
        cvv: '123',
        amount: 1.to_m
      )

      assert(payment.credit_card.present?)
      assert(payment.credit_card.errors.present?)
    end

    def test_lookup
      order_id = '1234'
      postal_code = '19106'
      payment = Payment.new(id: order_id)
      payment.set_address(postal_code: postal_code)
      payment.save(validate: false)

      assert_equal(payment, Payment.lookup(order_id, postal_code))
      assert_nil(Payment.lookup(order_id, '19143'))
    end

    def test_sets_the_credit_card_on_the_payment
      payment = Payment.create!
      payment.set_credit_card(number: '1', month: 1, year: 2012, cvv: 999)

      refute_nil(payment.credit_card)
      assert_equal('1', payment.credit_card.number)
      assert_equal(1, payment.credit_card.month)
      assert_equal(2012, payment.credit_card.year)
      assert_equal(999, payment.credit_card.cvv)
    end

    def test_resets_saved_card_id_on_the_credit_card_when_resetting
      payment = Payment.create!
      card = create_saved_credit_card

      payment.profile = card.profile
      payment.set_credit_card(saved_card_id: card.id, cvv: '999')
      assert_equal(card.id.to_s, payment.credit_card.saved_card_id)
      assert_equal('999', payment.credit_card.cvv)

      payment.set_credit_card(
        number: '1',
        month: 1,
        year: 2012,
        cvv: 999
      )

      assert_equal('1', payment.credit_card.number)
      assert_equal(1, payment.credit_card.month)
      assert_equal(2012, payment.credit_card.year)
      assert(payment.credit_card.saved_card_id.blank?)
      assert_equal(999, payment.credit_card.cvv)
    end

    def test_adjust_tender_amounts
      payment = Payment.new
      tenders = [FooTender.new(3), FooTender.new, FooTender.new, FooTender.new]

      payment.stubs(tenders: tenders) do
        payment.adjust_tender_amounts(4)

        assert_equal(3, tenders.first.amount)
        assert_equal(1, tenders.second.amount)
        assert_equal(0, tenders.third.amount)
        assert_equal(0, tenders.fourth.amount)
      end
    end

    def test_purchasable
      payment = Payment.new(address: { first_name: 'Ben', last_name: 'Crouse' })
      payment.set_credit_card(
        number: '1',
        month: 1,
        year: 1999,
        cvv: 999
      )

      refute(payment.purchasable?(0.to_m))

      payment.set_credit_card(
        number: '1',
        month: 1,
        year: Time.current.year + 1,
        cvv: 999
      )

      refute(payment.purchasable?(1.to_m))

      payment.set_credit_card(
        number: '1',
        month: 1,
        year: Time.current.year + 1,
        cvv: 999
      )

      payment.credit_card.amount = 1.to_m
      assert(payment.purchasable?(1.to_m))
    end

    def test_status
      payment = Payment.new(
        address: {
          first_name: 'Ben',
          last_name: 'Crouse',
          street: '22 S. 3rd St.',
          street_2: 'Second Floor',
          city: 'Philadelphia',
          region: 'PA',
          postal_code: '19106',
          country: 'US',
          phone_number: '2159251800'
        }
      )

      assert_equal(:not_applicable, payment.status)

      payment.build_credit_card(
        number: '4111111111111111',
        month: 1,
        year: Time.current.year + 1,
        cvv: 999,
        amount: 10.to_m
      )

      tender = payment.credit_card
      payment.save!

      assert_equal(:pending, payment.status)

      tender.build_transaction(amount: 10.to_m, success: true, action: 'authorize').save!

      assert_equal(:authorized, payment.reload.status)

      tender.build_transaction(amount: 5.to_m, success: true, action: 'capture').save!
      assert_equal(:partially_captured, payment.reload.status)

      tender.build_transaction(amount: 5.to_m, success: true, action: 'purchase').save!
      assert_equal(:captured, payment.status)

      tender.build_transaction(amount: 5.to_m, success: true, action: 'refund').save!
      assert_equal(:partially_refunded, payment.reload.status)

      tender.build_transaction(amount: 5.to_m, success: true, action: 'refund').save!
      assert_equal(:refunded, payment.reload.status)
    end
  end
end
