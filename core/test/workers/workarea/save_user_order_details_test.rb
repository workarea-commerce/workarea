require 'test_helper'

module Workarea
  class SaveUserOrderDetailsTest < Workarea::TestCase
    setup do
      @worker = SaveUserOrderDetails.new
    end

    def test_user_order_validation
      user = create_user(email: 'foo@baz.com')
      order = create_placed_order(
        id: '1',
        email: 'foo@bar.com',
        user_id: user.id
      )

      @worker.perform(order.id)
      user.reload

      assert(user.addresses.empty?)

      order = create_placed_order(id: '2', email: 'foo@baz.com')

      @worker.perform(order.id)
      user.reload

      assert(user.addresses.empty?)
    end

    def test_save_payment_details
      user = create_user
      order = Order.new(email: user.email, user_id: user.id)
      profile = create_payment_profile(email: user.email)

      payment = Payment.new(id: order.id)
      payment.profile = profile

      payment.set_credit_card(
        number: '1',
        month: 1,
        year: Time.current.year + 1,
        cvv: '999'
      )

      payment.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      Payment::StoreCreditCard.new(payment.credit_card).save!
      assert(payment.credit_card.persisted?)

      @worker.save_payment_details(order, user)
      user.reload

      assert_equal(user.first_name, 'Ben')
      assert_equal(user.last_name, 'Crouse')

      assert_equal(user.addresses.length, 1)
      assert_equal(user.addresses.first.first_name, 'Ben')
      assert_equal(user.addresses.first.last_name, 'Crouse')
      assert_equal(user.addresses.first.street, '22 S. 3rd St.')
      assert_equal(user.addresses.first.street_2, 'Second Floor')
      assert_equal(user.addresses.first.city, 'Philadelphia')
      assert_equal(user.addresses.first.region, 'PA')
      assert_equal(user.addresses.first.postal_code, '19106')
      assert_equal(user.addresses.first.country, Country['US'])
      assert_equal(user.addresses.first.phone_number, '2159251800')

      profile = Payment::Profile.lookup(PaymentReference.new(user))
      assert_equal(profile.credit_cards.length, 1)
      assert(profile.credit_cards.first.default?)

      payment.set_credit_card(
        number: '4111111111111111',
        month: 1,
        year: Time.current.year + 1,
        cvv: '123'
      )

      Payment::StoreCreditCard.new(payment.credit_card).save!
      assert(payment.credit_card.persisted?)
      @worker.save_payment_details(order, user)

      assert_equal(profile.credit_cards.length, 2)
      assert(profile.credit_cards.first.default?)
      refute(profile.credit_cards.last.default?)
    end

    def test_save_shipping_details
      user = create_user
      order = Order.new(email: user.email, user_id: user.id)
      order.add_item(product_id: 'PRODUCT', sku: 'SKU')

      shipping = Shipping.create!(order_id: order.id)
      shipping.set_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '22 S. 3rd St.',
        street_2: 'Second Floor',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      @worker.save_shipping_details(order, user)
      user.reload

      assert_equal(user.addresses.length, 1)
      assert_equal(user.addresses.first.first_name, 'Ben')
      assert_equal(user.addresses.first.last_name, 'Crouse')
      assert_equal(user.addresses.first.street, '22 S. 3rd St.')
      assert_equal(user.addresses.first.street_2, 'Second Floor')
      assert_equal(user.addresses.first.city, 'Philadelphia')
      assert_equal(user.addresses.first.region, 'PA')
      assert_equal(user.addresses.first.postal_code, '19106')
      assert_equal(user.addresses.first.country, Country['US'])
      assert_equal(user.addresses.first.phone_number, '2159251800')
    end
  end
end
