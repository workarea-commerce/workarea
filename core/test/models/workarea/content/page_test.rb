require 'test_helper'

module Workarea
  class Content
    class PageTest < TestCase
      include NavigableTest

      def navigable_class
        Page
      end
    end
  end
end
