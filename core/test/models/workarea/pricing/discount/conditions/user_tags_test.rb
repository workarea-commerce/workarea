require 'test_helper'

module Workarea
  module Pricing
    class Discount
      module Conditons
        class UserTagsTest < TestCase
          class TestDiscount < Pricing::Discount
            include Conditions::UserTags
          end

          def test_user_tag?
            discount = TestDiscount.new
            refute(discount.user_tag?)

            discount.user_tags = ['foo']
            assert(discount.user_tag?)

            discount.user_tags_list = 'foo, bar'
            assert(discount.user_tag?)
          end

          def test_user_tags_qualify?
            order = Workarea::Order.new
            discount = TestDiscount.new

            assert(discount.user_tags_qualify?(order))

            discount.user_tags_list = 'foo, bar'
            refute(discount.user_tags_qualify?(order))

            user = create_user
            order.user_id = user.id
            refute(discount.user_tags_qualify?(order))

            user.update(tag_list: 'foo')
            assert(discount.user_tags_qualify?(order))
          end
        end
      end
    end
  end
end
