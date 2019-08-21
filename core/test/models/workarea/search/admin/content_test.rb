require 'test_helper'

module Workarea
  module Search
    class Admin
      class ContentTest < TestCase
        def test_should_be_indexed?
          content = create_content(contentable: nil)
          assert(Content.new(content).should_be_indexed?)

          content = create_content(contentable: create_page)
          refute(Content.new(content).should_be_indexed?)
        end
      end
    end
  end
end
