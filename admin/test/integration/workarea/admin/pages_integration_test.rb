require 'test_helper'

module Workarea
  module Admin
    class PagesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_updates_a_page
        page = create_page

        patch admin.content_page_path(page),
          params: {
            page: {
              name: 'Test Page',
              slug: 'test-slug',
              tag_list: 'different,tags',
              show_navigation: true
            }
          }

        page.reload
        assert_equal('Test Page', page.name)
        assert_equal('test-slug', page.slug)
        assert_equal(%w(different tags), page.tags)
        assert(page.show_navigation?)
      end

      def test_deletes_a_page
        page = create_page
        delete admin.content_page_path(page)
        assert(Content::Page.empty?)
      end

      def test_autocompletes_partial_queries_when_xhr
        page = create_page(name: 'Test')
        get admin.content_pages_path(format: 'json', q: 'tes'), xhr: true

        results = JSON.parse(response.body)
        assert_equal(1, results['results'].length)
        assert(results['results'].first['label'].present?)
        assert_equal(page.id.to_s, results['results'].first['value'])
      end
    end
  end
end
