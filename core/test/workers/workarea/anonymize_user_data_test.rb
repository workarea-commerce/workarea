require 'test_helper'

module Workarea
  class AnonymizeUserDataTest < TestCase
    include SearchIndexing
    include Mail

    def test_perform
      user = create_user(email: 'bclams@workarea.com', first_name: 'Robert', last_name: 'Clams')
      order = create_placed_order(user_id: user.id, email: user.email)
      deletion_request = Email::DeletionRequest.create!(email: user.email)

      AnonymizeUserData.new.perform(deletion_request.id)
      refute(deletion_request.reload.completed?)
      assert_equal('bclams@workarea.com', deletion_request.email)

      user.reload
      assert_equal('bclams@workarea.com', user.email)

      order.reload
      assert_equal(user.email, order.email)

      fulfill_order(order)

      AnonymizeUserData.new.perform(deletion_request.id)
      assert(deletion_request.reload.completed?)
      refute_equal('bclams@workarea.com', deletion_request.email)

      user.reload
      refute_equal('bclams@workarea.com', user.email)
      assert_equal('Anonymized', user.first_name)
      assert_equal('User', user.last_name)
      assert_equal(0, user.addresses.count)

      order.reload
      refute_equal('bclams@workarea.com', order.email)

      shipping = Shipping.find_by_order(order.id)
      assert_equal('Anonymized', shipping.address.first_name)
      assert_equal('User', shipping.address.last_name)
      assert_equal('1 Anonymized St.', shipping.address.street)

      payment = Payment.find(order.id)
      assert_equal('Anonymized', payment.address.first_name)
      assert_equal('User', payment.address.last_name)
      assert_equal('1 Anonymized St.', payment.address.street)

      profile = Payment::Profile.find_by(email: deletion_request.email)
      assert_equal(0, profile.credit_cards.count)

      assert_raises(Mongoid::Errors::DocumentNotFound) { Payment::Profile.find_by(email: 'bclams@workarea.com') }
      assert_raises(Mongoid::Errors::DocumentNotFound) { Metrics::User.find('bclams@workarea.com') }

      delivery = ActionMailer::Base.deliveries.last
      assert_includes(delivery.subject, t('workarea.storefront.email.deletion_complete.subject'))
      assert_includes(delivery.to, 'bclams@workarea.com')
    end
  end
end
