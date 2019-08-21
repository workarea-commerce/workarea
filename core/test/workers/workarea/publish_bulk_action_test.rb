require 'test_helper'

module Workarea
  class PublishBulkActionTest < Workarea::TestCase
    cattr_accessor :raise_error

    class TestAction < BulkAction
      def perform!
        raise 'foo' if PublishBulkActionTest.raise_error
      end
    end

    def test_perform_marks_the_update_completed
      self.class.raise_error = false
      action = TestAction.create!(ids: %w(foo bar))
      PublishBulkAction.new.perform(action.id)
      assert(action.reload.completed?)
    end

    def test_perform_marks_the_update_as_completed_with_error
      self.class.raise_error = true
      action = TestAction.create!(ids: %w(foo bar))
      assert_raise { PublishBulkAction.new.perform(action.id) }
      assert(action.reload.completed?)
    end
  end
end
