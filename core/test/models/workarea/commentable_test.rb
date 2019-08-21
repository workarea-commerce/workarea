require 'test_helper'

module Workarea
  class CommentableTest < TestCase

    class CommentableDocument
      include Mongoid::Document
      include Commentable
    end

    def model
      @model ||= CommentableDocument.create!
    end

    def test_add_subscription
      model.add_subscription('1,2, 3,  4   ')
      model.reload
      assert_equal(%w(1 2 3 4), model.subscribed_user_ids)
    end

    def test_remove_subscription
      model.add_subscription('1,2, 3,  4   ')
      model.reload
      model.remove_subscription(' 2  , 4')
      model.reload
      assert_equal(%w(1 3), model.subscribed_user_ids)
    end
  end
end
