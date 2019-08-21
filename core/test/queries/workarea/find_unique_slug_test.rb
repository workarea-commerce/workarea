require 'test_helper'

module Workarea
  class FindUniqueSlugTest < TestCase
    def test_slug
      page = create_page(name: 'Foo Bar')
      assert('foo-bar', FindUniqueSlug.new(page, 'foo-bar').slug)
      assert('foo-bar-1', FindUniqueSlug.new(create_page, 'foo-bar').slug)

      create_page(name: 'Foo Bar')
      assert('foo-bar-2', FindUniqueSlug.new(create_page, 'foo-bar').slug)
    end
  end
end
