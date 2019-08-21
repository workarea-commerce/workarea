require 'test_helper'

module Workarea
  class PaymentReferenceTest < TestCase
    def test_email_casing
      user = create_user

      user.email = 'bCrOuSe@webLinC.cOM'
      reference = PaymentReference.new(user)
      assert_equal('bcrouse@weblinc.com', reference.email)

      order = create_order(email: 'bcrouse@weblinc.com')
      reference = PaymentReference.new(nil, order)
      assert_equal('bcrouse@weblinc.com', reference.email)
    end
  end
end
