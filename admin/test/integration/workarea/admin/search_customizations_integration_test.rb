require 'test_helper'

module Workarea
  module Admin
    class SearchCustomizationsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_autocomplete
        create_search_customization(id: 'test', query: 'test')
        create_search_customization(id: 'test_foo', query: 'test foo')

        get admin.search_customizations_path(format: 'json', q: 'tes'), xhr: true

        results = JSON.parse(response.body)['results']
        assert_equal(2, results.length)
      end

      def test_creating
        post admin.search_customizations_path, params: { q: 'Test' }

        assert_equal(1, Search::Customization.count)
        customization = Search::Customization.first

        assert_equal('test', customization.id)
        assert_equal('test', customization.query)
      end

      def test_invalid_creation
        assert_nothing_raised do
          post admin.search_customizations_path, params: { q: '' }
        end

        assert_redirected_to(admin.root_path)
      end

      def test_updating
        customization = create_search_customization

        patch admin.search_customization_path(customization),
          params: {
            customization: {
              rewrite: 'bar',
              redirect: 'http://www.foo.com'
            }
          }

        customization.reload

        assert_equal('bar', customization.rewrite)
        assert_equal('http://www.foo.com', customization.redirect)
      end

      def test_deleting
        customization = create_search_customization
        delete admin.search_customization_path(customization)
        assert_equal(0, Search::Customization.count)
      end
    end
  end
end
