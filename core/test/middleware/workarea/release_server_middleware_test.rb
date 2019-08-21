require 'test_helper'

module Workarea
  class ReleaseServerMiddlewareTest < TestCase
    def test_call_disables_any_current_release
      Release.with_current(create_release.id) do
        ReleaseServerMiddleware.new.call(mock, {}, :foo) do
          assert(Release.current.blank?)
        end
      end
    end
  end
end
