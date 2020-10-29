require 'test_helper'

module Workarea
  class UpdateEmailTest < TestCase
    def test_updating_payment_profile
      user = create_user(email: 'user@workarea.com')
      profile = Payment::Profile.lookup(PaymentReference.new(user))

      UpdateEmail.new.perform(user.id.to_s, 'email' => [nil, 'user@workarea.com'])
      assert_equal(profile.reload.email, 'user@workarea.com')

      UpdateEmail.new.perform(
        user.id.to_s,
        'email' => ['user@workarea.com', 'test@workarea.com']
      )
      assert_equal(profile.reload.email, 'test@workarea.com')
    end

    def test_updating_metrics
      user = create_user(email: 'user@workarea.com')
      old_metrics = Metrics::User.find_or_initialize_by(id: 'user@workarea.com')
      old_metrics.update!(orders: 3)

      UpdateEmail.new.perform(user.id.to_s, 'email' => [nil, 'user@workarea.com'])
      assert_equal(1, Metrics::User.count)
      assert_equal(3, old_metrics.reload.orders)

      new_metrics = Metrics::User.create!(id: 'test@workarea.com', orders: 1)

      UpdateEmail.new.perform(
        user.id.to_s,
        'email' => ['user@workarea.com', 'test@workarea.com']
      )
      assert_equal(1, Metrics::User.count)
      assert_raises(Mongoid::Errors::DocumentNotFound) { old_metrics.reload }
      assert_equal(4, new_metrics.reload.orders)
    end
  end
end
