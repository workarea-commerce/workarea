require 'test_helper'

module Workarea
  module Search
    class Admin
      class ContentPageTest < TestCase
        def test_search_text
          page = create_page(name: 'Foo', tag_list: 'one, two, three')

          result = ContentPage.new(page).search_text

          assert_includes(result, 'Foo')
          assert_includes(result, 'one, two, three')
        end
      end
    end
  end
end
