require 'test_helper'

module Workarea
  class ConditionalUrlHelperTest < ViewTest
    def test_link_to_if_with_block
      result = link_to_if_with_block(true, 'www.example.com', {}) do
        "Block body"
      end
      assert_equal("<a href=\"www.example.com\">Block body</a>", result)

      result = link_to_if_with_block(false, 'www.example.com', {}) do
        "Block body"
      end
      assert_equal("Block body", result)
    end

    def test_link_to_unless_with_block
      result = link_to_unless_with_block(true, 'www.example.com', {}) do
        "Block body"
      end
      assert_equal("Block body", result)

      result = link_to_unless_with_block(false, 'www.example.com', {}) do
        "Block body"
      end
      assert_equal("<a href=\"www.example.com\">Block body</a>", result)
    end
  end
end
