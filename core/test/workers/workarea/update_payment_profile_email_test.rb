require 'test_helper'

module Workarea
  class UpdatePaymentProfileEmailTest < Workarea::TestCase
    setup do
      @user = create_user(email: 'user@workarea.com')
      @profile = Payment::Profile.lookup(PaymentReference.new(@user))
      @worker = UpdatePaymentProfileEmail.new
    end

    def test_updating_payment_profile_email_address
      @worker.perform(
        @user.id.to_s,
        'email' => ['user@workarea.com', 'test@workarea.com']
      )

      @profile.reload
      assert_equal(@profile.email, 'test@workarea.com')
    end

    def test_skipping_update_if_email_change_is_nil
      @worker.perform(@user.id.to_s, 'email' => [nil, 'user@workarea.com'])
      @profile.reload
      assert_equal(@profile.email, 'user@workarea.com')
    end
  end
end
