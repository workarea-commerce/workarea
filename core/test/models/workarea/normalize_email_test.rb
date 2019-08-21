require 'test_helper'

module Workarea
  class NormalizeEmailTest < TestCase
    class FooModel
      include Mongoid::Document
      include NormalizeEmail

      field :email
    end

    def test_downcases_the_email_address
      model = FooModel.create(email: 'TEST@workarea.com')
      assert_equal('test@workarea.com', model.email)
    end
  end
end
